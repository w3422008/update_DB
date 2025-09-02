# DB案

### 1. 医療機関基本情報系

#### `hospitals` テーブル（医療機関基本情報）
医療機関の基本情報を格納するメインテーブル

| フィールド名 | データ型 | 制約 | 説明 |
|-------------|----------|------|------|
| hospital_id | varchar(10) | PRIMARY KEY | 医療機関コード |
| hospital_name | varchar(100) | NOT NULL | 医療機関名 |
| hospital_type_id | int(11) | FOREIGN KEY | 病院区分ID |
| status | enum('active','closed') | DEFAULT 'active' | 運営状況 |
| bed | int(11) | NOT NULL | 許可病床数 |
| notes | text | NULL | 備考（基本情報） |
| created_at | timestamp | DEFAULT CURRENT_TIMESTAMP | 作成日時 |
| updated_at | timestamp | DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP | 更新日時 |

#### `hospital_types` テーブル（病院区分マスタ）
病院の種別を管理するマスタテーブル
(病院、特定機能病院、など)

| フィールド名 | データ型 | 制約 | 説明 |
|-------------|----------|------|------|
| type_code | varchar(5) | PRIMARY KEY NOT NULL | 区分コード |
| type_name | varchar(50) | NOT NULL | 区分名 |

#### `addresses` テーブル（住所情報）
医療機関の住所情報を管理

| フィールド名 | データ型 | 制約 | 説明 |
|-------------|----------|------|------|
| address_id | int(11) | PRIMARY KEY AUTO_INCREMENT | 住所ID |
| hospital_id | varchar(10) | FOREIGN KEY | 医療機関コード |
| postal_code | varchar(7) | NULL | 郵便番号 |
| street_number | varchar(200) | NULL | 番地 |
| full_address | varchar(400) | NULL | 完全住所 |
| area_code | int(11) | FOREIGN KEY | 地区コード（areaテーブル参照） |

#### `contact_details` テーブル（連絡先情報）
医療機関の連絡先情報を管理

| フィールド名 | データ型 | 制約 | 説明 |
|-------------|----------|------|------|
| contact_id | int(11) | PRIMARY KEY AUTO_INCREMENT | 連絡先ID |
| hospital_id | varchar(10) | FOREIGN KEY | 医療機関コード |
| phone | varchar(20) | NULL | 電話番号 |
| fax | varchar(20) | NULL | FAX番号 |
| email | varchar(254) | NULL | メールアドレス |
| website | varchar(500) | NULL | ウェブサイト |

### 2. 人員情報系

#### `hospital_staff` テーブル（病院スタッフ情報）
理事長、病院長などの重要人物情報を管理

| フィールド名 | データ型 | 制約 | 説明 |
|-------------|----------|------|------|
| staff_id | int(11) | PRIMARY KEY AUTO_INCREMENT | スタッフ管理ID |
| hospital_id | varchar(10) | FOREIGN KEY | 医療機関コード |
| role_type | enum('chairman','director') | NOT NULL | 役職種別(chairman：理事長、director：病院長) |
| name | varchar(60) | NOT NULL | 氏名 |
| specialty | varchar(50) | NULL | 専門分野 |
| graduation_year | year(4) | NULL | 卒業年度 |
| alma_mater | varchar(100) | NULL | 出身校 |
| notes | text | NULL | 備考 |

#### `削除候補``medical_association` テーブル（医師会情報マスタ）
医師会についての情報を管理

| フィールド名 | データ型 | 制約 | 説明 |
|-------------|----------|------|------|
| section_id | int(11) | PRIMARY KEY AUTO_INCREMENT | 区分コード |
| area_id | varchar(20) | FOREIGN KEY | 地域コード |
| med_area | varchar(60) | NOT NULL | 二次医療圏 |
| med_association | varchar(60) | NOT NULL | 医師会名 |

### 3. 診療時間系

#### `consultation_hours` テーブル（診療時間）
医療機関の診療時間を管理

| フィールド名 | データ型 | 制約 | 説明 |
|-------------|----------|------|------|
| schedule_id | int(11) | PRIMARY KEY AUTO_INCREMENT | スケジュールID |
| hospital_id | varchar(10) | FOREIGN KEY | 医療機関コード |
| day_of_week | enum('monday','tuesday','wednesday','thursday','friday','saturday','sunday','holiday') | NOT NULL | 曜日 |
| period | enum('AM','PM','AM_PM') | NOT NULL | 時間帯 |
| is_available | boolean | DEFAULT false | 診療可否 |
| start_time | time | NULL | 開始時間 |
| end_time | time | NULL | 終了時間 |
| notes | varchar(200) | NULL | 備考 |

### 4. 診療科系

#### `medical_departments` テーブル（診療科マスタ）
診療科の分類と詳細を管理

| フィールド名 | データ型 | 制約 | 説明 |
|-------------|----------|------|------|
| department_id | int(11) | PRIMARY KEY AUTO_INCREMENT | 診療科ID |
| department_code | varchar(10) | UNIQUE NOT NULL | 診療科コード |
| department_name | varchar(100) | NOT NULL | 診療科名 |
| category | varchar(100) | FOREIGN KEY | 診療科カテゴリ名 |

#### `削除候補``medical_categories` テーブル（診療科カテゴリ）
診療科の大分類を管理

| フィールド名 | データ型 | 制約 | 説明 |
|-------------|----------|------|------|
| category_id | int(11) | PRIMARY KEY AUTO_INCREMENT | カテゴリID |
| category_code | varchar(10) | UNIQUE NOT NULL | カテゴリコード |
| category_name | varchar(50) | NOT NULL | カテゴリ名 |
| display_order | int(11) | DEFAULT 0 | 表示順序 |

#### `hospital_departments` テーブル（病院診療科関連）
医療機関が対応している診療科を管理

| フィールド名 | データ型 | 制約 | 説明 |
|-------------|----------|------|------|
| relation_id | int(11) | PRIMARY KEY AUTO_INCREMENT | 関連ID |
| hospital_id | varchar(10) | FOREIGN KEY | 医療機関コード |
| department_id | int(11) | FOREIGN KEY | 診療科ID |

### 5. 診療内容系

#### `medical_services` テーブル（診療内容マスタ）
提供可能な医療サービスを管理

| フィールド名 | データ型 | 制約 | 説明 |
|-------------|----------|------|------|
| service_code | varchar(10) | PRIMARY KEY(複合主キー) NOT NULL | 診療内容コード |
| service_division | varchar(100) | PRIMARY KEY(複合主キー) NULL | 診療区分 |
| service_category | varchar(100) | NULL | 診療部門 |
| service_name | varchar(300) | NOT NULL | 診療内容名 |

#### `hospital_services` テーブル（病院診療内容関連）
医療機関が提供している診療内容を管理

| フィールド名 | データ型 | 制約 | 説明 |
|-------------|----------|------|------|
| hospital_id | varchar(10) | PRIMARY KEY(複合主キー) | 医療機関コード |
| service_id | varchar(20) | PRIMARY KEY(複合主キー) | 診療内容ID |
| notes | text | NULL | 個別備考 |
| created_at | timestamp | DEFAULT CURRENT_TIMESTAMP | 作成日時 |

### 6. 地域・エリア系

#### `areas` テーブル（地域情報）
地域マスタ情報（旧areaテーブルの改良版）

| フィールド名 | データ型 | 制約 | 説明 |
|-------------|----------|------|------|
| area_code | int(11) | PRIMARY KEY NOT NULL | 地区コード |
| secondary_medical_area_name | varchar(50) | NULL | 二次医療圏名 |
| prefecture | varchar(10) | NULL | 都道府県 |
| city | varchar(30) | NULL | 市 |
| ward | varchar(20) | NULL | 区 |
| town | varchar(30) | NULL | 町 |

### 7. 外部連携系

#### `carna_connect` テーブル（カルナコネクト情報）`既存テーブル`

| フィールド名 | データ型 | 制約 | 説明 |
|-------------|----------|------|------|
| hospital_id | varchar(10) | PRIMARY KEY | 医療機関コード |
| is_deleted | boolean | DEFAULT false | 削除フラグ |

### 8. 履歴・ログ系

#### `audit_logs` テーブル（監査ログ）
データ変更の監査ログを統合管理

| フィールド名 | データ型 | 制約 | 説明 |
|-------------|----------|------|------|
| log_id | bigint(20) | PRIMARY KEY AUTO_INCREMENT | ログID |
| table_name | varchar(50) | NOT NULL | 対象テーブル名 |
| record_id | varchar(50) | NOT NULL | 対象レコードID |
| action_type | enum('INSERT','UPDATE','DELETE') | NOT NULL | 操作種別 |
| old_values | json | NULL | 変更前データ |
| new_values | json | NULL | 変更後データ |
| user_id | varchar(10) | NULL | 操作者ID |
| is_admin | boolean | DEFAULT false | 管理者フラグ |
| created_at | timestamp | DEFAULT CURRENT_TIMESTAMP | 操作日時 |
| ip_address | varchar(45) | NULL | IPアドレス |
| user_agent | text | NULL | ユーザーエージェント |

### 9. システム管理系

#### `users` テーブル（システム利用ユーザー）
システム利用者の情報を管理

| フィールド名 | データ型 | 制約 | 説明 |
|-------------|----------|------|------|
| user_id | varchar(8) | PRIMARY KEY | ユーザーID |
| username | varchar(50) | NOT NULL | ユーザー名 |
| password_hash | varchar(255) | NOT NULL | パスワードハッシュ |
| facility_id | varchar(20) | NULL | 所属施設ID |
| department_id | varchar(20) | NULL | 所属部署ID |
| role | enum('admin','editor','viewer') | DEFAULT 'viewer' | 権限レベル |
| is_active | boolean | DEFAULT true | アカウント有効フラグ |
| last_login_at | timestamp | NULL | 最終ログイン日時 |
| created_at | timestamp | DEFAULT CURRENT_TIMESTAMP | 作成日時 |
| updated_at | timestamp | DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP | 更新日時 |

#### `kawasaki_university_facility` テーブル（マスタ）
川崎学園の病院情報を管理
(附属病院、総合医療センター、高齢者医療センター)

| フィールド名 | データ型 | 制約 | 説明 |
|-------------|----------|------|------|
| facility_id | varchar(20) | PRIMARY KEY | 所属施設ID |
| name | varchar(50) | NOT NULL | 施設名 |
| fomal_name | varchar(60) | NOT NULL | 正式名称 |
| abbreviation | varchar(50) | NOT NULL | 略称 |

#### `kawasaki_university_department` テーブル（マスタ）
川崎学園の部署情報を管理

| フィールド名 | データ型 | 制約 | 説明 |
|-------------|----------|------|------|
| department_id | varchar(20) | PRIMARY KEY | 部署ID |
| name | varchar(50) | NOT NULL | 部署名 |

### 10. その他統合テーブル
#### `intro` `invers_intro` テーブル（紹介データ）
医療機関間の紹介情報を管理

| フィールド名 | データ型 | 説明 |
|-------------|----------|------|
| hos_cd | varchar(10) | 医療機関コード（複合主キー） |
| ins | int(11) | 施設区分（複合主キー、0:附属病院, 1:総合医療センター） |
| year | year(4) | 年度（複合主キー） |
| date | date | 診療日（複合主キー） |
| fie_name | varchar(30) | 診療科（複合主キー） |
| fie_cd | int(11) | 診療科コード |
| intr | int(11) | 紹介件数 |

#### `training` テーブル（院外診療支援・研修情報）
院外診療支援・研修情報を管理

| フィールド名 | データ型 | 説明 |
|-------------|----------|------|
| hos_cd | varchar(10) | 医療機関コード（複合主キー） |
| year | year(4) | 年度（複合主キー） |
| ins | int(11) | 施設区分（複合主キー、0:附属病院, 1:総合医療センター） |
| tra_name | varchar(200) | 研修先医療機関名（複合主キー） |
| dep | varchar(60) | 診療科（複合主キー） |
| name | varchar(60) | 氏名（複合主キー） |
| start | date | 診療支援開始日（複合主キー） |
| end | date | 診療支援終了日（複合主キー） |
| date | varchar(300) | 日付 |
| dia_div | varchar(50) | 診療支援区分 |
| occ | varchar(30) | 職名 |

#### `contact` テーブル（コンタクト履歴）
医療機関同士のコンタクト履歴を保管

| フィールド名 | データ型 | 説明 |
|-------------|----------|------|
| hos_cd | varchar(10) | 医療機関コード（複合主キー） |
| hos_name | varchar(100) | 医療機関名 |
| year | year(4) | 年度（複合主キー） |
| ins | int(11) | 施設区分（0:附属病院, 1:総合医療センター）（複合主キー） |
| date | date | 日付（複合主キー） |
| method | varchar(50) | 方法（来院、訪問、オンライン等）（複合主キー） |
| ex_dept | varchar(50) | 連携機関対応者部署 |
| ex_position | varchar(50) | 連携機関対応者役職 |
| ex_name | varchar(10) | 連携機関対応者氏名（複合主キー） |
| ex_subnames | varchar(100) | 連携機関対応人数・氏名 |
| in_dept | varchar(50) | 当院対応者所属 |
| in_name | varchar(10) | 当院対応者氏名（複合主キー） |
| in_subnames | varchar(100) | 当院対応人数・氏名 |
| detail | varchar(100) | 内容 |
| con_note | varchar(100) | 備考 |
| data_dept | varchar(50) | データ作成部署 |
