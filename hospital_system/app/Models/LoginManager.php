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
    public function handle($app) {
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
        $_SESSION['user_id'] = $app->escape($userId);
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
        
        // ログイン成功時にfailed_attemptsをリセット
        $this->resetFailedAttempts($userId);
        
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
        // keyからuser_idを抽出（uid:で始まる場合のみlogin_attempt_countsを使用）
        if (strpos($key, 'uid:') === 0) {
            $userId = substr($key, 4);
            $this->incrementFailedAttempts($userId);
        }
        
        // 従来のログ記録も並行して実行（統計用）
        if ($this->logManager) {
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
        // ユーザーIDベースの場合はlogin_attempt_countsテーブルをチェック
        if (strpos($key, 'uid:') === 0) {
            $userId = substr($key, 4);
            // 古い試行履歴をクリーンアップしてからチェック
            $this->cleanupOldAttempts($userId);
            return $this->isUserRateLimitExceeded($userId, $limit);
        }
        
        // IPアドレスベースの場合は従来通り
        if (!$this->logManager) {
            return false;
        }
        
        return $this->logManager->isRateLimitExceeded($key, $limit, $intervalSql);
    }

    /**
     * ユーザーの失敗試行回数を増加させる
     * @param string $userId
     */
    private function incrementFailedAttempts(string $userId): void {
        try {
            $stmt = $this->pdo->prepare("
                INSERT INTO login_attempt_counts (user_id, failed_attempts, last_failed_at) 
                VALUES (?, 1, NOW()) 
                ON DUPLICATE KEY UPDATE 
                    failed_attempts = failed_attempts + 1, 
                    last_failed_at = NOW()
            ");
            $stmt->execute([$userId]);
        } catch (Exception $e) {
            error_log("Failed to increment login attempts: " . $e->getMessage());
        }
    }

    /**
     * ユーザーの失敗試行回数をリセットする（ログイン成功時）
     * @param string $userId
     */
    private function resetFailedAttempts(string $userId): void {
        try {
            $stmt = $this->pdo->prepare("
                UPDATE login_attempt_counts 
                SET failed_attempts = 0, last_failed_at = NULL 
                WHERE user_id = ?
            ");
            $stmt->execute([$userId]);
        } catch (Exception $e) {
            error_log("Failed to reset login attempts: " . $e->getMessage());
        }
    }

    /**
     * ユーザーのレートリミットが超過しているかチェック
     * @param string $userId
     * @param int $limit
     * @return bool
     */
    private function isUserRateLimitExceeded(string $userId, int $limit): bool {
        try {
            $stmt = $this->pdo->prepare("
                SELECT failed_attempts, last_failed_at 
                FROM login_attempt_counts 
                WHERE user_id = ? AND failed_attempts >= ?
            ");
            $stmt->execute([$userId, $limit]);
            $row = $stmt->fetch();
            
            if (!$row) {
                return false;
            }
            
            // 15分以内の失敗があるかチェック
            $lastFailed = strtotime($row['last_failed_at']);
            $fifteenMinutesAgo = time() - (15 * 60);
            
            return $lastFailed > $fifteenMinutesAgo;
            
        } catch (Exception $e) {
            error_log("Failed to check rate limit: " . $e->getMessage());
            return false;
        }
    }

    /**
     * 古い試行履歴をクリーンアップ（15分以上経過したレコードをリセット）
     * @param string|null $userId 特定ユーザーのみクリーンアップする場合は指定、nullで全体
     */
    private function cleanupOldAttempts(?string $userId = null): void {
        try {
            if ($userId !== null) {
                // 特定ユーザーのクリーンアップ
                $stmt = $this->pdo->prepare("
                    UPDATE login_attempt_counts 
                    SET failed_attempts = 0, last_failed_at = NULL 
                    WHERE user_id = ? AND last_failed_at < DATE_SUB(NOW(), INTERVAL 15 MINUTE)
                ");
                $stmt->execute([$userId]);
            } else {
                // 全体のクリーンアップ
                $stmt = $this->pdo->prepare("
                    UPDATE login_attempt_counts 
                    SET failed_attempts = 0, last_failed_at = NULL 
                    WHERE last_failed_at < DATE_SUB(NOW(), INTERVAL 15 MINUTE)
                ");
                $stmt->execute();
            }
        } catch (Exception $e) {
            error_log("Failed to cleanup old attempts: " . $e->getMessage());
        }
    }

    /**
     * 全ユーザーの古い試行履歴を定期的にクリーンアップ
     * 通常は1日1回程度バッチ処理で呼び出すことを想定
     */
    public function batchCleanupOldAttempts(): void {
        $this->cleanupOldAttempts();
    }

    /**
     * ユーザーの現在の失敗試行回数を取得
     * @param string $userId
     * @return array ['failed_attempts' => int, 'last_failed_at' => string|null]
     */
    public function getUserFailedAttempts(string $userId): array {
        try {
            $stmt = $this->pdo->prepare("
                SELECT failed_attempts, last_failed_at 
                FROM login_attempt_counts 
                WHERE user_id = ?
            ");
            $stmt->execute([$userId]);
            $row = $stmt->fetch();
            
            if (!$row) {
                return ['failed_attempts' => 0, 'last_failed_at' => null];
            }
            
            return [
                'failed_attempts' => (int)$row['failed_attempts'],
                'last_failed_at' => $row['last_failed_at']
            ];
            
        } catch (Exception $e) {
            error_log("Failed to get user failed attempts: " . $e->getMessage());
            return ['failed_attempts' => 0, 'last_failed_at' => null];
        }
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