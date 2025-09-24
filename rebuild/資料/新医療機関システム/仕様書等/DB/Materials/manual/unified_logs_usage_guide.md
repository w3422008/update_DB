# 統合ログシステム使用ガイド

## 概要
`unified_logs`テーブルは、システム内のすべてのログ情報を一元管理するための統合ログテーブルです。  
4つのログ種別（監査・アクセス・セキュリティ・ログイン試行）をサポートしています。

---

## 📋 ログ種別と用途

| ログ種別 | log_type | 用途 | 主要フィールド |
|---------|----------|------|---------------|
| **監査ログ** | `audit` | データベースの変更履歴追跡 | `table_name`, `action_type`, `old_values`, `new_values` |
| **アクセスログ** | `access` | ページアクセス・API呼び出し記録 | `access_type`, `page_url`, `http_method`, `response_status` |
| **セキュリティログ** | `security` | セキュリティイベント記録 | `event_type`, `severity`, `failure_reason` |
| **ログイン試行ログ** | `login_attempt` | ログイン・ログアウト記録 | `event_type`, `session_id` |

---

## 🔍 1. 監査ログ（audit）

### 📝 データ作成時の記録

```sql
INSERT INTO unified_logs (
    log_type, user_id, table_name, record_id, action_type, 
    new_values, created_at
) VALUES (
    'audit', 'USER001', 'hospitals', 'H001', 'INSERT',
    JSON_OBJECT(
        'hospital_id', 'H001',
        'hospital_name', '川崎医科大学附属病院',
        'status', 'active',
        'bed', 1182
    ),
    NOW()
);
```

### ✏️ データ更新時の記録

```sql
INSERT INTO unified_logs (
    log_type, user_id, table_name, record_id, action_type,
    old_values, new_values, created_at
) VALUES (
    'audit', 'USER001', 'hospitals', 'H001', 'UPDATE',
    JSON_OBJECT('hospital_name', '旧病院名', 'bed', 1000),
    JSON_OBJECT('hospital_name', '新病院名', 'bed', 1182),
    NOW()
);
```

### 🗑️ データ削除時の記録

```sql
INSERT INTO unified_logs (
    log_type, user_id, table_name, record_id, action_type,
    old_values, created_at
) VALUES (
    'audit', 'USER001', 'hospitals', 'H001', 'DELETE',
    JSON_OBJECT(
        'hospital_id', 'H001',
        'hospital_name', '削除された病院',
        'status', 'closed'
    ),
    NOW()
);
```

---

## 🌐 2. アクセスログ（access）

### 📄 ページアクセスの記録

```sql
INSERT INTO unified_logs (
    log_type, user_id, session_id, access_type, page_url, page_name,
    http_method, response_status, response_time_ms, ip_address, 
    user_agent, facility_id, department_id, created_at
) VALUES (
    'access', 'USER001', 'sess_abc123', 'page_access', 
    '/hospitals/list', '医療機関一覧', 'GET', 200, 250,
    '192.168.1.100', 'Mozilla/5.0 (Windows NT 10.0)', 
    'FACILITY01', 'DEPT01', NOW()
);
```

### 🔐 ログイン・ログアウトの記録

```sql
-- ログイン
INSERT INTO unified_logs (
    log_type, user_id, session_id, access_type, ip_address,
    user_agent, facility_id, department_id, description, created_at
) VALUES (
    'access', 'USER001', 'sess_abc123', 'login',
    '192.168.1.100', 'Mozilla/5.0 (Windows NT 10.0)', 
    'FACILITY01', 'DEPT01', 'ユーザーがログインしました', NOW()
);

-- ログアウト
INSERT INTO unified_logs (
    log_type, user_id, session_id, access_type, ip_address,
    description, created_at
) VALUES (
    'access', 'USER001', 'sess_abc123', 'logout',
    '192.168.1.100', 'ユーザーがログアウトしました', NOW()
);
```

### 📁 ファイルダウンロード・アップロードの記録

```sql
-- ダウンロード
INSERT INTO unified_logs (
    log_type, user_id, session_id, access_type, page_url,
    description, ip_address, additional_data, created_at
) VALUES (
    'access', 'USER001', 'sess_abc123', 'download',
    '/hospitals/export/csv', 'CSV形式で医療機関データをダウンロード',
    '192.168.1.100',
    JSON_OBJECT('file_name', 'hospitals_2025.csv', 'file_size', 15680),
    NOW()
);
```

---

## 🛡️ 3. セキュリティログ（security）

### ❌ ログイン失敗の記録

```sql
INSERT INTO unified_logs (
    log_type, user_id, event_type, severity, description,
    ip_address, user_agent, failure_reason, created_at
) VALUES (
    'security', 'USER001', 'login_failure', 'medium',
    'パスワード認証に失敗しました', '192.168.1.100',
    'Mozilla/5.0 (Windows NT 10.0)', 'パスワードが正しくありません', NOW()
);
```

### 🚫 権限違反の記録

```sql
INSERT INTO unified_logs (
    log_type, user_id, event_type, severity, description,
    target_resource, ip_address, created_at
) VALUES (
    'security', 'USER002', 'permission_denied', 'high',
    '管理者権限が必要な操作へのアクセスを拒否',
    '/admin/users', '192.168.1.101', NOW()
);
```

### 🔒 アカウントロックの記録

```sql
INSERT INTO unified_logs (
    log_type, user_id, event_type, severity, description,
    ip_address, additional_data, created_at
) VALUES (
    'security', 'USER003', 'account_lock', 'critical',
    '連続ログイン失敗によりアカウントをロックしました',
    '192.168.1.102',
    JSON_OBJECT('failed_attempts', 5, 'lock_duration_minutes', 30),
    NOW()
);
```

### 🔄 パスワード変更の記録

```sql
INSERT INTO unified_logs (
    log_type, user_id, event_type, severity, description,
    ip_address, created_at
) VALUES (
    'security', 'USER001', 'password_change', 'low',
    'ユーザーがパスワードを変更しました',
    '192.168.1.100', NOW()
);
```

---

## 🔑 4. ログイン試行ログ（login_attempt）

### ✅ 成功ログイン

```sql
INSERT INTO unified_logs (
    log_type, user_id, session_id, event_type, description,
    ip_address, user_agent, additional_data, created_at
) VALUES (
    'login_attempt', 'USER001', 'sess_def456', 'login_success',
    'ユーザーが正常にログインしました',
    '192.168.1.100', 'Mozilla/5.0 (Windows NT 10.0)',
    JSON_OBJECT('login_method', 'password', 'remember_me', true),
    NOW()
);
```

### ❌ 失敗ログイン

```sql
INSERT INTO unified_logs (
    log_type, user_id, session_id, event_type, description,
    ip_address, user_agent, failure_reason, created_at
) VALUES (
    'login_attempt', 'USER001', 'sess_ghi789', 'login_failure',
    'ログイン試行が失敗しました',
    '192.168.1.100', 'Mozilla/5.0 (Windows NT 10.0)',
    'ユーザーID又はパスワードが間違っています', NOW()
);
```

---

## 🔍 ログ検索・分析クエリ

### 📊 特定ユーザーの最近のアクティビティ

```sql
SELECT 
    log_type, action_type, access_type, event_type,
    description, created_at
FROM unified_logs 
WHERE user_id = 'USER001' 
AND created_at >= DATE_SUB(NOW(), INTERVAL 24 HOUR)
ORDER BY created_at DESC;
```

### 🚨 セキュリティアラート

```sql
SELECT 
    user_id, event_type, severity, description, 
    ip_address, created_at
FROM unified_logs 
WHERE log_type = 'security' 
AND severity IN ('high', 'critical')
AND created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)
ORDER BY created_at DESC;
```

### 📈 アクセス統計

```sql
SELECT 
    DATE(created_at) as access_date,
    access_type,
    COUNT(*) as access_count,
    COUNT(DISTINCT user_id) as unique_users
FROM unified_logs 
WHERE log_type = 'access'
AND created_at >= DATE_SUB(NOW(), INTERVAL 30 DAY)
GROUP BY DATE(created_at), access_type
ORDER BY access_date DESC;
```

### 🕵️ 監査履歴（特定テーブル）

```sql
SELECT 
    action_type, user_id, record_id,
    old_values, new_values, created_at
FROM unified_logs 
WHERE log_type = 'audit' 
AND table_name = 'hospitals' 
AND record_id = 'H001'
ORDER BY created_at DESC;
```

---

## 📋 利用可能なビュー

システムには以下の便利なビューが用意されています：

### 📊 audit_summary
監査ログの概要統計

```sql
SELECT * FROM audit_summary;
```

### 📈 access_summary  
アクセスログの統計（過去30日間）

```sql
SELECT * FROM access_summary;
```

### 🚨 security_alerts
重要度の高いセキュリティイベント

```sql
SELECT * FROM security_alerts;
```

### 👥 user_activity
ユーザーのアクティビティ統計

```sql
SELECT * FROM user_activity;
```

### 🔐 login_attempt_summary
ログイン試行の統計

```sql
SELECT * FROM login_attempt_summary;
```

---

## 💡 使用上のベストプラクティス

### ✅ 推奨事項

1. **適切なログ種別の選択**: 目的に応じて正しい`log_type`を使用
2. **必須フィールドの入力**: `user_id`, `ip_address`は可能な限り記録
3. **JSONデータの活用**: 構造化データは`additional_data`フィールドを活用
4. **セキュリティレベルの適切な設定**: `severity`フィールドを適切に設定

### ⚠️ 注意事項

1. **個人情報の保護**: パスワードなどの機密情報は記録しない
2. **ログサイズの管理**: 定期的な古いログの削除・アーカイブを検討
3. **パフォーマンス**: 大量ログ検索時はインデックスを活用
4. **一貫性**: 同じ種類のイベントは統一されたフォーマットで記録

---

## 🛠️ PHPでの実装例

### 汎用ログ記録関数

```php
class UnifiedLogger {
    private $pdo;
    
    public function __construct($pdo) {
        $this->pdo = $pdo;
    }
    
    // アクセスログ記録
    public function logAccess($userId, $sessionId, $accessType, $pageUrl = null, $pageName = null) {
        $sql = "INSERT INTO unified_logs (
            log_type, user_id, session_id, access_type, page_url, page_name,
            http_method, ip_address, user_agent, created_at
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())";
        
        $this->pdo->prepare($sql)->execute([
            'access', $userId, $sessionId, $accessType, $pageUrl, $pageName,
            $_SERVER['REQUEST_METHOD'] ?? 'UNKNOWN',
            $_SERVER['REMOTE_ADDR'] ?? '0.0.0.0',
            $_SERVER['HTTP_USER_AGENT'] ?? 'Unknown'
        ]);
    }
    
    // セキュリティログ記録
    public function logSecurity($userId, $eventType, $severity, $description, $failureReason = null) {
        $sql = "INSERT INTO unified_logs (
            log_type, user_id, event_type, severity, description, 
            failure_reason, ip_address, user_agent, created_at
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, NOW())";
        
        $this->pdo->prepare($sql)->execute([
            'security', $userId, $eventType, $severity, $description,
            $failureReason,
            $_SERVER['REMOTE_ADDR'] ?? '0.0.0.0',
            $_SERVER['HTTP_USER_AGENT'] ?? 'Unknown'
        ]);
    }
}
```

---

*最終更新: 2025年9月16日*
