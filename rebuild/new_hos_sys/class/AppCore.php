<?php
/**
 * AppCore.php
 * システムのコア機能を1つのクラスで管理します。
 * - DB接続
 * - セッション管理
 * - ユーザー認証
 * - ログイン履歴・レートリミット
 * - ユーザー情報取得
 * - APIレスポンス生成
 *
 * どの処理が何をしているか、各メソッドに詳細コメントを記載しています。
 */

class AppCore {
    /** @var PDO $pdo DB接続用PDOインスタンス */
    public $pdo;

    /**
     * コンストラクタ：DB接続とセッション初期化
     */
    public function __construct() {
        date_default_timezone_set('Asia/Tokyo'); // タイムゾーン設定
        $this->initDb();      // DB接続
        $this->initSession(); // セッション初期化
    }

    /**
     * DB接続を初期化します。
     * エラー時は500で終了。
     */
    private function initDb() {
        $host = getenv('DB_HOST') ?: 'localhost';      // XAMPPの既定
        $port = getenv('DB_PORT') ?: '3306';
        $db   = getenv('DB_DATABASE') ?: 'new_hossysdb'; // ←XAMPP側のDB名に合わせる
        $user = getenv('DB_USERNAME') ?: 'root';
        $pass = getenv('DB_PASSWORD') ?: '';

        $dsn = "mysql:host={$host};port={$port};dbname={$db};charset=utf8mb4";

        try {
            $this->pdo = new PDO($dsn, $user, $pass, [
                PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                PDO::ATTR_EMULATE_PREPARES => false,
            ]);
        } catch (PDOException $e) {
            http_response_code(500);
            echo 'DB connection failed: ' . htmlspecialchars($e->getMessage());
            exit;
        }
    }


    /**
     * セッションの初期化とセキュリティ設定
     */
    private function initSession() {
        $secure = (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off');
        session_set_cookie_params([
            'lifetime' => 0,
            'path' => '/',
            'secure' => $secure,
            'httponly' => true,
            'samesite' => 'Lax'
        ]);
        if (session_status() !== PHP_SESSION_ACTIVE) session_start();
    }

    /**
     * HTMLエスケープ（XSS対策）
     * @param string|null $s
     * @return string
    */
    public static function escape(?string $s): string {
        return htmlspecialchars($s ?? '', ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8');
    }

    /**
     * ユーザーID、ユーザー名、権限の取得
     * @param string $userId
     * @return array|null
     */
    public function loadUserInfo(string $userId): ?array {
        $st = $this->pdo->prepare('SELECT user_id, user_name, role FROM users WHERE user_id=?');
        $st->execute([$userId]);
        $row = $st->fetch();
        return $row ? $row : null;
    }

    /**
     * 権限毎に出力する表記を変更
     */
    public function getRoleLabel($role){
        switch($role){
            case 'system_admin':
                return 'システム管理者';
            case 'admin':
                return '管理者';
            case 'editor':
                return '一般(事務)';
            case 'viewer':
                return '一般';
            default:
                return '-';
        }

    }

}
