# newhptldb データベース ビュー・トリガー・関数 ガイド

**作成日:** 2025年10月5日  
**対象データベース:** newhptldb  
**データベースシステム:** MySQL 8.0+ / MariaDB 10.3+

---

## 📚 目次

1. [概要](#概要)
2. [統合ログシステム](#統合ログシステム)
3. [監査トリガー](#監査トリガー)
4. [ビュー一覧](#ビュー一覧)
5. [関数・プロシージャ](#関数プロシージャ)
6. [使用例](#使用例)
7. [メンテナンス・運用](#メンテナンス運用)

---

## 概要

newhptldbデータベースは病院情報管理システムで、包括的な監査ログ機能、アクセス管理、システム運営支援機能を提供します。

### 主要機能
- **統合ログシステム** - 全テーブルの変更を自動記録
- **セキュリティ監査** - ログイン試行、権限変更等を追跡
- **アクセスログ** - ページアクセス、API呼び出しを記録
- **システム管理** - メンテナンス、バージョン管理を支援

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
    department_id varchar(30),
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

## 監査トリガー

### 自動監査機能

すべての主要テーブルに対して、INSERT、UPDATE、DELETE操作を自動的にログ記録するトリガーが設定されています。

#### 対象テーブル一覧

| テーブル名 | 監査対象操作 | 特記事項 |
|-----------|-------------|---------|
| `hospitals` | INSERT, UPDATE, DELETE | 医療機関情報の変更を追跡 |
| `users` | INSERT, UPDATE, DELETE | パスワードハッシュは記録から除外 |
| `contact_details` | INSERT, UPDATE, DELETE | 連絡先情報の変更を追跡 |
| `hospital_staffs` | INSERT, UPDATE, DELETE | 重要人物情報の変更を追跡 |
| `introductions` | INSERT, UPDATE, DELETE | 紹介・逆紹介データの変更を追跡 |
| `maintenances` | INSERT, UPDATE, DELETE | メンテナンス計画の変更を追跡 |
| `messages` | INSERT, UPDATE, DELETE | システム要望・更新情報の変更を追跡 |
| `inquires` | INSERT, UPDATE, DELETE | 問い合わせ情報の変更を追跡 |

#### トリガー命名規則

```
{テーブル名}_{操作}_{audit}
例: hospitals_insert_audit, users_update_audit
```

#### セキュリティ考慮事項

- **パスワードハッシュは記録されません** - `users`テーブルの`password_hash`フィールドは監査ログから除外
- **変更前後の値をJSON形式で保存** - 詳細な変更履歴を確認可能
- **自動的なユーザー特定** - 可能な場合はuser_idを自動設定

---

## ビュー一覧

### 監査・ログ関連ビュー

#### 1. audit_summary
```sql
-- 監査ログの概要統計
SELECT * FROM audit_summary;
```
各テーブルの操作回数と最終操作日時を表示

#### 2. access_summary  
```sql
-- アクセス統計（過去30日）
SELECT * FROM access_summary;
```
日別・アクセスタイプ別の統計情報

#### 3. security_alerts
```sql
-- 高重要度セキュリティアラート
SELECT * FROM security_alerts WHERE severity IN ('high', 'critical');
```
重要なセキュリティイベントを監視

#### 4. user_activity
```sql
-- ユーザーアクティビティ（過去30日）
SELECT * FROM user_activity ORDER BY last_access DESC;
```
ユーザーの活動状況を追跡

### システム運営管理ビュー

#### 5. current_system_status
```sql
-- 現在のシステム状態
SELECT * FROM current_system_status;
```
システムモード（通常/メンテナンス/読み取り専用）を確認

#### 6. current_version
```sql
-- 現在稼働中のバージョン
SELECT * FROM current_version;
```
システムの現行バージョン情報

#### 7. maintenance_schedule
```sql
-- メンテナンス予定一覧
SELECT * FROM maintenance_schedule WHERE date >= CURDATE();
```
今後のメンテナンス予定を表示

#### 8. message_management
```sql
-- メッセージ・要望管理
SELECT * FROM message_management WHERE status = 'open';
```
未対応の要望・メッセージを表示

#### 9. inquire_management
```sql
-- 問い合わせ管理
SELECT * FROM inquire_management WHERE status IN ('open', 'in_progress');
```
対応中・未対応の問い合わせを表示

---

## 関数・プロシージャ

### 1. get_current_version()
```sql
-- 現在のシステムバージョンを取得
SELECT get_current_version();
```

### 2. switch_current_version(new_version_id)
```sql
-- 安全なバージョン切り替え
CALL switch_current_version(5);
```

### 3. escalate_urgent_inquiries()
```sql
-- 緊急問い合わせの自動エスカレーション
CALL escalate_urgent_inquiries();
```

### 4. update_inquire_status(inquire_id, new_status, resolution, assigned_to)
```sql
-- 問い合わせステータス更新
CALL update_inquire_status(123, 'resolved', '解決しました', 'admin001');
```

---

## 使用例

### 監査ログの確認

```sql
-- 特定テーブルの変更履歴を確認
SELECT 
    log_id,
    action_type,
    user_id,
    old_values,
    new_values,
    created_at
FROM unified_logs 
WHERE log_type = 'audit' 
  AND table_name = 'hospitals'
  AND record_id = '1234567890'
ORDER BY created_at DESC;
```

### セキュリティ監視

```sql
-- 失敗ログイン試行の監視
SELECT 
    ip_address,
    COUNT(*) as failed_attempts,
    MAX(created_at) as last_attempt
FROM unified_logs 
WHERE log_type = 'security' 
  AND event_type = 'login_failure'
  AND created_at >= DATE_SUB(NOW(), INTERVAL 1 HOUR)
GROUP BY ip_address
HAVING failed_attempts > 5;
```

### アクセス統計の取得

```sql
-- 人気ページランキング
SELECT 
    page_name,
    COUNT(*) as access_count,
    COUNT(DISTINCT user_id) as unique_users
FROM unified_logs 
WHERE log_type = 'access' 
  AND access_type = 'page_access'
  AND created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)
GROUP BY page_name
ORDER BY access_count DESC
LIMIT 10;
```

### メンテナンス管理

```sql
-- 予定されているメンテナンスの確認
SELECT 
    title,
    date,
    start_time,
    end_time,
    comment
FROM maintenance_schedule
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
- 監査ログは改ざん防止のため、一般ユーザーからは読み取り専用
- パスワード等の機密情報はログに記録されない設計
- 定期的なログの外部バックアップを推奨

### パフォーマンス
- ログテーブルは急速に成長するため、定期的な古いデータの削除が必要
- 大量のトリガー処理があるため、バッチ処理時は一時的にトリガーを無効化することを検討

### 運用
- システムバージョンの変更時は必ず`switch_current_version`プロシージャを使用
- メンテナンスモード切り替え時は事前にユーザーへの通知を実施

---

**最終更新:** 2025年10月5日  
**文書バージョン:** 1.0