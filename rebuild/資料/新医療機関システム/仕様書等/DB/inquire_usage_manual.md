# 問い合わせ機能使用マニュアル

## 概要
システムに関する問い合わせを管理するための機能です。  
バグ報告、機能要望、技術サポートなど、様々な種類の問い合わせを一元管理できます。

---

## 📋 問い合わせ種別

| 種別 | inquiry_type | 用途 | 例 |
|------|-------------|------|---|
| **バグ報告** | `bug_report` | システムの不具合報告 | 画面が表示されない、データが保存されない |
| **機能要望** | `feature_request` | 新機能の追加要望 | 検索機能の追加、レポート出力機能 |
| **技術サポート** | `technical_support` | 操作方法の質問 | ログイン方法、データ入力方法 |
| **一般的な問い合わせ** | `general_inquiry` | その他の質問 | システムの利用条件、仕様について |
| **その他** | `other` | 上記以外 | システム外の相談など |

---

## 🚀 問い合わせの新規登録

### 基本的な問い合わせ登録

```sql
INSERT INTO inquire (
    user_id, inquiry_type, priority, subject, description, 
    category, reporter_email
) VALUES (
    'USER001',                          -- 問い合わせ者のユーザーID
    'bug_report',                       -- 問い合わせ種別
    'high',                            -- 優先度
    'ログイン画面でエラーが発生',         -- 件名
    'ログイン画面でユーザーIDとパスワードを入力してもエラーメッセージが表示され、ログインできません。', -- 詳細
    '認証システム',                      -- カテゴリ
    'user@example.com'                  -- 連絡先メール
);
```

### 機能要望の登録

```sql
INSERT INTO inquire (
    user_id, inquiry_type, priority, subject, description, 
    category, reporter_email
) VALUES (
    'USER002',
    'feature_request',
    'medium',
    'Excel形式でのデータエクスポート機能',
    '医療機関一覧をExcel形式でダウンロードできる機能を追加してほしいです。現在はCSV形式のみですが、Excelで直接開けると便利です。',
    'データ出力',
    'admin@hospital.com'
);
```

### 技術サポートの登録

```sql
INSERT INTO inquire (
    user_id, inquiry_type, priority, subject, description, 
    category, reporter_email
) VALUES (
    'USER003',
    'technical_support',
    'low',
    '新しい医療機関の登録方法',
    '新しい医療機関を追加する手順を教えてください。どの画面から入力できますか？',
    '医療機関管理',
    'support@clinic.jp'
);
```

---

## 📊 問い合わせ状況の管理

### 🔄 ステータス更新

#### 対応開始時
```sql
UPDATE inquire 
SET status = 'in_progress', 
    assigned_to = 'ADMIN01',
    updated_at = NOW()
WHERE inquire_id = 1;
```

#### 解決時
```sql
UPDATE inquire 
SET status = 'resolved',
    resolution = '該当する不具合を修正しました。次回のアップデートで反映されます。',
    resolved_at = NOW(),
    updated_at = NOW()
WHERE inquire_id = 1;
```

#### クローズ時
```sql
UPDATE inquire 
SET status = 'closed',
    updated_at = NOW()
WHERE inquire_id = 1;
```

---

## 🔍 問い合わせ検索・一覧

### 📈 ステータス別一覧

```sql
-- 未対応の問い合わせ
SELECT 
    inquire_id, subject, inquiry_type, priority, 
    reporter_email, created_at
FROM inquire 
WHERE status = 'open'
ORDER BY priority DESC, created_at ASC;
```

### 🔥 緊急度の高い問い合わせ

```sql
SELECT 
    inquire_id, subject, inquiry_type, description,
    reporter_email, created_at
FROM inquire 
WHERE priority IN ('high', 'urgent') 
AND status NOT IN ('resolved', 'closed')
ORDER BY 
    CASE priority 
        WHEN 'urgent' THEN 1 
        WHEN 'high' THEN 2 
    END,
    created_at ASC;
```

### 👤 特定ユーザーの問い合わせ履歴

```sql
SELECT 
    i.inquire_id, i.subject, i.inquiry_type, i.status,
    i.created_at, i.resolved_at
FROM inquire i
WHERE i.user_id = 'USER001'
ORDER BY i.created_at DESC;
```

### 📊 種別別統計

```sql
SELECT 
    inquiry_type,
    COUNT(*) as total_count,
    COUNT(CASE WHEN status = 'resolved' THEN 1 END) as resolved_count,
    COUNT(CASE WHEN status = 'open' THEN 1 END) as open_count,
    AVG(TIMESTAMPDIFF(HOUR, created_at, resolved_at)) as avg_resolution_hours
FROM inquire 
WHERE created_at >= DATE_SUB(NOW(), INTERVAL 30 DAY)
GROUP BY inquiry_type
ORDER BY total_count DESC;
```

---

## 📋 管理者向け機能

### 🔧 担当者割り当て

```sql
-- 担当者を割り当て
UPDATE inquire 
SET assigned_to = 'ADMIN02',
    status = 'in_progress',
    updated_at = NOW()
WHERE inquire_id = 5 
AND status = 'open';
```

### 📝 管理者メモ追加

```sql
-- 内部メモを追加（管理者用）
UPDATE inquire 
SET resolution = CONCAT(
    IFNULL(resolution, ''), 
    '\n\n【管理者メモ】',
    '\n対応予定日: 2025年9月20日',
    '\n担当部署: システム開発チーム'
),
updated_at = NOW()
WHERE inquire_id = 3;
```

### 📈 対応状況レポート

```sql
-- 月次対応状況レポート
SELECT 
    DATE_FORMAT(created_at, '%Y年%m月') as month,
    inquiry_type,
    COUNT(*) as inquiries,
    COUNT(CASE WHEN status = 'resolved' THEN 1 END) as resolved,
    ROUND(
        COUNT(CASE WHEN status = 'resolved' THEN 1 END) * 100.0 / COUNT(*), 
        1
    ) as resolution_rate
FROM inquire 
WHERE created_at >= DATE_SUB(NOW(), INTERVAL 6 MONTH)
GROUP BY DATE_FORMAT(created_at, '%Y-%m'), inquiry_type
ORDER BY month DESC, inquiry_type;
```

---

## 🔔 通知・アラート機能

### ⚠️ 長期未対応問い合わせ

```sql
-- 3日以上未対応の問い合わせ
SELECT 
    inquire_id, subject, inquiry_type, priority,
    reporter_email, 
    DATEDIFF(NOW(), created_at) as days_open
FROM inquire 
WHERE status = 'open' 
AND created_at <= DATE_SUB(NOW(), INTERVAL 3 DAY)
ORDER BY days_open DESC;
```

### 🚨 緊急対応が必要な問い合わせ

```sql
-- 緊急度が高く未対応の問い合わせ
SELECT 
    inquire_id, subject, description, 
    reporter_email, created_at
FROM inquire 
WHERE priority = 'urgent' 
AND status = 'open'
ORDER BY created_at ASC;
```

---

## 📊 便利なビュー（推奨）

### 問い合わせ詳細ビュー

```sql
CREATE VIEW inquire_details AS
SELECT 
    i.inquire_id,
    i.subject,
    i.inquiry_type,
    i.priority,
    i.status,
    i.description,
    i.category,
    u1.user_name as reporter_name,
    i.reporter_email,
    u2.user_name as assigned_name,
    i.resolution,
    i.created_at,
    i.updated_at,
    i.resolved_at,
    CASE 
        WHEN i.resolved_at IS NOT NULL THEN 
            TIMESTAMPDIFF(HOUR, i.created_at, i.resolved_at)
        ELSE NULL 
    END as resolution_hours
FROM inquire i
LEFT JOIN users u1 ON i.user_id = u1.user_id
LEFT JOIN users u2 ON i.assigned_to = u2.user_id;
```

### 未対応問い合わせビュー

```sql
CREATE VIEW pending_inquiries AS
SELECT 
    inquire_id,
    subject,
    inquiry_type,
    priority,
    reporter_email,
    created_at,
    DATEDIFF(NOW(), created_at) as days_pending
FROM inquire 
WHERE status IN ('open', 'in_progress')
ORDER BY 
    CASE priority 
        WHEN 'urgent' THEN 1 
        WHEN 'high' THEN 2 
        WHEN 'medium' THEN 3 
        WHEN 'low' THEN 4 
    END,
    created_at ASC;
```

---

## 💡 運用のベストプラクティス

### ✅ 推奨事項

1. **迅速な初回対応**: 問い合わせ受付後24時間以内に初回返信
2. **適切な分類**: 問い合わせ種別とカテゴリを正確に設定
3. **進捗の透明性**: ステータス更新を定期的に実施
4. **詳細な記録**: 解決方法を詳しく記録してナレッジ蓄積

### ⚠️ 注意点

1. **個人情報の保護**: 問い合わせ内容に個人情報が含まれる場合は適切に管理
2. **優先度の適切な設定**: 緊急度を正しく判断して設定
3. **重複チェック**: 同様の問い合わせがないか確認
4. **フォローアップ**: 解決後の満足度確認

---

## 🛠️ PHPでの実装例

### 問い合わせ登録フォーム処理

```php
class InquireManager {
    private $pdo;
    
    public function __construct($pdo) {
        $this->pdo = $pdo;
    }
    
    // 問い合わせ新規登録
    public function createInquiry($userId, $inquiryType, $priority, $subject, $description, $category = null, $reporterEmail = null) {
        $sql = "INSERT INTO inquire (
            user_id, inquiry_type, priority, subject, description, 
            category, reporter_email, created_at
        ) VALUES (?, ?, ?, ?, ?, ?, ?, NOW())";
        
        $stmt = $this->pdo->prepare($sql);
        $stmt->execute([
            $userId, $inquiryType, $priority, $subject, 
            $description, $category, $reporterEmail
        ]);
        
        return $this->pdo->lastInsertId();
    }
    
    // ステータス更新
    public function updateStatus($inquireId, $status, $assignedTo = null, $resolution = null) {
        $sql = "UPDATE inquire SET 
            status = ?, 
            assigned_to = ?, 
            resolution = ?,
            resolved_at = CASE WHEN ? = 'resolved' THEN NOW() ELSE resolved_at END,
            updated_at = NOW()
        WHERE inquire_id = ?";
        
        $stmt = $this->pdo->prepare($sql);
        return $stmt->execute([$status, $assignedTo, $resolution, $status, $inquireId]);
    }
    
    // 問い合わせ一覧取得
    public function getInquiries($status = null, $limit = 50) {
        $sql = "SELECT * FROM inquire_details";
        $params = [];
        
        if ($status) {
            $sql .= " WHERE status = ?";
            $params[] = $status;
        }
        
        $sql .= " ORDER BY created_at DESC LIMIT ?";
        $params[] = $limit;
        
        $stmt = $this->pdo->prepare($sql);
        $stmt->execute($params);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }
}
```

---

*最終更新: 2025年9月16日*
