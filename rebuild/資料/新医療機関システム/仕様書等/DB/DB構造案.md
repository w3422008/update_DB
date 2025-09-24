# DB案 

### 1. 医療機関基本情報系

#### `hospitals` テーブル（医療機関基本情報）
医療機関の基本情報を格納するメインテーブル

| フィールド名 | データ型 | 制約 | 説明 |
|-------------|----------|------|------|
| hospital_id | varchar(10) | PRIMARY KEY | 医療機関コード |
| hospital_type_id | varchar(11) | FOREIGN KEY | 病院区分ID |
| hospital_name | varchar(100) | NOT NULL | 医療機関名 |
| status | enum('active','closed') | DEFAULT 'active' | 運営状況 |
| bed_count | int(11) | DEFAULT 0 | 許可病床数 |
| has_pt | boolean | DEFAULT false | 理学療法士在籍フラグ |
| has_ot | boolean | DEFAULT false | 作業療法士在籍フラグ |
| has_st | boolean | DEFAULT false | 言語聴覚療法士在籍フラグ |
| notes | text | NULL | 備考（基本情報） |
| created_at | datetime | DEFAULT CURRENT_TIMESTAMP | 作成日時 |
| updated_at | datetime | DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP | 更新日時 |

#### `hospital_types` テーブル（病院区分マスタ）
病院の種別を管理するマスタテーブル
(病院、特定機能病院、など)

| フィールド名 | データ型 | 制約 | 説明 |
|-------------|----------|------|------|
| type_id | varchar(11) | PRIMARY KEY NOT NULL | 病院区分ID |
| type_name | varchar(50) | NOT NULL | 区分名 |
| is_active | boolean | DEFAULT true | 有効フラグ |
| display_order | int(11) | NOT NULL DEFAULT 0 | 表示順序 |

#### `addresses` テーブル（住所情報）
医療機関の住所情報を管理

| フィールド名 | データ型 | 制約 | 説明 |
|-------------|----------|------|------|
| address_id | int(11) | PRIMARY KEY AUTO_INCREMENT | 住所ID |
| hospital_id | varchar(10) | FOREIGN KEY NOT NULL | 医療機関コード |
| area_id | int(11) | FOREIGN KEY | 地区コード（areaテーブル参照） |
| postal_code | varchar(7) | NULL | 郵便番号 |
| street_number | varchar(200) | NULL | 番地 |
| full_address | varchar(400) | NULL | 完全住所 |

#### `contact_details` テーブル（連絡先情報）
医療機関の連絡先情報を管理

| フィールド名 | データ型 | 制約 | 説明 |
|-------------|----------|------|------|
| contact_id | int(11) | PRIMARY KEY AUTO_INCREMENT | 連絡先ID |
| hospital_id | varchar(10) | FOREIGN KEY NOT NULL | 医療機関コード |
| phone | varchar(20) | NULL | 電話番号 |
| fax | varchar(20) | NULL | FAX番号 |
| email | varchar(254) | NULL | メールアドレス |
| website | varchar(500) | NULL | ウェブサイト |

#### `hospitals_ward_types`(病棟種類テーブル)
病棟種類を持つかどうかを管理
| フィールド名 | データ型 | 制約 | 説明 |
|-------------|----------|------|------|
| hospital_id | varchar(10) | PRIMARY KEY(複合主キー) | 医療機関コード |
| ward_id | varchar(10) | PRIMARY KEY(複合主キー) | 病棟種類ID |

#### `ward_types`(病棟種類マスタ)
病棟種類名を管理する
| フィールド名 | データ型 | 制約 | 説明 |
|-------------|----------|------|------|
| ward_id | varchar(10) | PRIMARY KEY NOT NULL | 病棟種類ID |
| ward_name | varchar(20) | NOT NULL | 病棟名 |
| is_active | boolean | DEFAULT true | 有効フラグ |
| display_order | int(11) | NOT NULL DEFAULT 0 | 表示順序 |

### 2. 人員情報系

#### `hospital_staffs` テーブル（病院スタッフ情報）
理事長、病院長などの重要人物情報を管理

| フィールド名 | データ型 | 制約 | 説明 |
|-------------|----------|------|------|
| staff_id | int(11) | PRIMARY KEY AUTO_INCREMENT | スタッフ管理ID |
| hospital_id | varchar(10) | FOREIGN KEY NOT NULL | 医療機関コード |
| role_type | enum('chairman','director') | NOT NULL | 役職種別(chairman：理事長、director：病院長) |
| staff_name | varchar(60) | NOT NULL | 氏名 |
| specialty | varchar(50) | NULL | 専門分野 |
| graduation_year | year(4) | NULL | 卒業年度 |
| alma_mater | varchar(100) | NULL | 出身校 |
| notes | text | NULL | 備考 |

### 3. 診療時間系

#### `consultation_hours` テーブル（診療時間）
医療機関の診療時間を管理

| フィールド名 | データ型 | 制約 | 説明 |
|-------------|----------|------|------|
| hospital_id | varchar(10) | PRIMARY KEY(複合主キー) | 医療機関コード |
| day_of_week | enum('monday','tuesday','wednesday','thursday','friday','saturday','sunday','holiday') | PRIMARY KEY(複合主キー) | 曜日 |
| period | enum('AM','PM','AM_PM') | PRIMARY KEY(複合主キー) | 時間帯 |
| is_available | boolean | DEFAULT true | 診療可否 |
| start_time | time | NULL | 開始時間 |
| end_time | time | NULL | 終了時間 |
| notes | varchar(200) | NULL | 備考 |

### 4. 診療科系

#### `medical_departments` テーブル（診療科マスタ）
診療科の分類と詳細を管理

| フィールド名 | データ型 | 制約 | 説明 |
|-------------|----------|------|------|
| department_id | varchar(10) | PRIMARY KEY NOT NULL | 診療科コード |
| department_name | varchar(100) | NOT NULL | 診療科名 |
| category | varchar(100) | NOT NULL | 診療科カテゴリ名 |
| is_active | boolean | DEFAULT true | 有効フラグ |
| display_order | int(11) | NOT NULL DEFAULT 0 | 表示順序 |

#### `hospital_departments` テーブル（病院診療科関連）
医療機関が対応している診療科を管理

| フィールド名 | データ型 | 制約 | 説明 |
|-------------|----------|------|------|
| hospital_id | varchar(10) | PRIMARY KEY(複合主キー) FOREIGN KEY | 医療機関コード |
| department_id | varchar(10) | PRIMARY KEY(複合主キー) FOREIGN KEY | 診療科ID |

### 5. 診療内容系

#### `medical_services` テーブル（診療内容マスタ）
提供可能な医療サービスを管理

| フィールド名 | データ型 | 制約 | 説明 |
|-------------|----------|------|------|
| service_id | varchar(10) | PRIMARY KEY(複合主キー) NOT NULL | 診療内容コード |
| service_division | varchar(100) | PRIMARY KEY(複合主キー) NOT NULL | 診療区分 |
| service_category | varchar(100) | NULL | 診療部門 |
| service_name | varchar(300) | NOT NULL | 診療内容名 |
| is_active | boolean | DEFAULT true | 有効フラグ |
| display_order | int(11) | NOT NULL DEFAULT 0 | 表示順序 |

#### `hospital_services` テーブル（病院診療内容関連）
医療機関が提供している診療内容を管理

| フィールド名 | データ型 | 制約 | 説明 |
|-------------|----------|------|------|
| hospital_id | varchar(10) | PRIMARY KEY(複合主キー) FOREIGN KEY | 医療機関コード |
| service_id | varchar(10) | PRIMARY KEY(複合主キー) FOREIGN KEY | 診療内容コード |
| service_division | varchar(100) | PRIMARY KEY(複合主キー) FOREIGN KEY | 診療区分 |

#### `clinical_pathway_hospitals`テーブル（連携パスと医療機関を接続）
地域連携クリニカルパスの存在有無を管理
| フィールド名 | データ型 | 制約 | 説明 |
|-------------|----------|------|------|
| hospital_id | varchar(10) | PRIMARY KEY(複合主キー) | 医療機関コード |
| clinical_pathway_id | varchar(10) | PRIMARY KEY(複合主キー) | 連携パスID |

#### `clinical_pathways`テーブル（連携パスマスタ）
地域連携クリニカルパス名を管理
detail/control/relation_control.phpファイルに内容あり
（`入退院支援連携先病院`,`脳卒中パス`,`大腿骨パス`,`心筋梗塞・心不全パス`,`胃がんパス`,`大腸がんパス`,`乳がんパス`,`肺がんパス`,`肝がんパス`が存在）
| フィールド名 | データ型 | 制約 | 説明 |
|-------------|----------|------|------|
| clinical_pathway_id | varchar(10) | PRIMARY KEY | 連携パスID |
| path_name | varchar(30) | NOT NULL | 連携パス名 |
| is_active | boolean | DEFAULT true | 有効フラグ |
| display_order | int(11) | NOT NULL DEFAULT 0 | 表示順序 |

### 6. 地域・エリア系

#### `areas` テーブル（地域情報）
地域マスタ情報（旧areaテーブルの改良版）

| フィールド名 | データ型 | 制約 | 説明 |
|-------------|----------|------|------|
| area_id | int(11) | PRIMARY KEY NOT NULL | 地区コード |
| secondary_medical_area_name | varchar(50) | NULL | 二次医療圏名 |
| prefecture | varchar(10) | NULL | 都道府県 |
| city | varchar(30) | NULL | 市 |
| ward | varchar(20) | NULL | 区 |
| town | varchar(30) | NULL | 町 |
| is_active | boolean | DEFAULT true | 有効フラグ |
| display_order | int(11) | NOT NULL DEFAULT 0 | 表示順序 |

### 7. 外部連携系

#### `carna_connects` テーブル（カルナコネクト情報）`既存テーブル`

| フィールド名 | データ型 | 制約 | 説明 |
|-------------|----------|------|------|
| hospital_id | varchar(10) | PRIMARY KEY | 医療機関コード |
| is_deleted | boolean | DEFAULT false | 削除フラグ |

### 8. 履歴・ログ系

#### `unified_logs` テーブル（統合ログ）
システム内のすべてのログ情報を一元管理する統合ログテーブル
4つのログ種別（監査・アクセス・セキュリティ・ログイン試行）をサポート

| フィールド名 | データ型 | 制約 | 説明 |
|-------------|----------|------|------|
| log_id | bigint(20) | PRIMARY KEY AUTO_INCREMENT | ログID |
| log_type | enum('audit','login_attempt','access','security') | NOT NULL | ログ種別 |
| user_id | varchar(8) | FOREIGN KEY | ユーザーID |
| session_id | varchar(64) | NULL | セッションID |
| **監査ログ用フィールド** |  |  |  |
| table_name | varchar(50) | NULL | 対象テーブル名（監査ログ用） |
| record_id | varchar(50) | NULL | 対象レコードID（監査ログ用） |
| action_type | enum('INSERT','UPDATE','DELETE') | NULL | 操作種別（監査ログ用） |
| old_values | json | NULL | 変更前データ（監査ログ用） |
| new_values | json | NULL | 変更後データ（監査ログ用） |
| **アクセスログ用フィールド** |  |  |  |
| access_type | enum('login','logout','page_access','api_access','download','upload','error') | NULL | アクセス種別 |
| page_url | varchar(500) | NULL | アクセスページURL |
| page_name | varchar(100) | NULL | ページ名 |
| http_method | enum('GET','POST','PUT','DELETE','PATCH') | NULL | HTTPメソッド |
| request_params | json | NULL | リクエストパラメータ |
| response_status | int(11) | NULL | レスポンスステータス |
| response_time_ms | int(11) | NULL | レスポンス時間（ミリ秒） |
| referer | varchar(500) | NULL | リファラー |
| **セキュリティログ用フィールド** |  |  |  |
| event_type | enum('login_success','login_failure','password_change','account_lock','permission_denied','suspicious_access','data_export','admin_access') | NULL | セキュリティイベント種別 |
| severity | enum('low','medium','high','critical') | DEFAULT 'medium' | 重要度 |
| target_resource | varchar(200) | NULL | 対象リソース |
| failure_reason | varchar(200) | NULL | 失敗理由 |
| **共通フィールド** |  |  |  |
| description | text | NULL | イベント詳細・説明 |
| ip_address | varchar(45) | NULL | IPアドレス |
| additional_data | json | NULL | 追加データ・その他情報 |
| created_at | datetime | DEFAULT CURRENT_TIMESTAMP | ログ記録日時 |

### 9. システム管理系

#### `users` テーブル（システム利用ユーザー）
システム利用者の情報を管理

| フィールド名 | データ型 | 制約 | 説明 |
|-------------|----------|------|------|
| user_id | varchar(8) | PRIMARY KEY | ユーザーID |
| user_name | varchar(50) | NOT NULL | ユーザー名 |
| password_hash | varchar(255) | NOT NULL | パスワードハッシュ |
| facility_id | varchar(20) | NOT NULL | 所属施設ID |
| department_id | varchar(20) | NOT NULL | 所属部署ID |
| role | enum('admin','editor','viewer') | DEFAULT 'viewer' | 権限レベル |
| is_active | boolean | DEFAULT true | アカウント有効フラグ |
| last_login_at | datetime | NULL | 最終ログイン日時 |
| created_at | datetime | DEFAULT CURRENT_TIMESTAMP | 作成日時 |
| updated_at | datetime | DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP | 更新日時 |

#### `kawasaki_university_facilities` テーブル（マスタ）
川崎学園の病院情報を管理
(附属病院、総合医療センター、高齢者医療センター)

| フィールド名 | データ型 | 制約 | 説明 |
|-------------|----------|------|------|
| facility_id | varchar(20) | PRIMARY KEY | 所属施設ID |
| facility_name | varchar(50) | NOT NULL | 施設名 |
| formal_name | varchar(60) | NOT NULL | 正式名称 |
| abbreviation | varchar(50) | NULL | 略称 |
| is_active | boolean | DEFAULT true | 有効フラグ |
| display_order | int(11) | NOT NULL DEFAULT 0 | 表示順序 |

#### `kawasaki_university_departments` テーブル（マスタ）
川崎学園の部署情報を管理

| フィールド名 | データ型 | 制約 | 説明 |
|-------------|----------|------|------|
| department_id | varchar(20) | PRIMARY KEY | 部署ID |
| department_name | varchar(50) | NOT NULL | 部署名 |
| is_active | boolean | DEFAULT true | 有効フラグ |
| display_order | int(11) | NOT NULL DEFAULT 0 | 表示順序 |

### 10. その他統合テーブル
#### `introductions` テーブル（紹介データ）
医療機関間の紹介情報を管理

| フィールド名 | データ型 | 制約 | 説明 |
|-------------|----------|------|------|
| hospital_id | varchar(10) | PRIMARY KEY(複合主キー) | 医療機関コード |
| user_id | varchar(8) | PRIMARY KEY(複合主キー) | ユーザーID（これより附属病院、総合医療センターの情報を取得） |
| year | year | PRIMARY KEY(複合主キー) | 年度 |
| date | date | PRIMARY KEY(複合主キー) | 診療日 |
| department_name | varchar(30) | PRIMARY KEY(複合主キー) | 診療科 |
| intro_type | enum('intro','invers_intro') | PRIMARY KEY(複合主キー) DEFAULT 'intro' | 紹介・逆紹介判定 |
| department_id | varchar(10) | NULL | 診療科コード |
| intro_count | int(11) | NOT NULL | 紹介・逆紹介件数 |

#### `training` テーブル（兼業データ）
複数の医療機関へ研修・勤務している人物を管理

| フィールド名 | データ型 | 制約 | 説明 |
|-------------|----------|------|------|
| hospital_id | varchar(10) | PRIMARY KEY(複合主キー) | 医療機関コード |
| year | year | PRIMARY KEY(複合主キー) | 年度 |
| user_id | varchar(8) | PRIMARY KEY(複合主キー) | ユーザーID（これより附属病院、総合医療センターの情報を取得） |
| department | varchar(60) | PRIMARY KEY(複合主キー) | 診療科 |
| staff_name | varchar(60) | NOT NULL | 氏名 |
| position_id | varchar(20) | FOREIGN KEY | 職名 |
| start_date | date | PRIMARY KEY(複合主キー) | 診療支援開始日 |
| end_date | date | NULL | 診療支援終了日 |
| date | varchar(300) | NULL | 日付 |
| diagnostic_aid | varchar(50) | NULL | 診療支援区分 |

#### `positions` テーブル（職名マスタ）
職業のマスタテーブル

| フィールド名 | データ型 | 制約 | 説明 |
|-------------|----------|------|------|
| position_id | varchar(20) | PRIMARY KEY | 診療科 |
| position_name | varchar(60) | NOT NULL | 氏名 |
| is_active | boolean | DEFAULT true | 有効フラグ |
| display_order | int(11) | NOT NULL DEFAULT 0 | 表示順序 |

#### `contacts` テーブル（コンタクト履歴）
医療機関同士のコンタクト履歴を保管

| フィールド名 | データ型 | 制約 | 説明 |
|-------------|----------|------|------|
| hospital_id | varchar(10) | PRIMARY KEY(複合主キー) | 医療機関コード |
| year | year(4) | PRIMARY KEY(複合主キー) | 年度 |
| user_id | varchar(8) | PRIMARY KEY(複合主キー) | ユーザーID（これより附属病院、総合医療センターの情報を取得） |
| date | date | PRIMARY KEY(複合主キー) | 日付 |
| method | varchar(50) | PRIMARY KEY(複合主キー) | 方法（来院、訪問、オンライン等） |
| external_contact_name | varchar(10) | NOT NULL | 連携機関対応者氏名 |
| external_department | varchar(50) | NULL | 連携機関対応者部署 |
| external_position | varchar(50) | NULL | 連携機関対応者役職 |
| external_additional_participants | varchar(100) | NULL | 連携機関対応人数・氏名 |
| internal_contact_name | varchar(10) | NOT NULL | 当院対応者氏名 |
| internal_department | varchar(50) | NULL | 当院対応者所属 |
| internal_additional_participants | varchar(100) | NULL | 当院対応人数・氏名 |
| detail | varchar(100) | NULL | 内容 |
| notes | varchar(100) | NULL | 備考 |
| data_department | varchar(50) | NULL | データ作成部署 |

#### `inquires` テーブル（問い合わせ）
システムに関する問い合わせ内容を管理

| フィールド名 | データ型 | 制約 | 説明 |
|-------------|----------|------|------|
| inquire_id | bigint(20) | PRIMARY KEY AUTO_INCREMENT | 問い合わせID |
| user_id | varchar(8) | FOREIGN KEY | 問い合わせ者ユーザーID |
| priority | enum('general','urgent') | DEFAULT 'general' | 優先度 |
| status | enum('open','in_progress','resolved','closed') | DEFAULT 'open' | 対応状況 |
| description | text | NOT NULL | 問い合わせ内容 |
| assigned_to | varchar(8) | FOREIGN KEY | 担当者ユーザーID |
| resolution | text | NULL | 解決方法・回答内容 |
| created_at | datetime | DEFAULT CURRENT_TIMESTAMP | 問い合わせ日時 |
| updated_at | datetime | DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP | 最終更新日時 |
| resolved_at | datetime | NULL | 解決日時 |

### 11. システム運営管理系

#### `maintenance_notifications` テーブル（メンテナンス通知管理）
システムメンテナンスの事前通知と実行中通知を統合管理

| フィールド名 | データ型 | 制約 | 説明 |
|-------------|----------|------|------|
| notification_id | int(11) | PRIMARY KEY AUTO_INCREMENT | 通知ID |
| notification_type | enum('scheduled','in_progress','completed','cancelled') | NOT NULL | 通知種別（予定・実行中・完了・中止） |
| title | text | NOT NULL | タイトル |
| description | text | NULL | 詳細説明・実施内容 |
| upload_date | datetime | NOT NULL | 通知作成日 |
| scheduled_date | datetime | NOT NULL | 予定作業日 |
| start_time | time | NULL | 予定開始時刻 |
| end_time | time | NULL | 予定終了時刻 |
| actual_start_time | time | NULL | 実際の開始時刻 |
| actual_end_time | time | NULL | 実際の終了時刻 |
| **メンテナンス制御フィールド** |  |  |  |
| auto_start | boolean | DEFAULT false | 自動開始フラグ |
| auto_end | boolean | DEFAULT false | 自動終了フラグ |
| maintenance_mode | enum('none','read_only','full_stop') | DEFAULT 'none' | メンテナンスモード |
| affected_services | json | NULL | 影響を受けるサービス一覧 |
| rollback_plan | text | NULL | ロールバック手順 |
| approval_status | enum('pending','approved','rejected') | DEFAULT 'pending' | 承認状況 |
| approved_by | varchar(8) | FOREIGN KEY | 承認者ユーザーID |
| approved_at | datetime | NULL | 承認日時 |
| **通知・表示制御** |  |  |  |
| is_visible | boolean | DEFAULT true | 表示フラグ |
| notification_level | enum('info','warning','critical') | DEFAULT 'info' | 通知レベル |
| target_users | json | NULL | 通知対象ユーザー（NULL=全員） |
| created_by | varchar(8) | FOREIGN KEY | 作成者ユーザーID |
| created_at | datetime | DEFAULT CURRENT_TIMESTAMP | 作成日時 |
| updated_at | datetime | DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP | 更新日時 |

#### `maintenance_execution_logs` テーブル（メンテナンス実行ログ）
メンテナンス実行時の詳細なログとステータスを管理

| フィールド名 | データ型 | 制約 | 説明 |
|-------------|----------|------|------|
| log_id | bigint(20) | PRIMARY KEY AUTO_INCREMENT | ログID |
| notification_id | int(11) | FOREIGN KEY NOT NULL | 通知ID |
| execution_step | enum('preparation','start','execution','completion','rollback','error') | NOT NULL | 実行ステップ |
| step_status | enum('pending','in_progress','success','failed','skipped') | NOT NULL | ステップ状況 |
| step_description | varchar(500) | NOT NULL | ステップ説明 |
| execution_command | text | NULL | 実行コマンド・処理内容 |
| execution_result | text | NULL | 実行結果・出力 |
| error_message | text | NULL | エラーメッセージ |
| executed_by | varchar(8) | FOREIGN KEY | 実行者ユーザーID |
| execution_duration_ms | int(11) | NULL | 実行時間（ミリ秒） |
| system_status_before | json | NULL | 実行前システム状態 |
| system_status_after | json | NULL | 実行後システム状態 |
| created_at | datetime | DEFAULT CURRENT_TIMESTAMP | ログ記録日時 |

#### `system_status` テーブル（システム状態管理）
現在のシステムの稼働状態とメンテナンス状況を管理

| フィールド名 | データ型 | 制約 | 説明 |
|-------------|----------|------|------|
| status_id | int(11) | PRIMARY KEY AUTO_INCREMENT | 状態ID |
| system_mode | enum('normal','maintenance','emergency','read_only') | DEFAULT 'normal' | システムモード |
| maintenance_notification_id | int(11) | FOREIGN KEY | 関連メンテナンス通知ID |
| status_message | varchar(500) | NULL | 状態メッセージ |
| affected_features | json | NULL | 影響を受ける機能一覧 |
| estimated_recovery_time | datetime | NULL | 復旧予定時刻 |
| last_health_check | datetime | NULL | 最終ヘルスチェック時刻 |
| health_check_result | json | NULL | ヘルスチェック結果 |
| changed_by | varchar(8) | FOREIGN KEY | 状態変更者ユーザーID |
| created_at | datetime | DEFAULT CURRENT_TIMESTAMP | 作成日時 |
| updated_at | datetime | DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP | 更新日時 |

#### `system_messages` テーブル（システム更新履歴・要望管理）
システムの更新履歴、機能要望、バグ報告を管理

| フィールド名 | データ型 | 制約 | 説明 |
|-------------|----------|------|------|
| message_id | int(11) | PRIMARY KEY AUTO_INCREMENT | メッセージID |
| message_type | enum('feature_request','bug_report','update_log','announcement') | DEFAULT 'update_log' | メッセージ種別 |
| priority | enum('low','normal','high','urgent') | DEFAULT 'normal' | 優先度 |
| status | enum('open','in_progress','testing','completed','rejected') | DEFAULT 'open' | 対応状況 |
| title | varchar(200) | NOT NULL | タイトル・概要 |
| description | text | NOT NULL | 詳細内容 |
| request_date | datetime | NOT NULL | 依頼日・報告日 |
| response_date | datetime | NULL | 対応完了日 |
| requester_facility | varchar(20) | FOREIGN KEY | 依頼者施設ID |
| requester_department | varchar(20) | FOREIGN KEY | 依頼者部署ID |
| requester_name | varchar(60) | NULL | 依頼者氏名 |
| assigned_to | varchar(8) | FOREIGN KEY | 担当者ユーザーID |
| version | varchar(50) | NULL | 対応バージョン |
| is_visible | boolean | DEFAULT true | 表示フラグ |
| created_at | datetime | DEFAULT CURRENT_TIMESTAMP | 作成日時 |
| updated_at | datetime | DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP | 更新日時 |


