<?php
/**
 * LogAuditManager.php
 * ログ・監査記録管理クラス
 *
 * unified_logsテーブルを使用して以下のログを一元管理：
 * - ログイン成功/失敗ログ
 * - レートリミット制限ログ
 * - ログアウトログ
 * - 監査ログ
 * - セキュリティログ
 * - アクセスログ
 */
class LogAuditManager {
    /** @var PDO $pdo DB接続用PDOインスタンス */
    private $pdo;

    /**
     * コンストラクタ
     * @param PDO $pdo DB接続
     */
    public function __construct(PDO $pdo) {
        $this->pdo = $pdo;
    }

    /**
     * ログイン成功ログを記録
     * @param string $userId ユーザーID
     * @param string $sessionId セッションID
     */
    public function recordLoginSuccess(string $userId, string $sessionId): void {
        $ip = $_SERVER['REMOTE_ADDR'] ?? 'unknown';
        $userAgent = $_SERVER['HTTP_USER_AGENT'] ?? '';
        
        $this->insertLog([
            'log_type' => 'security',
            'user_id' => $userId,
            'session_id' => $sessionId,
            'access_type' => 'login',
            'event_type' => 'login_success',
            'severity' => 'low',
            'description' => "ユーザーログイン成功: {$userId}",
            'ip_address' => $ip,
            'user_agent' => $userAgent
        ]);
    }

    /**
     * ログイン失敗ログを記録
     * @param string $userId ユーザーID
     * @param string $ip IPアドレス
     * @param string $reason 失敗理由
     */
    public function recordLoginFailure(string $userId, string $ip, string $reason): void {
        $userAgent = $_SERVER['HTTP_USER_AGENT'] ?? '';
        
        $this->insertLog([
            'log_type' => 'security',
            'user_id' => $userId,
            'access_type' => 'login',
            'event_type' => 'login_failure',
            'severity' => 'medium',
            'description' => "ログイン認証失敗: {$userId}",
            'failure_reason' => $reason,
            'ip_address' => $ip,
            'user_agent' => $userAgent
        ]);
    }

    /**
     * レートリミット制限ヒット時のログを記録
     * @param string $userId ユーザーID
     * @param string $ip IPアドレス
     */
    public function recordRateLimitHit(string $userId, string $ip): void {
        $userAgent = $_SERVER['HTTP_USER_AGENT'] ?? '';
        
        $this->insertLog([
            'log_type' => 'security',
            'user_id' => $userId,
            'access_type' => 'login',
            'event_type' => 'login_failure',
            'severity' => 'high',
            'description' => "レートリミット制限ヒット: {$userId}",
            'failure_reason' => 'Too many login attempts',
            'ip_address' => $ip,
            'user_agent' => $userAgent
        ]);
    }

    /**
     * ログアウトログを記録
     * @param string $userId ユーザーID
     * @param string $sessionId セッションID
     */
    public function recordLogout(string $userId, string $sessionId): void {
        $ip = $_SERVER['REMOTE_ADDR'] ?? 'unknown';
        $userAgent = $_SERVER['HTTP_USER_AGENT'] ?? '';
        
        $this->insertLog([
            'log_type' => 'security',
            'user_id' => $userId,
            'session_id' => $sessionId,
            'access_type' => 'logout',
            'event_type' => 'login_success',  // ログアウトは正常な操作なのでsuccess
            'severity' => 'low',
            'description' => "ユーザーログアウト: {$userId}",
            'ip_address' => $ip,
            'user_agent' => $userAgent
        ]);
    }

    /**
     * ログイン試行履歴を記録（レートリミット用）
     * @param string $key レートリミットキー
     * @param string|null $userId ユーザーID（取得できる場合）
     */
    public function recordLoginAttempt(string $key, ?string $userId = null): void {
        $ip = $_SERVER['REMOTE_ADDR'] ?? 'unknown';
        $userAgent = $_SERVER['HTTP_USER_AGENT'] ?? '';
        
        $this->insertLog([
            'log_type' => 'login_attempt',
            'user_id' => $userId,
            'access_type' => 'login',
            'event_type' => 'login_failure',
            'severity' => 'medium',
            'description' => "ログイン試行制限記録: {$key}",
            'ip_address' => $ip,
            'user_agent' => $userAgent,
            'additional_data' => json_encode(['rate_limit_key' => $key])
        ]);
    }

    /**
     * 監査ログを記録
     * @param string $userId ユーザーID
     * @param string $tableName 対象テーブル名
     * @param string $recordId 対象レコードID
     * @param string $actionType 操作種別（INSERT/UPDATE/DELETE）
     * @param array|null $oldValues 変更前データ
     * @param array|null $newValues 変更後データ
     * @param string $description 説明
     */
    public function recordAudit(
        string $userId, 
        string $tableName, 
        string $recordId, 
        string $actionType, 
        ?array $oldValues = null, 
        ?array $newValues = null, 
        string $description = ''
    ): void {
        $ip = $_SERVER['REMOTE_ADDR'] ?? 'unknown';
        $userAgent = $_SERVER['HTTP_USER_AGENT'] ?? '';
        $sessionId = session_id();
        
        $this->insertLog([
            'log_type' => 'audit',
            'user_id' => $userId,
            'session_id' => $sessionId,
            'table_name' => $tableName,
            'record_id' => $recordId,
            'action_type' => $actionType,
            'old_values' => $oldValues ? json_encode($oldValues) : null,
            'new_values' => $newValues ? json_encode($newValues) : null,
            'severity' => 'medium',
            'description' => $description ?: "データ{$actionType}操作: {$tableName}#{$recordId}",
            'ip_address' => $ip,
            'user_agent' => $userAgent
        ]);
    }

    /**
     * アクセスログを記録
     * @param string $userId ユーザーID
     * @param string $accessType アクセス種別
     * @param string $pageUrl ページURL
     * @param string $pageName ページ名
     * @param string $httpMethod HTTPメソッド
     * @param array|null $requestParams リクエストパラメータ
     * @param int|null $responseStatus レスポンスステータス
     * @param int|null $responseTime レスポンス時間（ミリ秒）
     */
    public function recordAccess(
        string $userId,
        string $accessType,
        string $pageUrl,
        string $pageName,
        string $httpMethod = 'GET',
        ?array $requestParams = null,
        ?int $responseStatus = null,
        ?int $responseTime = null
    ): void {
        $ip = $_SERVER['REMOTE_ADDR'] ?? 'unknown';
        $userAgent = $_SERVER['HTTP_USER_AGENT'] ?? '';
        $sessionId = session_id();
        $referer = $_SERVER['HTTP_REFERER'] ?? '';
        
        $this->insertLog([
            'log_type' => 'access',
            'user_id' => $userId,
            'session_id' => $sessionId,
            'access_type' => $accessType,
            'page_url' => $pageUrl,
            'page_name' => $pageName,
            'http_method' => $httpMethod,
            'request_params' => $requestParams ? json_encode($requestParams) : null,
            'response_status' => $responseStatus,
            'response_time_ms' => $responseTime,
            'referer' => $referer,
            'severity' => 'low',
            'description' => "ページアクセス: {$pageName} ({$pageUrl})",
            'ip_address' => $ip,
            'user_agent' => $userAgent
        ]);
    }

    /**
     * セキュリティログを記録
     * @param string $userId ユーザーID
     * @param string $eventType セキュリティイベント種別
     * @param string $severity 重要度（low/medium/high/critical）
     * @param string $description 説明
     * @param string|null $targetResource 対象リソース
     * @param string|null $failureReason 失敗理由
     */
    public function recordSecurity(
        string $userId,
        string $eventType,
        string $severity,
        string $description,
        ?string $targetResource = null,
        ?string $failureReason = null
    ): void {
        $ip = $_SERVER['REMOTE_ADDR'] ?? 'unknown';
        $userAgent = $_SERVER['HTTP_USER_AGENT'] ?? '';
        $sessionId = session_id();
        
        $this->insertLog([
            'log_type' => 'security',
            'user_id' => $userId,
            'session_id' => $sessionId,
            'event_type' => $eventType,
            'severity' => $severity,
            'description' => $description,
            'target_resource' => $targetResource,
            'failure_reason' => $failureReason,
            'ip_address' => $ip,
            'user_agent' => $userAgent
        ]);
    }

    /**
     * unified_logsテーブルにログを挿入
     * @param array $logData ログデータ
     */
    private function insertLog(array $logData): void {
        try {
            // ユーザー情報を自動取得してfacility_idとdepartment_idを設定
            if (isset($logData['user_id']) && $logData['user_id']) {
                $userInfo = $this->getUserInfo($logData['user_id']);
                if ($userInfo) {
                    $logData['facility_id'] = $userInfo['facility_id'];
                    $logData['department_id'] = $userInfo['department_id'];
                    // 管理者フラグの設定
                    $logData['is_admin'] = ($userInfo['role'] === 'admin');
                }
            }
            
            // カラム名と値を動的に構築
            $columns = array_keys($logData);
            $placeholders = array_fill(0, count($columns), '?');
            
            $sql = "INSERT INTO unified_logs (" . 
                   implode(', ', $columns) . 
                   ") VALUES (" . 
                   implode(', ', $placeholders) . 
                   ")";
            
            $st = $this->pdo->prepare($sql);
            $st->execute(array_values($logData));
            
        } catch (Exception $e) {
            // ログ記録失敗時はエラーログに記録（無限ループを避けるため）
            error_log("LogAuditManager: ログ記録エラー - " . $e->getMessage());
            error_log("LogAuditManager: 失敗したログデータ - " . json_encode($logData));
        }
    }

    /**
     * ユーザー情報を取得
     * @param string $userId ユーザーID
     * @return array|null ユーザー情報
     */
    private function getUserInfo(string $userId): ?array {
        try {
            $st = $this->pdo->prepare('SELECT facility_id, department_id, role FROM users WHERE user_id = ?');
            $st->execute([$userId]);
            return $st->fetch(PDO::FETCH_ASSOC) ?: null;
        } catch (Exception $e) {
            error_log("LogAuditManager: ユーザー情報取得エラー - " . $e->getMessage());
            return null;
        }
    }

    /**
     * 簡易ページアクセスログ記録（セッション情報から自動取得）
     * @param string $pageName ページ名
     * @param string $pageUrl ページURL（省略時は現在のURL）
     */
    public function logPageAccess(string $pageName, ?string $pageUrl = null): void {
        if (isset($_SESSION['user_id'])) {
            $this->recordAccess(
                $_SESSION['user_id'],
                'page_access',
                $pageUrl ?: $_SERVER['REQUEST_URI'] ?? '',
                $pageName
            );
        }
    }

    /**
     * 権限拒否ログの記録
     * @param string $userId ユーザーID
     * @param string $resource 対象リソース
     * @param string $requiredRole 必要な権限
     */
    public function logPermissionDenied(string $userId, string $resource, string $requiredRole = ''): void {
        $this->recordSecurity(
            $userId,
            'permission_denied',
            'medium',
            "権限不足によるアクセス拒否: {$resource}",
            $resource,
            "Required role: {$requiredRole}"
        );
    }

    /**
     * データエクスポートログの記録
     * @param string $userId ユーザーID
     * @param string $dataType データ種別
     * @param string $format ファイル形式
     * @param int $recordCount レコード数
     */
    public function logDataExport(string $userId, string $dataType, string $format = 'CSV', int $recordCount = 0): void {
        $this->recordSecurity(
            $userId,
            'data_export',
            'medium',
            "データエクスポート: {$dataType} ({$format}, {$recordCount}件)",
            $dataType
        );
    }

    /**
     * エラーログの記録
     * @param string|null $userId ユーザーID
     * @param string $errorMessage エラーメッセージ
     * @param string $pageUrl 発生ページ
     * @param int $httpStatus HTTPステータスコード
     */
    public function logError(?string $userId, string $errorMessage, string $pageUrl = '', int $httpStatus = 500): void {
        $this->recordAccess(
            $userId ?: 'anonymous',
            'error',
            $pageUrl ?: $_SERVER['REQUEST_URI'] ?? '',
            'エラー発生',
            $_SERVER['REQUEST_METHOD'] ?? 'GET',
            null,
            $httpStatus
        );

        if ($userId) {
            $this->recordSecurity(
                $userId,
                'suspicious_access',
                $httpStatus >= 500 ? 'high' : 'medium',
                "アプリケーションエラー: {$errorMessage}"
            );
        }
    }

    /**
     * システム全体からの簡易ログ記録（静的メソッド風）
     * @param PDO $pdo PDO接続
     * @param string $userId ユーザーID
     * @param string $action アクション
     * @param string $description 説明
     */
    public static function quickLog(PDO $pdo, string $userId, string $action, string $description): void {
        try {
            $manager = new self($pdo);
            $manager->recordSecurity($userId, $action, 'low', $description);
        } catch (Exception $e) {
            error_log("LogAuditManager::quickLog エラー: " . $e->getMessage());
        }
    }

    /**
     * ログイン試行回数が制限を超えているか判定
     * @param string $key レートリミットキー
     * @param int $limit 制限回数
     * @param string $intervalSql 時間間隔（SQL形式）
     * @return bool 制限を超えている場合true
     */
    public function isRateLimitExceeded(string $key, int $limit, string $intervalSql): bool {
        try {
            $sql = "
                SELECT COUNT(*) FROM unified_logs 
                WHERE log_type = 'login_attempt' 
                AND access_type = 'login'
                AND event_type = 'login_failure'
                AND JSON_EXTRACT(additional_data, '$.rate_limit_key') = ?
                AND created_at > (NOW() - INTERVAL $intervalSql)
            ";
            
            $st = $this->pdo->prepare($sql);
            $st->execute([$key]);
            return ((int)$st->fetchColumn()) >= $limit;
            
        } catch (Exception $e) {
            error_log("LogAuditManager: レートリミット判定エラー - " . $e->getMessage());
            // エラー時は安全側に倒してfalseを返す
            return false;
        }
    }
}