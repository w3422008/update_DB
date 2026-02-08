<?php
/**
 * AppCore.php
 * システムのコア機能を1つのクラスで管理。
 * - DB接続（CommonRepository から取得）
 * - セッション管理
 * - ユーザー認証
 * - ログイン履歴・レートリミット
 * - ユーザー情報取得
 * - APIレスポンス生成
 * - ルーティング・アセットヘルパー
 *
 * DB接続情報は CommonRepository で管理。
 */

require_once __DIR__ . '/../Repositories/CommonRepository.php';
require_once __DIR__ . '/../../config/config.php';

class AppCore {
    /** @var PDO $pdo DB接続用PDOインスタンス（CommonRepository から取得） */
    public $pdo;

    /**
     * コンストラクタ：DB接続とセッション初期化
     */
    public function __construct($initSession = true) {
        date_default_timezone_set('Asia/Tokyo'); // タイムゾーン設定
        $this->initDb();      // DB接続
        if ($initSession) {
            $this->initSession();                 // セッション初期化（必要な場合のみ）
        }    
    }

    /**
     * DB接続を初期化します。
     * CommonRepository から DB 接続を取得して $pdo に保存します。
     * エラー時は500で終了。
     */
    private function initDb() {
        try {
            $this->pdo = CommonRepository::getDbConnection();
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

/**
 * グローバルヘルパー関数
 * ビュー内で短く route() と asset() を使用可能
 */

/**
 * ルーティング用パスを生成
 * @param string $path
 * @return string
 */
function route(string $path): string {
    return BASE_PATH . $path;
}

/**
 * アセットファイルのパスを生成
 * @param string $path
 * @return string
 */
function asset(string $path): string {
    return ASSETS_PATH . $path;
}
