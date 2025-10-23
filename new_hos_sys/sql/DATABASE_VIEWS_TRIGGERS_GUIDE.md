# newhptldb データベース ビュー・トリガー・関数 ガイド

**作成日:** 2025年10月5日  
**対象データベース:** newhptldb  
**データベースシステム:** MySQL 8.0+ / MariaDB 10.3+

---

## 📚 目次

1. [概要](#概要)
2. [統合ログシステム](#統合ログシステム)
3. [ビュー一覧](#ビュー一覧)
4. [関数・プロシージャ](#関数プロシージャ)
5. [使用例](#使用例)
6. [メンテナンス・運用](#メンテナンス運用)

---

## 概要

newhptldbデータベースは病院情報管理システムで、包括的な監査ログ機能、アクセス管理、システム運営支援機能を提供します。

### 主要機能
- **統合ログシステム** - 全テーブルの変更記録用テーブル構造を提供
- **ビューシステム** - システム運営支援、ログ分析用ビューを提供
- **関数・プロシージャ** - システム管理用の基本機能を提供

---

## 統合ログシステム

### unified_logs テーブル構造

すべてのログ情報を一元管理するテーブルです。

```sql
CREATE TABLE unified_logs (
    log_id bigint(20) PRIMARY KEY AUTO_INCREMENT,
    log_type enum('audit','login_attempt','access','security') NOT NULL,
    user_id varchar(8),
    session_id varchar(64),
    
    -- 監査ログ用フィールド
    table_name varchar(50),
    record_id varchar(50),
    action_type enum('INSERT','UPDATE','DELETE'),
    old_values json,
    new_values json,
    
    -- アクセスログ用フィールド
    access_type enum('login','logout','page_access','api_access','download','upload','error'),
    page_url varchar(500),
    page_name varchar(100),
    
    -- セキュリティログ用フィールド
    event_type enum('login_success','login_failure','password_change','account_lock','permission_denied','suspicious_access','data_export','admin_access'),
    severity enum('low','medium','high','critical') DEFAULT 'medium',
    
    -- 共通フィールド
    description text,
    ip_address varchar(45),
    user_agent text,
    facility_id varchar(30),
    department_id varchar(50),
    created_at datetime DEFAULT CURRENT_TIMESTAMP
);
```

### ログタイプ別用途

| ログタイプ | 用途 | 主要フィールド |
|-----------|------|---------------|
| `audit` | データベース変更記録 | table_name, action_type, old_values, new_values |
| `login_attempt` | ログイン試行記録 | event_type, ip_address, failure_reason |
| `access` | ページ・API アクセス | access_type, page_url, response_status |
| `security` | セキュリティイベント | event_type, severity, target_resource |

---

## ビュー一覧

### システム運営管理ビュー

#### 1. current_system_status
```sql
-- 現在のシステム状態
SELECT * FROM current_system_status;
```
システムモード（通常/メンテナンス/読み取り専用）を確認

#### 2. current_version
```sql
-- 現在稼働中のバージョン
SELECT * FROM current_version;
```
システムの現行バージョン情報

#### 3. maintenance_schedule
```sql
-- メンテナンス予定一覧
SELECT * FROM maintenance_schedule WHERE date >= CURDATE();
```
今後のメンテナンス予定を表示

#### 4. message_management
```sql
-- メッセージ・要望管理
SELECT * FROM message_management WHERE status = 'open';
```
未対応の要望・メッセージを表示

#### 5. inquire_management
```sql
-- 問い合わせ管理
SELECT * FROM inquire_management WHERE status IN ('open', 'in_progress');
```
対応中・未対応の問い合わせを表示

#### 6. audit_summary
```sql
-- 監査ログの概要統計
SELECT * FROM audit_summary;
```
各テーブルの操作回数と最終操作日時を表示

#### 7. access_summary  
```sql
-- アクセス統計（過去30日）
SELECT * FROM access_summary;
```
日別・アクセスタイプ別の統計情報

#### 8. security_alerts
```sql
-- 高重要度セキュリティアラート
SELECT * FROM security_alerts WHERE severity IN ('high', 'critical');
```
重要なセキュリティイベントを監視

#### 9. user_activity
```sql
-- ユーザーアクティビティ（過去30日）
SELECT * FROM user_activity ORDER BY last_access DESC;
```
ユーザーの活動状況を追跡

#### 10. version_statistics
```sql
-- バージョン管理統計
SELECT * FROM version_statistics;
```
システムバージョンと関連メッセージの統計

#### 11. inquire_statistics
```sql
-- 問い合わせ統計
SELECT * FROM inquire_statistics;
```
問い合わせの統計情報（過去30日間）

#### 12. system_usage_stats
```sql
-- システム利用統計
SELECT * FROM system_usage_stats;
```
システム利用統計（過去30日間）

---

## 関数・プロシージャ

### 1. get_current_version()
```sql
-- 現在のシステムバージョンを取得
SELECT get_current_version();
```

### 2. update_inquire_status(inquire_id, new_status, resolution, assigned_to)
```sql
-- 問い合わせステータス更新
CALL update_inquire_status(123, 'resolved', '解決しました', 'admin001');
```

---

## 使用例

### ログテーブルの確認

```sql
-- 統合ログテーブルの内容確認
SELECT 
    log_id,
    log_type,
    user_id,
    description,
    created_at
FROM unified_logs 
ORDER BY created_at DESC
LIMIT 20;
```

### システム運営管理

```sql
-- 現在のシステムバージョン確認
SELECT get_current_version();

-- メンテナンス予定の確認
SELECT * FROM maintenance_schedule WHERE date >= CURDATE();

-- 未対応の問い合わせ確認
SELECT * FROM inquire_management WHERE status = 'open';
```

### ユーザー管理

```sql
-- アクティブユーザーリスト
SELECT 
    u.user_id,
    u.user_name,
    u.role,
    d.department_name,
    f.facility_name
FROM users u
JOIN kawasaki_university_departments d ON u.department_id = d.department_id
JOIN kawasaki_university_facilities f ON d.facility_id = f.facility_id
WHERE u.is_active = 1;
```
WHERE date BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 7 DAY)
ORDER BY date, start_time;
```

---

## メンテナンス・運用

### 定期メンテナンス推奨事項

#### 1. ログの定期削除
```sql
-- 1年以上古いログの削除（例）
DELETE FROM unified_logs 
WHERE created_at < DATE_SUB(NOW(), INTERVAL 1 YEAR)
  AND log_type NOT IN ('audit'); -- 監査ログは除外

-- 監査ログは3年保持（例）
DELETE FROM unified_logs 
WHERE created_at < DATE_SUB(NOW(), INTERVAL 3 YEAR)
  AND log_type = 'audit';
```

#### 2. インデックスの最適化
```sql
-- 統計情報の更新
ANALYZE TABLE unified_logs;

-- インデックスの再構築（必要に応じて）
OPTIMIZE TABLE unified_logs;
```

#### 3. システム状態の監視
```sql
-- システム状態の定期確認
SELECT 
    system_mode,
    status_message,
    changed_by,
    created_at
FROM current_system_status;
```

### パフォーマンス最適化

#### 1. ログテーブルのパーティション化（大規模運用時）
```sql
-- 月別パーティション化の例
ALTER TABLE unified_logs 
PARTITION BY RANGE (YEAR(created_at) * 100 + MONTH(created_at)) (
    PARTITION p202410 VALUES LESS THAN (202411),
    PARTITION p202411 VALUES LESS THAN (202412),
    PARTITION p202412 VALUES LESS THAN (202501)
);
```

#### 2. インデックス戦略
- `log_type`, `created_at`の複合インデックス
- `user_id`, `session_id`での検索用インデックス
- `table_name`, `record_id`での監査ログ検索用インデックス

### バックアップ戦略

```sql
-- 監査ログの定期バックアップ
CREATE TABLE unified_logs_backup_202410 AS
SELECT * FROM unified_logs 
WHERE log_type = 'audit' 
  AND created_at >= '2024-10-01' 
  AND created_at < '2024-11-01';
```

---

## 注意事項

### セキュリティ
- データベースアクセスは適切な権限管理を実施
- パスワードハッシュ等の機密情報は適切に保護
- 定期的なデータベースバックアップを推奨

### パフォーマンス
- ログテーブルは時間とともに成長するため、適切な保存期間設定を検討
- インデックスが適切に設定されているかを定期的に確認

### 運用
- システムバージョン管理は`system_versions`テーブルで一元管理
- メンテナンス計画は事前にユーザーへの通知を実施
- 問い合わせ対応は`update_inquire_status`プロシージャで統一的に管理

---

**最終更新:** 2025年10月18日  
**文書バージョン:** 1.2