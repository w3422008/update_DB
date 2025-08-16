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
class LoginManager {
    /** @var PDO $pdo DB接続用PDOインスタンス */
    private $pdo;

    /**
     * コンストラクタ
     * @param PDO $pdo DB接続
     */
    public function __construct($pdo) {
        $this->pdo = $pdo;
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
            $this->json(['success' => false, 'message' => '試行回数が多すぎます。しばらくしてからお試しください。']);
            exit;
        }
        $isValid = $this->checkCredentials($userId, $password);
        // 認証失敗時の処理
        if (!$this->checkCredentials($userId, $password)) {
            $this->rlRecord($ipKey); $this->rlRecord($uidKey); usleep(250000);
            $this->json(['success' => false, 'message' => 'IDまたはパスワードが正しくありません。', 'user_id' => $userId,'password' => $password,'isvaild'=>$isValid]);
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
        $st = $this->pdo->prepare('SELECT pwd_hash,is_active FROM users WHERE user_id=?');
        $st->execute([$userId]);
        $row = $st->fetch();
        // ユーザーが存在しない or 無効ならfalse
        if(!$row || !(int)$row['is_active']) return false;
        // パスワード照合
        return password_verify($password, $row['pwd_hash']);
    }

    /**
     * ログイン成功時の処理（最終ログイン日時の更新）
     * @param string $userId
     */
    public function afterLogin(string $userId): void {
        $st = $this->pdo->prepare('UPDATE users SET last_login_at=NOW() WHERE user_id=?');
        $st->execute([$userId]);
    }

    /**
     * ログイン試行履歴を記録（レートリミット用）
     * @param string $key
     */
    public function rlRecord(string $key): void {
        $st = $this->pdo->prepare('INSERT INTO login_attempts (key_name) VALUES (?)');
        $st->execute([$key]);
    }

    /**
     * ログイン試行回数が制限を超えているか判定
     * @param string $key
     * @param int $limit
     * @param string $intervalSql
     * @return bool
     */
    public function rlTooMany(string $key, int $limit, string $intervalSql): bool {
        $st = $this->pdo->prepare("SELECT COUNT(*) FROM login_attempts WHERE key_name=? AND attempted > (NOW()-INTERVAL $intervalSql)");
        $st->execute([$key]);
        return ((int)$st->fetchColumn()) >= $limit;
    }

}