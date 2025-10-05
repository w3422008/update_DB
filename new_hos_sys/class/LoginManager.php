<?php
/**
 * LoginManager.php
 * ログイン認証・レートリミット・セッション管理クラス
 *
 * - handle: API本体（POST受付・認証・レートリミット・セッション管理・JSON返却）
 * - tooManyAttempts: 試行回数制限判定
 * - authenticate: 認証処理
 * - recordAttempt: 試行履歴記録
 * - loginSuccess: 認証成功時の処理
 * - json: JSON返却
 */

require_once __DIR__ . '/LogAuditManager.php';

class LoginManager {
    /** @var PDO|null $pdo DB接続用PDOインスタンス */
    private $pdo;
    
    /** @var LogAuditManager|null $logManager ログ管理用インスタンス */
    private $logManager;

    /**
     * コンストラクタ
     * @param PDO|null $pdo DB接続（ログアウト時はnull可）
     */
    public function __construct($pdo) {
        $this->pdo = $pdo;
        $this->logManager = $pdo ? new LogAuditManager($pdo) : null;
    }

    // JSON返却
    public function json($arr) {
        echo json_encode($arr);
    }

    /**
     * API本体（POST受付・認証・レートリミット・セッション管理・JSON返却）
     */
    public function handle() {
        if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
            http_response_code(405);
            $this->json(['success' => false, 'message' => 'POSTメソッドのみ許可されています。']);
            exit;
        }
        $input = json_decode(file_get_contents('php://input'), true);
        $userId = trim($input['user_id'] ?? '');
        $password = $input['password'] ?? '';
        $ip = $_SERVER['REMOTE_ADDR'] ?? 'unknown';
        $ipKey = "ip:$ip";
        $uidKey = "uid:$userId";
        // 試行回数制限判定
        if ($this->rlTooMany($ipKey, 20, '15 MINUTE') || $this->rlTooMany($uidKey, 10, '15 MINUTE')) {
            // レートリミット制限ログを記録
            if ($this->logManager) {
                $this->logManager->recordRateLimitHit($userId, $ip);
            }
            $this->json(['success' => false, 'message' => '試行回数が多すぎます。しばらくしてからお試しください。']);
            exit;
        }
        $isValid = $this->checkCredentials($userId, $password);
        // 認証失敗時の処理
        if (!$isValid) {
            // レートリミット記録
            $this->rlRecord($ipKey); 
            $this->rlRecord($uidKey); 
            
            // 詳細な失敗ログを記録
            if ($this->logManager) {
                $this->logManager->recordLoginFailure($userId, $ip, 'Invalid credentials');
            }
            
            usleep(250000);
            $this->json(['success' => false, 'message' => 'IDまたはパスワードが正しくありません。']);
            exit;
        }
        // 認証成功時の処理
        session_regenerate_id(true);
        $_SESSION['user_id'] = $userId;
        $this->afterLogin($userId);
        $this->json(['success' => true]);
        exit;
    }

    /**
     * ユーザーIDとパスワードで認証を行う
     * @param string $userId ユーザーID
     * @param string $password パスワード
     * @return bool 認証成功ならtrue
     */
    public function checkCredentials(string $userId, string $password): bool {
        $st = $this->pdo->prepare('SELECT password_hash,is_active FROM users WHERE user_id=?');
        $st->execute([$userId]);
        $row = $st->fetch();
        // ユーザーが存在しない or 無効ならfalse
        if(!$row || !(int)$row['is_active']) return false;
        // パスワード照合
        return password_verify($password, $row['password_hash']);
    }

    /**
     * ログイン成功時の処理（最終ログイン日時の更新・ログ記録）
     * @param string $userId
     */
    public function afterLogin(string $userId): void {
        // 最終ログイン日時の更新
        $st = $this->pdo->prepare('UPDATE users SET last_login_at=NOW() WHERE user_id=?');
        $st->execute([$userId]);
        
        // ログイン成功ログをunified_logsに記録
        if ($this->logManager) {
            $sessionId = session_id();
            $this->logManager->recordLoginSuccess($userId, $sessionId);
        }
    }

    /**
     * ログイン試行履歴を記録（レートリミット用）
     * @param string $key
     */
    public function rlRecord(string $key): void {
        if ($this->logManager) {
            // keyからuser_idを抽出（uid:で始まる場合）
            $userId = null;
            if (strpos($key, 'uid:') === 0) {
                $userId = substr($key, 4);
            }
            
            $this->logManager->recordLoginAttempt($key, $userId);
        }
    }

    /**
     * ログイン試行回数が制限を超えているか判定
     * @param string $key
     * @param int $limit
     * @param string $intervalSql
     * @return bool
     */
    public function rlTooMany(string $key, int $limit, string $intervalSql): bool {
        if (!$this->logManager) {
            return false;
        }
        
        return $this->logManager->isRateLimitExceeded($key, $limit, $intervalSql);
    }

    // ログアウト処理
    public function Logout() {
        // セッションが開始されていない場合は開始
        if (session_status() === PHP_SESSION_NONE) {
            session_start();
        }
        
        // ログアウトログ記録（PDOが存在し、ユーザーIDがある場合のみ）
        if ($this->logManager && isset($_SESSION['user_id'])) {
            $userId = $_SESSION['user_id'];
            $sessionId = session_id();
            
            try {
                $this->logManager->recordLogout($userId, $sessionId);
            } catch (Exception $e) {
                // ログ記録失敗してもログアウト処理は継続
                error_log("ログアウトログ記録エラー: " . $e->getMessage());
            }
        }
        
        // セッション変数を全て空に
        $_SESSION = [];
        // セッションクッキー削除
        if (ini_get('session.use_cookies')) {
            $params = session_get_cookie_params();
            setcookie(session_name(), '', time() - 42000, $params['path'], $params['domain'] ?? '', $params['secure'], $params['httponly']);
        }
        // セッション破棄
        session_destroy();
    }

}