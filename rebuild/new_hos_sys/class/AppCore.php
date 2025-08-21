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
        try {
            $this->pdo = new PDO(
                'mysql:host=localhost;dbname=new_hossysdb;charset=utf8mb4',
                'root',
                '',
                [
                    PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                    PDO::ATTR_EMULATE_PREPARES => false,
                ]
            );
        } catch (PDOException $e) {
            http_response_code(500);
            echo 'DB connection failed.';
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
     * ユーザー表示名の取得（現状はIDのみ返却）
     * @param string $userId
     * @return string|null
     */
    public function loadDisplayName(string $userId): ?string {
        $st = $this->pdo->prepare('SELECT user_id FROM users WHERE user_id=?');
        $st->execute([$userId]);
        $row = $st->fetch();
        return $row ? ($row['user_id'] ?? null) : null;
    }

    /**
     * HTMLエスケープ（XSS対策）
     * @param string|null $s
     * @return string
     */
    public static function h(?string $s): string {
        return htmlspecialchars($s ?? '', ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8');
    }

}
