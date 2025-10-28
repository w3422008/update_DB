DROP DATABASE IF EXISTS newhptldb;
CREATE DATABASE IF NOT EXISTS newhptldb
  DEFAULT CHARACTER SET utf8mb4
  COLLATE utf8mb4_general_ci;

USE newhptldb;

-- 外部キー制約チェックを一時的に無効化（安全なテーブル削除のため）
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS hospital_types;
CREATE TABLE hospital_types (
    hospital_type_id varchar(11) PRIMARY KEY NOT NULL COMMENT '病院区分ID',
    type_name varchar(50) NOT NULL COMMENT '区分名',
    is_active tinyint(1) DEFAULT 1 COMMENT '有効フラグ',
    display_order int(11) NOT NULL DEFAULT 0 COMMENT '表示順序'
) COMMENT = '病院の種別を管理するマスタテーブル（病院、特定機能病院など）';


DROP TABLE IF EXISTS hospitals;
CREATE TABLE hospitals (
    hospital_id varchar(10) PRIMARY KEY COMMENT '医療機関コード',
    hospital_type_id varchar(11) COMMENT '病院区分ID',
    hospital_name varchar(100) NOT NULL COMMENT '医療機関名',
    status enum('active','closed','Locked') DEFAULT 'active' COMMENT '運営状況',
    bed_count int(11) DEFAULT 0 COMMENT '許可病床数',
    consultation_hour varchar(200) NULL COMMENT '診療時間',
    has_carna_connect tinyint(1) DEFAULT 0 COMMENT 'カルナコネクトフラグ',
    has_pt tinyint(1) DEFAULT 0 COMMENT '理学療法士在籍フラグ',
    has_ot tinyint(1) DEFAULT 0 COMMENT '作業療法士在籍フラグ',
    has_st tinyint(1) DEFAULT 0 COMMENT '言語聴覚療法士在籍フラグ',
    notes text NULL COMMENT '備考',
    closed_at date NULL COMMENT '閉院日',
    created_at datetime DEFAULT CURRENT_TIMESTAMP COMMENT '作成日時',
    updated_at datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新日時',
    FOREIGN KEY (hospital_type_id) REFERENCES hospital_types(hospital_type_id)
) COMMENT = '医療機関の基本情報を格納するメインテーブル';

DROP TABLE IF EXISTS areas;
CREATE TABLE areas (
    area_id int(11) PRIMARY KEY NOT NULL COMMENT '地区コード',
    secondary_medical_area_name varchar(50) NULL COMMENT '二次医療圏名',
    prefecture varchar(10) NULL COMMENT '都道府県',
    city varchar(30) NULL COMMENT '市',
    ward varchar(20) NULL COMMENT '区',
    town varchar(30) NULL COMMENT '町',
    is_active tinyint(1) DEFAULT 1 COMMENT '有効フラグ',
    display_order int(11) NOT NULL DEFAULT 0 COMMENT '表示順序'
) COMMENT = '地域マスタ情報（旧areaテーブルの改良版）';

DROP TABLE IF EXISTS addresses;
CREATE TABLE addresses (
    address_id int(11) PRIMARY KEY AUTO_INCREMENT COMMENT '住所ID',
    hospital_id varchar(10) NOT NULL COMMENT '医療機関コード',
    area_id int(11) COMMENT '地区コード（areasテーブル参照）',
    postal_code varchar(7) COMMENT '郵便番号',
    street_number varchar(200) COMMENT '番地',
    full_address varchar(400) COMMENT '完全住所',
    FOREIGN KEY (hospital_id) REFERENCES hospitals(hospital_id),
    FOREIGN KEY (area_id) REFERENCES areas(area_id)
) COMMENT = '医療機関の住所情報を管理';



DROP TABLE IF EXISTS contact_details;
CREATE TABLE contact_details (
    contact_id int(11) PRIMARY KEY AUTO_INCREMENT COMMENT '連絡先ID',
    hospital_id varchar(10) NOT NULL COMMENT '医療機関コード',
    contact_detail varchar(30) NULL COMMENT '連絡先（診療科・部署など）',
    phone varchar(20) NULL COMMENT '電話番号',
    fax varchar(20) NULL COMMENT 'FAX番号',
    email varchar(254) NULL COMMENT 'メールアドレス',
    website varchar(500) NULL COMMENT 'ウェブサイト',
    note text NULL COMMENT '備考',
    is_deleted tinyint(1) DEFAULT 0 COMMENT '削除フラグ',
    FOREIGN KEY (hospital_id) REFERENCES hospitals(hospital_id)
) COMMENT = '医療機関の連絡先情報を管理';

DROP TABLE IF EXISTS ward_types;
CREATE TABLE ward_types (
    ward_id varchar(10) PRIMARY KEY NOT NULL COMMENT '病棟種類ID',
    ward_name varchar(20) NOT NULL COMMENT '病棟名',
    is_active tinyint(1) DEFAULT 1 COMMENT '有効フラグ',
    display_order int(11) NOT NULL DEFAULT 0 COMMENT '表示順序'
) COMMENT = '病棟種類名を管理する';

DROP TABLE IF EXISTS hospitals_ward_types;
CREATE TABLE hospitals_ward_types (
    hospital_id varchar(10) COMMENT '医療機関コード',
    ward_id varchar(10) COMMENT '病棟種類ID',
    PRIMARY KEY (hospital_id, ward_id),
    FOREIGN KEY (hospital_id) REFERENCES hospitals(hospital_id),
    FOREIGN KEY (ward_id) REFERENCES ward_types(ward_id)
) COMMENT = '病棟種類を持つかどうかを管理';

DROP TABLE IF EXISTS hospital_staffs;
CREATE TABLE hospital_staffs (
    staff_id int(11) PRIMARY KEY AUTO_INCREMENT COMMENT 'スタッフ管理ID',
    hospital_id varchar(10) NOT NULL COMMENT '医療機関コード',
    role_type enum('chairman','director') NOT NULL COMMENT '役職種別(chairman：理事長、director：病院長)',
    staff_name varchar(60) NOT NULL COMMENT '氏名',
    specialty varchar(50) NULL COMMENT '専門分野',
    graduation_year year(4) NULL COMMENT '卒業年度',
    alma_mater varchar(100) NULL COMMENT '出身校',
    notes text NULL COMMENT '備考',
    FOREIGN KEY (hospital_id) REFERENCES hospitals(hospital_id)
) COMMENT = '理事長、病院長などの重要人物情報を管理';

DROP TABLE IF EXISTS hospital_code_history;
CREATE TABLE hospital_code_history (
    history_id bigint(20) PRIMARY KEY AUTO_INCREMENT COMMENT '履歴ID',
    hospital_id varchar(10) NOT NULL COMMENT '現在の医療機関コード',
    former_hospital_id varchar(10) NOT NULL COMMENT '以前の医療機関コード',
    change_date date NULL COMMENT 'コード更新日',
    
    INDEX idx_hospital_code_history_hospital_id (hospital_id),
    INDEX idx_hospital_code_history_former_hospital_id (former_hospital_id),
    INDEX idx_hospital_code_history_change_date (change_date),
    
    FOREIGN KEY (hospital_id) REFERENCES hospitals(hospital_id)
) COMMENT = '現在の医療機関コードと、過去に使用されていたコードを紐づけ';

DROP TABLE IF EXISTS consultation_hours;
CREATE TABLE consultation_hours (
    hospital_id varchar(10) COMMENT '医療機関コード',
    day_of_week enum('monday','tuesday','wednesday','thursday','friday','saturday','sunday','holiday') NOT NULL COMMENT '曜日',
    period enum('AM','PM') NOT NULL COMMENT '時間帯',
    is_available tinyint(1) DEFAULT 1 COMMENT '診療可否',
    start_time time COMMENT '開始時間',
    end_time time COMMENT '終了時間',
    notes varchar(200) COMMENT '備考',
    PRIMARY KEY (hospital_id, day_of_week, period),
    FOREIGN KEY (hospital_id) REFERENCES hospitals(hospital_id)
) COMMENT = '医療機関の診療時間を管理';

DROP TABLE IF EXISTS medical_departments;
CREATE TABLE medical_departments (
    department_id varchar(10) PRIMARY KEY NOT NULL COMMENT '診療科コード',
    department_name varchar(100) NOT NULL COMMENT '診療科名',
    category varchar(100) NOT NULL COMMENT '診療科カテゴリ名',
    is_active tinyint(1) DEFAULT 1 COMMENT '有効フラグ',
    display_order int(11) NOT NULL DEFAULT 0 COMMENT '表示順序'
) COMMENT = '診療科の分類と詳細を管理';

-- DROP TABLE IF EXISTS medical_categories;
-- CREATE TABLE medical_categories (
--     category_id int(11) PRIMARY KEY AUTO_INCREMENT COMMENT 'カテゴリID',
--     category_code varchar(10) NOT NULL UNIQUE COMMENT 'カテゴリコード',
--     category_name varchar(50) NOT NULL COMMENT 'カテゴリ名',
--     display_order int(11) COMMENT '表示順序'
-- ) COMMENT = '診療科の大分類を管理';

DROP TABLE IF EXISTS hospital_departments;
CREATE TABLE hospital_departments (
    hospital_id varchar(10) COMMENT '医療機関コード',
    department_id varchar(10) COMMENT '診療科コード',
    PRIMARY KEY (hospital_id, department_id),
    FOREIGN KEY (hospital_id) REFERENCES hospitals(hospital_id),
    FOREIGN KEY (department_id) REFERENCES medical_departments(department_id)
) COMMENT = '医療機関が対応している診療科を管理';

-- 先に医療サービスマスタを作成
DROP TABLE IF EXISTS medical_services;
CREATE TABLE medical_services (
    service_id varchar(10) COMMENT '診療内容コード',
    service_division varchar(100) NOT NULL COMMENT '診療区分',
    service_category varchar(100) NULL COMMENT '診療部門',
    service_name varchar(300) NOT NULL COMMENT '診療内容名',
    is_active tinyint(1) DEFAULT 1 COMMENT '有効フラグ',
    display_order int(11) NOT NULL DEFAULT 0 COMMENT '表示順序',
    PRIMARY KEY (service_id, service_division)
) COMMENT = '提供可能な医療サービスを管理';

DROP TABLE IF EXISTS hospital_services;
CREATE TABLE hospital_services (
    hospital_id varchar(10) COMMENT '医療機関コード',
    service_id varchar(10) COMMENT '診療内容コード',
    service_division varchar(100) COMMENT '診療区分',
    PRIMARY KEY (hospital_id, service_id, service_division),
    FOREIGN KEY (hospital_id) REFERENCES hospitals(hospital_id),
    FOREIGN KEY (service_id, service_division) REFERENCES medical_services(service_id, service_division)
) COMMENT = '医療機関が提供している診療内容を管理';

DROP TABLE IF EXISTS clinical_paths;
CREATE TABLE clinical_paths (
    clinical_path_id varchar(10) PRIMARY KEY COMMENT '連携パスID',
    path_name varchar(30) NOT NULL COMMENT '連携パス名',
    is_active tinyint(1) DEFAULT 1 COMMENT '有効フラグ',
    display_order int(11) NOT NULL DEFAULT 0 COMMENT '表示順序'
) COMMENT = '地域連携クリニカルパス名を管理';

DROP TABLE IF EXISTS clinical_path_hospitals;
CREATE TABLE clinical_path_hospitals (
    hospital_id varchar(10) COMMENT '医療機関コード',
    clinical_path_id varchar(10) COMMENT '連携パスID',
    facility_id varchar(20) COMMENT '施設ID',
    PRIMARY KEY (hospital_id, clinical_path_id, facility_id),
    FOREIGN KEY (hospital_id) REFERENCES hospitals(hospital_id),
    FOREIGN KEY (clinical_path_id) REFERENCES clinical_paths(clinical_path_id)
) COMMENT = '地域連携クリニカルパスの存在有無を管理';

-- 川崎学園マスタテーブルを先に作成
DROP TABLE IF EXISTS kawasaki_university_facilities;
CREATE TABLE kawasaki_university_facilities (
    facility_id varchar(20) PRIMARY KEY COMMENT '施設ID',
    facility_name varchar(50) NOT NULL COMMENT '施設名',
    abbreviation varchar(50) NULL COMMENT '略名',
    is_active tinyint(1) DEFAULT 1 COMMENT '有効フラグ',
    display_order int(11) NOT NULL DEFAULT 0 COMMENT '表示順序'
) COMMENT = '川崎学園の病院情報を管理（附属病院、総合医療センター、高齢者医療センター）';

DROP TABLE IF EXISTS kawasaki_university_departments;
CREATE TABLE kawasaki_university_departments (
    department_id varchar(20) PRIMARY KEY COMMENT '部署ID',
    facility_id varchar(20) NOT NULL COMMENT '施設ID',
    department_name varchar(50) NOT NULL COMMENT '部署名',
    is_active tinyint(1) DEFAULT 1 COMMENT '有効フラグ',
    display_order int(11) NOT NULL DEFAULT 0 COMMENT '表示順序',
    FOREIGN KEY (facility_id) REFERENCES kawasaki_university_facilities(facility_id)
) COMMENT = '川崎学園の部署情報を管理';

-- 川崎学園マスタテーブルを先に作成
DROP TABLE IF EXISTS kawasaki_university_facilities;
CREATE TABLE kawasaki_university_facilities (
    facility_id varchar(20) PRIMARY KEY COMMENT '施設ID',
    facility_name varchar(50) NOT NULL COMMENT '施設名',
    abbreviation varchar(50) NULL COMMENT '略名',
    is_active tinyint(1) DEFAULT 1 COMMENT '有効フラグ',
    display_order int(11) NOT NULL DEFAULT 0 COMMENT '表示順序'
) COMMENT = '川崎学園の病院情報を管理（附属病院、総合医療センター、高齢者医療センター）';

DROP TABLE IF EXISTS kawasaki_university_departments;
CREATE TABLE kawasaki_university_departments (
    department_id varchar(20) PRIMARY KEY COMMENT '部署ID',
    facility_id varchar(20) NOT NULL COMMENT '施設ID',
    department_name varchar(50) NOT NULL COMMENT '部署名',
    is_active tinyint(1) DEFAULT 1 COMMENT '有効フラグ',
    display_order int(11) NOT NULL DEFAULT 0 COMMENT '表示順序',
    FOREIGN KEY (facility_id) REFERENCES kawasaki_university_facilities(facility_id)
) COMMENT = '川崎学園の部署情報を管理';

DROP TABLE IF EXISTS users;
CREATE TABLE users (
    user_id varchar(8) PRIMARY KEY COMMENT 'ユーザーID',
    user_name varchar(50) NOT NULL COMMENT 'ユーザー名',
    password_hash varchar(255) NOT NULL COMMENT 'パスワードハッシュ',
    department_id varchar(20) NOT NULL COMMENT '所属部署ID',
    role enum('admin','editor','viewer','system_admin') DEFAULT 'viewer' COMMENT '権限レベル',
    is_active tinyint(1) DEFAULT 1 COMMENT 'アカウント有効フラグ',
    last_login_at datetime NULL COMMENT '最終ログイン日時',
    created_at datetime DEFAULT CURRENT_TIMESTAMP COMMENT '作成日時',
    updated_at datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新日時',
    
    INDEX idx_users_user_name (user_name),
    INDEX idx_users_active (is_active),
    INDEX idx_users_department (department_id),
    INDEX idx_users_role (role),
    INDEX idx_users_last_login (last_login_at),
    INDEX idx_users_created_at (created_at),
    INDEX idx_users_active_role (is_active, role),
    
    FOREIGN KEY (department_id) REFERENCES kawasaki_university_departments(department_id)
) COMMENT = 'システム利用者の情報を管理';

DROP TABLE IF EXISTS unified_logs;
CREATE TABLE unified_logs (
    log_id bigint(20) PRIMARY KEY AUTO_INCREMENT COMMENT 'ログID',
    log_type enum('audit','security') NOT NULL COMMENT 'ログ種別',
    action_type varchar(20) NOT NULL COMMENT '操作種別',
    user_id varchar(8) COMMENT 'ユーザーID',
    ip_address varchar(45) NULL COMMENT 'IPアドレス',
    table_name varchar(50) NULL COMMENT '対象テーブル名',
    record_id varchar(50) NULL COMMENT '対象レコードID',
    old_values json NULL COMMENT '変更前データ',
    new_values json NULL COMMENT '変更後データ',
    additional_data json NULL COMMENT '追加データ・その他情報',
    description text NULL COMMENT 'イベント詳細・説明',
    created_at datetime DEFAULT CURRENT_TIMESTAMP COMMENT 'ログ記録日時',
    
    INDEX log_type_idx (log_type),
    INDEX action_type_idx (action_type),
    INDEX user_id_idx (user_id),
    INDEX table_name_idx (table_name),
    INDEX record_id_idx (record_id),
    INDEX created_at_idx (created_at),

    FOREIGN KEY (user_id) REFERENCES users(user_id)
) COMMENT = 'システム内のすべてのログ情報を一元管理する統合ログテーブル';

DROP TABLE IF EXISTS login_attempt_counts;
CREATE TABLE login_attempt_counts (
    user_id varchar(8) PRIMARY KEY COMMENT 'ユーザーID',
    failed_attempts tinyint(3) DEFAULT 0 COMMENT '連続失敗回数',
    last_failed_at datetime NULL COMMENT '最終失敗日時',
    FOREIGN KEY (user_id) REFERENCES users(user_id)
) COMMENT = 'ユーザーがパスワードを間違えた際に登録される';

DROP TABLE IF EXISTS referrals;
CREATE TABLE referrals (
    hospital_id varchar(10) COMMENT '医療機関コード',
    facility_id varchar(20) COMMENT '施設ID',
    year year COMMENT '年度',
    date date COMMENT '診療日',
    department_name varchar(30) COMMENT '診療科',
    referral_type enum('referral','invers_referral') DEFAULT 'referral' COMMENT '紹介・逆紹介判定',
    department_id varchar(10) NULL COMMENT '診療科コード',
    referral_count int(11) NOT NULL COMMENT '紹介・逆紹介件数',
    PRIMARY KEY (hospital_id, facility_id, year, date, department_name, referral_type),
    FOREIGN KEY (hospital_id) REFERENCES hospitals(hospital_id)
) COMMENT = '医療機関間の紹介情報を管理';

-- 職名マスタテーブルを追加
DROP TABLE IF EXISTS positions;
CREATE TABLE positions (
    position_name varchar(60) PRIMARY KEY COMMENT '職名',
    is_active tinyint(1) DEFAULT 1 COMMENT '有効フラグ',
    display_order int(11) NOT NULL DEFAULT 0 COMMENT '表示順序'
) COMMENT = '職名マスタテーブル';

DROP TABLE IF EXISTS training;
CREATE TABLE training (
    hospital_id varchar(10) COMMENT '医療機関コード',
    year year COMMENT '年度',
    facility_id varchar(20) COMMENT '施設ID',
    department varchar(60) COMMENT '診療科',
    staff_name varchar(60) NOT NULL COMMENT '氏名',
    position_name varchar(60) COMMENT '職名',
    start_date date COMMENT '診療支援開始日',
    end_date date NULL COMMENT '診療支援終了日',
    date varchar(300) NULL COMMENT '日付',
    diagnostic_aid varchar(50) NULL COMMENT '診療支援区分',
    PRIMARY KEY (hospital_id, year, facility_id, department, start_date),
    FOREIGN KEY (hospital_id) REFERENCES hospitals(hospital_id),
    FOREIGN KEY (position_name) REFERENCES positions(position_name)
) COMMENT = '複数の医療機関へ研修・勤務している人物を管理';

DROP TABLE IF EXISTS contacts;
CREATE TABLE contacts (
    hospital_id varchar(10) COMMENT '医療機関コード',
    year year(4) COMMENT '年度',
    facility_id varchar(20) COMMENT '施設ID',
    date date COMMENT '日付',
    method varchar(50) COMMENT '方法（来院、訪問、オンライン等）',
    external_contact_name varchar(10) NOT NULL COMMENT '連携機関対応者氏名',
    external_department varchar(50) NULL COMMENT '連携機関対応者部署',
    external_position varchar(50) NULL COMMENT '連携機関対応者役職',
    external_additional_participants varchar(100) NULL COMMENT '連携機関対応人数・氏名',
    internal_contact_name varchar(10) NOT NULL COMMENT '当院対応者氏名',
    internal_department varchar(50) NULL COMMENT '当院対応者所属',
    internal_additional_participants varchar(100) NULL COMMENT '当院対応人数・氏名',
    detail varchar(100) NULL COMMENT '内容',
    notes varchar(100) NULL COMMENT '備考',
    data_department varchar(50) NULL COMMENT 'データ作成部署',
    PRIMARY KEY (hospital_id, year, facility_id, date, method),
    FOREIGN KEY (hospital_id) REFERENCES hospitals(hospital_id)
) COMMENT = '医療機関同士のコンタクト履歴を保管';

-- 問い合わせテーブル
DROP TABLE IF EXISTS inquires;
CREATE TABLE inquires (
    inquire_id bigint(20) PRIMARY KEY AUTO_INCREMENT COMMENT '問い合わせID',
    user_id varchar(8) COMMENT '問い合わせ者ユーザーID',
    priority enum('general','urgent') DEFAULT 'general' COMMENT '優先度',
    status enum('open','in_progress','resolved','closed') DEFAULT 'open' COMMENT '対応状況',
    description text NOT NULL COMMENT '問い合わせ内容',
    assigned_to varchar(8) COMMENT '担当者ユーザーID',
    resolution text NULL COMMENT '回答内容',
    created_at datetime DEFAULT CURRENT_TIMESTAMP COMMENT '問い合わせ日時',
    updated_at date NULL COMMENT '回答日',
    resolved_at date NULL COMMENT '対応終了日',
    
    INDEX idx_inquires_user_id (user_id),
    INDEX idx_inquires_status (status),
    INDEX idx_inquires_priority (priority),
    INDEX idx_inquires_assigned_to (assigned_to),
    INDEX idx_inquires_created_at (created_at),
    
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (assigned_to) REFERENCES users(user_id)
) COMMENT = 'システムに関する問い合わせ内容を管理';

-- =================================================================
-- システム運営管理系テーブル
-- =================================================================

-- メンテナンス通知テーブル
DROP TABLE IF EXISTS maintenances;
CREATE TABLE maintenances (
    maintenance_id bigint(20) PRIMARY KEY AUTO_INCREMENT COMMENT 'メンテナンスID',
    title varchar(200) NOT NULL COMMENT 'タイトル',
    comment text NOT NULL COMMENT '実施内容',
    date date NOT NULL COMMENT '予定作業日',
    start_time time NULL COMMENT '予定開始時刻',
    end_time time NULL COMMENT '予定終了時刻',
    view tinyint(1) DEFAULT 1 COMMENT '表示フラグ',
    created_by varchar(8) COMMENT '作成者ユーザーID',
    created_at datetime DEFAULT CURRENT_TIMESTAMP COMMENT '作成日時',
    updated_at datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新日時',
    
    INDEX idx_maintenances_date (date),
    INDEX idx_maintenances_view (view),
    INDEX idx_maintenances_created_by (created_by),
    
    FOREIGN KEY (created_by) REFERENCES users(user_id)
) COMMENT = '事前メンテナンス通知を管理';

-- メンテナンス実行中通知テーブル
DROP TABLE IF EXISTS maintenance_start;
CREATE TABLE maintenance_start (
    id bigint(20) PRIMARY KEY AUTO_INCREMENT COMMENT '実行通知ID',
    maintenance_id bigint(20) COMMENT 'メンテナンスID',
    title varchar(200) NOT NULL COMMENT '通知タイトル',
    description text NULL COMMENT '通知詳細',
    implementation_details text NULL COMMENT '実施内容',
    view tinyint(1) DEFAULT 1 COMMENT '表示フラグ',
    created_by varchar(8) COMMENT '作成者ユーザーID',
    created_at datetime DEFAULT CURRENT_TIMESTAMP COMMENT '作成日時',
    updated_at datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新日時',
    
    INDEX idx_maintenance_start_maintenance_id (maintenance_id),
    INDEX idx_maintenance_start_view (view),
    
    FOREIGN KEY (maintenance_id) REFERENCES maintenances(maintenance_id),
    FOREIGN KEY (created_by) REFERENCES users(user_id)
) COMMENT = 'メンテナンス実行中の通知を管理';

-- システムバージョン管理テーブル
DROP TABLE IF EXISTS system_versions;
CREATE TABLE system_versions (
    version_id int(11) PRIMARY KEY AUTO_INCREMENT COMMENT 'バージョン管理ID',
    version_number varchar(20) NOT NULL UNIQUE COMMENT 'バージョン番号（例：4.5.2）',
    release_date date NOT NULL COMMENT 'リリース日',
    is_current tinyint(1) DEFAULT 0 COMMENT '現在稼働バージョンフラグ',
    release_notes text NULL COMMENT 'リリースノート・変更内容',
    created_at datetime DEFAULT CURRENT_TIMESTAMP COMMENT '作成日時',
    updated_at datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新日時',
    
    INDEX idx_system_versions_is_current (is_current),
    INDEX idx_system_versions_release_date (release_date)
) COMMENT = 'システムのバージョン情報を最小限で管理';

-- メッセージテーブル（システム更新履歴・要望管理）
DROP TABLE IF EXISTS messages;
CREATE TABLE messages (
    message_id bigint(20) PRIMARY KEY AUTO_INCREMENT COMMENT 'メッセージID',
    status enum('open','in_progress','completed','rejected') DEFAULT 'open' COMMENT '対応状況',
    comment text NOT NULL COMMENT '内容',
    view tinyint(1) DEFAULT 1 COMMENT '表示フラグ',
    version_id int(11) NULL COMMENT '実装バージョンID',
    assigned_to varchar(8) COMMENT '担当者ユーザーID',
    res_date date NULL COMMENT '対応日',
    created_at datetime DEFAULT CURRENT_TIMESTAMP COMMENT '作成日時',
    updated_at datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新日時',
    
    INDEX idx_messages_status (status),
    INDEX idx_messages_assigned_to (assigned_to),
    INDEX idx_messages_version_id (version_id),
    INDEX idx_messages_created_at (created_at),
    
    FOREIGN KEY (version_id) REFERENCES system_versions(version_id),
    FOREIGN KEY (assigned_to) REFERENCES users(user_id)
) COMMENT = 'システムの更新履歴、実装予定機能掲載、現状報告を管理';

-- システム状態管理テーブル
DROP TABLE IF EXISTS system_status;
CREATE TABLE system_status (
    status_id int(11) PRIMARY KEY AUTO_INCREMENT COMMENT '状態ID',
    system_mode enum('normal','maintenance','read_only') DEFAULT 'normal' COMMENT 'システムモード',
    status_message varchar(500) NULL COMMENT '現在の状態メッセージ',
    maintenance_id bigint(20) NULL COMMENT '関連メンテナンスID',
    changed_by varchar(8) NOT NULL COMMENT '状態変更者ユーザーID',
    created_at datetime DEFAULT CURRENT_TIMESTAMP COMMENT '作成日時',
    updated_at datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新日時',
    
    INDEX idx_system_status_system_mode (system_mode),
    INDEX idx_system_status_maintenance_id (maintenance_id),
    INDEX idx_system_status_created_at (created_at),
    
    FOREIGN KEY (maintenance_id) REFERENCES maintenances(maintenance_id),
    FOREIGN KEY (changed_by) REFERENCES users(user_id)
) COMMENT = '現在のシステムモードと状態を管理するシンプルなテーブル';

-- =================================================================
-- 関係者・人物情報系
-- =================================================================

-- 親族情報テーブル
DROP TABLE IF EXISTS relatives;
CREATE TABLE relatives (
    relative_id int(11) PRIMARY KEY AUTO_INCREMENT COMMENT '親族ID',
    hospital_id varchar(10) NOT NULL COMMENT '医療機関コード',
    relative_name varchar(60) NOT NULL COMMENT '親族名',
    connection varchar(30) NULL COMMENT '続柄',
    school_name varchar(100) NULL COMMENT '学校名',
    entrance_year year(4) NULL COMMENT '入学年',
    graduation_year year(4) NULL COMMENT '卒業年',
    notes text NULL COMMENT '備考',
    is_deleted tinyint(1) DEFAULT 0 COMMENT '削除フラグ',
    created_at datetime DEFAULT CURRENT_TIMESTAMP COMMENT '作成日時',
    updated_at datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新日時',
    
    INDEX idx_relatives_hospital_id (hospital_id),
    INDEX idx_relatives_relative_name (relative_name),
    INDEX idx_relatives_connection (connection),
    INDEX idx_relatives_graduation_year (graduation_year),
    INDEX idx_relatives_is_deleted (is_deleted),
    INDEX idx_relatives_created_at (created_at),
    
    FOREIGN KEY (hospital_id) REFERENCES hospitals(hospital_id)
) COMMENT = '医療機関に関連する人物の親族情報を管理';

-- =================================================================
-- 会議・イベント参加系
-- =================================================================

-- 医療連携懇話会参加年度テーブル
DROP TABLE IF EXISTS social_meetings;
CREATE TABLE social_meetings (
    hospital_id varchar(10) COMMENT '医療機関コード',
    facility_id varchar(20) COMMENT '施設ID',
    meeting_year year(4) COMMENT '参加年度',
    created_at datetime DEFAULT CURRENT_TIMESTAMP COMMENT '作成日時',
    updated_at datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新日時',
    PRIMARY KEY (hospital_id, facility_id, meeting_year),
    
    INDEX idx_social_meetings_hospital_id (hospital_id),
    INDEX idx_social_meetings_facility_id (facility_id),
    INDEX idx_social_meetings_meeting_year (meeting_year),
    INDEX idx_social_meetings_created_at (created_at),
    
    FOREIGN KEY (hospital_id) REFERENCES hospitals(hospital_id)
) COMMENT = '医療連携懇話会への参加年度を管理';

-- 外部キー制約チェックを再度有効化
SET FOREIGN_KEY_CHECKS = 1;



-- =================================================================
-- ログ確認用ビュー（統合ログテーブル用）
-- =================================================================

-- 監査ログサマリビュー
CREATE VIEW audit_summary AS
SELECT 
    table_name,
    action_type,
    COUNT(*) as count,
    MIN(created_at) as first_action,
    MAX(created_at) as last_action
FROM unified_logs 
WHERE log_type = 'audit'
GROUP BY table_name, action_type
ORDER BY table_name, action_type;

-- セキュリティアラートビュー
CREATE VIEW security_alerts AS
SELECT 
    ul.*,
    u.user_name,
    u.department_id as user_department_id
FROM unified_logs ul
LEFT JOIN users u ON ul.user_id = u.user_id
WHERE ul.log_type = 'security'
   AND (ul.action_type IN ('login_failure', 'permission_denied', 'suspicious_access'))
ORDER BY ul.created_at DESC;

-- ユーザーアクティビティビュー
CREATE VIEW user_activity AS
SELECT 
    u.user_id,
    u.user_name,
    u.department_id,
    COUNT(DISTINCT DATE(ul.created_at)) as active_days,
    COUNT(ul.log_id) as total_accesses,
    MAX(ul.created_at) as last_access,
    COUNT(CASE WHEN ul.action_type = 'login' THEN 1 END) as login_count
FROM users u
LEFT JOIN unified_logs ul ON u.user_id = ul.user_id 
WHERE ul.log_type = 'access'
   AND ul.created_at >= DATE_SUB(NOW(), INTERVAL 30 DAY)
GROUP BY u.user_id, u.user_name, u.department_id
ORDER BY last_access DESC;

-- =================================================================
-- システム運営管理用ビュー
-- =================================================================

-- 現在のシステム状態ビュー
CREATE VIEW current_system_status AS
SELECT 
    ss.status_id,
    ss.system_mode,
    ss.status_message,
    ss.created_at as status_changed_at,
    u.user_name as changed_by_name,
    ud.department_name,
    m.title as maintenance_title,
    m.date as maintenance_date,
    m.start_time as maintenance_start,
    m.end_time as maintenance_end
FROM system_status ss
LEFT JOIN users u ON ss.changed_by = u.user_id
LEFT JOIN kawasaki_university_departments ud ON u.department_id = ud.department_id
LEFT JOIN maintenances m ON ss.maintenance_id = m.maintenance_id
ORDER BY ss.created_at DESC
LIMIT 1;

-- 現在稼働中のバージョン情報ビュー
CREATE VIEW current_version AS
SELECT 
    version_id,
    version_number,
    release_date,
    release_notes,
    created_at
FROM system_versions 
WHERE is_current = true
ORDER BY version_id DESC
LIMIT 1;

-- メンテナンス予定一覧ビュー
CREATE VIEW maintenance_schedule AS
SELECT 
    m.maintenance_id,
    m.title,
    m.comment,
    m.date,
    m.start_time,
    m.end_time,
    m.view,
    u.user_name as created_by_name,
    ud.department_name,
    m.created_at,
    CASE 
        WHEN m.date < CURDATE() THEN '完了'
        WHEN m.date = CURDATE() AND CURTIME() BETWEEN COALESCE(m.start_time, '00:00:00') AND COALESCE(m.end_time, '23:59:59') THEN '実行中'
        WHEN m.date = CURDATE() AND CURTIME() < COALESCE(m.start_time, '00:00:00') THEN '本日予定'
        WHEN m.date > CURDATE() THEN '予定'
        ELSE '完了'
    END as status
FROM maintenances m
LEFT JOIN users u ON m.created_by = u.user_id
LEFT JOIN kawasaki_university_departments ud ON u.department_id = ud.department_id
WHERE m.view = true
ORDER BY m.date DESC, m.start_time ASC;

-- メッセージ・要望管理ビュー
CREATE VIEW message_management AS
SELECT 
    msg.message_id,
    msg.status,
    msg.comment,
    msg.res_date,
    msg.created_at,
    msg.updated_at,
    u_assigned.user_name as assigned_to_name,
    ud_assigned.department_name as assigned_department,
    sv.version_number as implemented_version,
    sv.release_date as version_release_date,
    CASE 
        WHEN msg.status = 'completed' THEN DATEDIFF(msg.res_date, DATE(msg.created_at))
        WHEN msg.status IN ('open', 'in_progress') THEN DATEDIFF(CURDATE(), DATE(msg.created_at))
        ELSE NULL
    END as days_elapsed
FROM messages msg
LEFT JOIN users u_assigned ON msg.assigned_to = u_assigned.user_id
LEFT JOIN kawasaki_university_departments ud_assigned ON u_assigned.department_id = ud_assigned.department_id
LEFT JOIN system_versions sv ON msg.version_id = sv.version_id
WHERE msg.view = true
ORDER BY msg.created_at DESC;

-- バージョン管理統計ビュー
CREATE VIEW version_statistics AS
SELECT 
    sv.version_id,
    sv.version_number,
    sv.release_date,
    sv.is_current,
    COUNT(msg.message_id) as related_messages,
    COUNT(CASE WHEN msg.status = 'completed' THEN 1 END) as completed_messages,
    COUNT(CASE WHEN msg.status = 'in_progress' THEN 1 END) as in_progress_messages,
    COUNT(CASE WHEN msg.status = 'open' THEN 1 END) as open_messages
FROM system_versions sv
LEFT JOIN messages msg ON sv.version_id = msg.version_id
GROUP BY sv.version_id, sv.version_number, sv.release_date, sv.is_current
ORDER BY sv.release_date DESC;

-- 問い合わせ管理ビュー
CREATE VIEW inquire_management AS
SELECT 
    inq.inquire_id,
    inq.priority,
    inq.status,
    inq.description,
    inq.resolution,
    inq.created_at,
    inq.updated_at,
    inq.resolved_at,
    u_user.user_name as inquirer_name,
    ud_user.department_name as inquirer_department,
    u_assigned.user_name as assigned_to_name,
    ud_assigned.department_name as assigned_department,
    CASE 
        WHEN inq.status = 'resolved' AND inq.resolved_at IS NOT NULL THEN 
            TIMESTAMPDIFF(HOUR, inq.created_at, inq.resolved_at)
        WHEN inq.status IN ('open', 'in_progress') THEN 
            TIMESTAMPDIFF(HOUR, inq.created_at, NOW())
        ELSE NULL
    END as response_time_hours,
    DATEDIFF(CURDATE(), DATE(inq.created_at)) as days_since_created
FROM inquires inq
LEFT JOIN users u_user ON inq.user_id = u_user.user_id
LEFT JOIN kawasaki_university_departments ud_user ON u_user.department_id = ud_user.department_id
LEFT JOIN users u_assigned ON inq.assigned_to = u_assigned.user_id
LEFT JOIN kawasaki_university_departments ud_assigned ON u_assigned.department_id = ud_assigned.department_id
ORDER BY 
    CASE inq.priority 
        WHEN 'urgent' THEN 1
        WHEN 'general' THEN 2
    END,
    inq.created_at DESC;

-- 問い合わせ統計ビュー
CREATE VIEW inquire_statistics AS
SELECT 
    COUNT(*) as total_inquiries,
    COUNT(CASE WHEN status = 'open' THEN 1 END) as open_inquiries,
    COUNT(CASE WHEN status = 'in_progress' THEN 1 END) as in_progress_inquiries,
    COUNT(CASE WHEN status = 'resolved' THEN 1 END) as resolved_inquiries,
    COUNT(CASE WHEN status = 'closed' THEN 1 END) as closed_inquiries,
    COUNT(CASE WHEN priority = 'urgent' THEN 1 END) as urgent_inquiries,
    COUNT(CASE WHEN priority = 'general' THEN 1 END) as general_inquiries,
    AVG(CASE 
        WHEN status = 'resolved' AND resolved_at IS NOT NULL THEN 
            TIMESTAMPDIFF(HOUR, created_at, resolved_at)
    END) as avg_resolution_time_hours,
    DATE(created_at) as inquiry_date
FROM inquires 
WHERE created_at >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
GROUP BY DATE(created_at)
ORDER BY inquiry_date DESC;

-- システム利用統計ビュー（最新30日間）
CREATE VIEW system_usage_stats AS
SELECT 
    DATE(ul.created_at) as usage_date,
    COUNT(DISTINCT ul.user_id) as unique_users,
    COUNT(CASE WHEN ul.log_type = 'access' THEN 1 END) as total_accesses,
    COUNT(CASE WHEN ul.log_type = 'audit' THEN 1 END) as audit_actions
FROM unified_logs ul
WHERE ul.created_at >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
GROUP BY DATE(ul.created_at)
ORDER BY usage_date DESC;

-- =================================================================
-- 便利な関数・プロシージャ
-- =================================================================

-- 現在のシステムバージョンを取得する関数
DELIMITER $$
CREATE FUNCTION get_current_version() RETURNS VARCHAR(20)
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE current_ver VARCHAR(20) DEFAULT 'Unknown';
    
    SELECT version_number INTO current_ver
    FROM system_versions 
    WHERE is_current = true
    LIMIT 1;
    
    RETURN current_ver;
END$$

-- 問い合わせステータス一括更新プロシージャ
CREATE PROCEDURE update_inquire_status(
    IN p_inquire_id BIGINT,
    IN p_new_status ENUM('open','in_progress','resolved','closed'),
    IN p_resolution TEXT,
    IN p_assigned_to VARCHAR(8)
)
MODIFIES SQL DATA
BEGIN
    DECLARE old_status ENUM('open','in_progress','resolved','closed');
    
    -- 現在のステータスを取得
    SELECT status INTO old_status FROM inquires WHERE inquire_id = p_inquire_id;
    
    -- ステータス更新
    UPDATE inquires 
    SET status = p_new_status,
        assigned_to = COALESCE(p_assigned_to, assigned_to),
        resolution = CASE WHEN p_new_status = 'resolved' THEN COALESCE(p_resolution, resolution) ELSE resolution END,
        resolved_at = CASE WHEN p_new_status = 'resolved' THEN CURRENT_TIMESTAMP ELSE resolved_at END,
        updated_at = CURRENT_TIMESTAMP
    WHERE inquire_id = p_inquire_id;
    
    -- ログ記録
    INSERT INTO unified_logs (log_type, table_name, record_id, action_type, description, user_id, created_at)
    VALUES ('audit', 'inquires', p_inquire_id, 'UPDATE', 
            CONCAT('ステータス変更: ', old_status, ' → ', p_new_status), 
            p_assigned_to, NOW());
END$$

DELIMITER ;
