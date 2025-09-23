CREATE DATABASE IF NOT EXISTS newhptldb
  DEFAULT CHARACTER SET utf8mb4
  COLLATE utf8mb4_general_ci;

USE newhptldb;

-- 外部キー制約チェックを一時的に無効化（安全なテーブル削除のため）
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS hospital_types;
CREATE TABLE hospital_types (
    type_id varchar(11) PRIMARY KEY NOT NULL COMMENT '病院区分ID',
    type_name varchar(50) NOT NULL COMMENT '区分名',
    is_active boolean DEFAULT true COMMENT '有効フラグ',
    display_order int(11) AUTO_INCREMENT UNIQUE KEY COMMENT '表示順序'
) COMMENT = '病院の種別を管理するマスタテーブル（病院、特定機能病院など）';


DROP TABLE IF EXISTS hospitals;
CREATE TABLE hospitals (
    hospital_id varchar(10) PRIMARY KEY COMMENT '医療機関コード',
    hospital_type_id varchar(11) COMMENT '病院区分ID',
    hospital_name varchar(100) NOT NULL COMMENT '医療機関名',
    status enum('active','closed') DEFAULT 'active' COMMENT '運営状況',
    bed_count int(11) DEFAULT 0 COMMENT '許可病床数',
    has_pt boolean DEFAULT false COMMENT '理学療法士在籍フラグ',
    has_ot boolean DEFAULT false COMMENT '作業療法士在籍フラグ',
    has_st boolean DEFAULT false COMMENT '言語聴覚療法士在籍フラグ',
    notes text COMMENT '備考（基本情報）',
    created_at datetime DEFAULT CURRENT_TIMESTAMP COMMENT '作成日時',
    updated_at datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新日時',
    FOREIGN KEY (hospital_type_id) REFERENCES hospital_types(type_id)
) COMMENT = '医療機関の基本情報を格納するメインテーブル';

DROP TABLE IF EXISTS areas;
CREATE TABLE areas (
    area_id int(11) PRIMARY KEY NOT NULL COMMENT '地区コード',
    secondary_medical_area_name varchar(50) COMMENT '二次医療圏名',
    prefecture varchar(10) COMMENT '都道府県',
    city varchar(30) COMMENT '市',
    ward varchar(20) COMMENT '区',
    town varchar(30) COMMENT '町',
    is_active boolean DEFAULT true COMMENT '有効フラグ',
    display_order int(11) AUTO_INCREMENT UNIQUE KEY COMMENT '表示順序'
) COMMENT = '地域マスタ情報（旧areaテーブルの改良版）';

DROP TABLE IF EXISTS addresses;
CREATE TABLE addresses (
    address_id int(11) PRIMARY KEY AUTO_INCREMENT COMMENT '住所ID',
    hospital_id varchar(10) COMMENT '医療機関コード',
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
    hospital_id varchar(10) COMMENT '医療機関コード',
    phone varchar(20) COMMENT '電話番号',
    fax varchar(20) COMMENT 'FAX番号',
    email varchar(254) COMMENT 'メールアドレス',
    website varchar(500) COMMENT 'ウェブサイト',
    FOREIGN KEY (hospital_id) REFERENCES hospitals(hospital_id)
) COMMENT = '医療機関の連絡先情報を管理';

DROP TABLE IF EXISTS ward_types;
CREATE TABLE ward_types (
    ward_id varchar(10) PRIMARY KEY NOT NULL COMMENT '病棟種類ID',
    ward_name varchar(20) NOT NULL COMMENT '病棟名',
    is_active boolean DEFAULT true COMMENT '有効フラグ',
    display_order int(11) AUTO_INCREMENT UNIQUE KEY COMMENT '表示順序'
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
    hospital_id varchar(10) COMMENT '医療機関コード',
    role_type enum('chairman','director') NOT NULL COMMENT '役職種別（理事長・病院長）',
    staff_name varchar(60) NOT NULL COMMENT '氏名',
    specialty varchar(50) COMMENT '専門分野',
    graduation_year year(4) COMMENT '卒業年度',
    alma_mater varchar(100) COMMENT '出身校',
    notes text COMMENT '備考',
    FOREIGN KEY (hospital_id) REFERENCES hospitals(hospital_id)
) COMMENT = '理事長、病院長などの重要人物情報を管理';

DROP TABLE IF EXISTS consultation_hours;
CREATE TABLE consultation_hours (
    hospital_id varchar(10) COMMENT '医療機関コード',
    day_of_week enum('monday','tuesday','wednesday','thursday','friday','saturday','sunday','holiday') NOT NULL COMMENT '曜日',
    period enum('AM','PM','AM_PM') NOT NULL COMMENT '時間帯',
    is_available boolean DEFAULT true COMMENT '診療可否',
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
    is_active boolean DEFAULT true COMMENT '有効フラグ',
    display_order int(11) AUTO_INCREMENT UNIQUE KEY COMMENT '表示順序'
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
    service_code varchar(10) COMMENT '診療内容コード',
    service_division varchar(100) COMMENT '診療区分',
    service_category varchar(100) COMMENT '診療部門',
    service_name varchar(300) NOT NULL COMMENT '診療内容名',
    is_active boolean DEFAULT true COMMENT '有効フラグ',
    display_order int(11) AUTO_INCREMENT UNIQUE KEY COMMENT '表示順序',
    PRIMARY KEY (service_code, service_division)
) COMMENT = '提供可能な医療サービスを管理';

DROP TABLE IF EXISTS hospital_services;
CREATE TABLE hospital_services (
    hospital_id varchar(10) COMMENT '医療機関コード',
    service_id varchar(20) COMMENT '診療内容ID',
    notes text COMMENT '個別備考',
    PRIMARY KEY (hospital_id, service_id),
    FOREIGN KEY (hospital_id) REFERENCES hospitals(hospital_id)
) COMMENT = '医療機関が提供している診療内容を管理';

DROP TABLE IF EXISTS clinical_pathways;
CREATE TABLE clinical_pathways (
    clinical_pathway_id varchar(10) PRIMARY KEY COMMENT '連携パスID',
    path_name varchar(30) NOT NULL COMMENT '連携パス名',
    is_active boolean DEFAULT true COMMENT '有効フラグ',
    display_order int(11) AUTO_INCREMENT UNIQUE KEY COMMENT '表示順序'
) COMMENT = '地域連携クリニカルパス名を管理';

DROP TABLE IF EXISTS clinical_pathway_hospitals;
CREATE TABLE clinical_pathway_hospitals (
    hospital_id varchar(10) COMMENT '医療機関コード',
    clinical_pathway_id varchar(10) COMMENT '連携パスID',
    PRIMARY KEY (hospital_id, clinical_pathway_id),
    FOREIGN KEY (hospital_id) REFERENCES hospitals(hospital_id),
    FOREIGN KEY (clinical_pathway_id) REFERENCES clinical_pathways(clinical_pathway_id)
) COMMENT = '地域連携クリニカルパスの存在有無を管理';

DROP TABLE IF EXISTS carna_connects;
CREATE TABLE carna_connects (
    hospital_id varchar(10) PRIMARY KEY COMMENT '医療機関コード',
    is_deleted boolean DEFAULT false COMMENT '削除フラグ'
) COMMENT = 'カルナコネクトと連携しているかどうかを管理';

-- 川崎学園マスタテーブルを先に作成
DROP TABLE IF EXISTS kawasaki_university_facilities;
CREATE TABLE kawasaki_university_facilities (
    facility_id varchar(30) PRIMARY KEY COMMENT '所属施設ID',
    facility_name varchar(50) NOT NULL COMMENT '施設名',
    formal_name varchar(60) NOT NULL COMMENT '正式名称',
    abbreviation varchar(50) NOT NULL COMMENT '略称',
    is_active boolean DEFAULT true COMMENT '有効フラグ',
    display_order int(11) AUTO_INCREMENT UNIQUE KEY COMMENT '表示順序'
) COMMENT = '川崎学園の病院情報を管理（附属病院、総合医療センター、高齢者医療センター）';

DROP TABLE IF EXISTS kawasaki_university_departments;
CREATE TABLE kawasaki_university_departments (
    department_id varchar(30) PRIMARY KEY COMMENT '部署ID',
    department_name varchar(50) NOT NULL COMMENT '部署名',
    is_active boolean DEFAULT true COMMENT '有効フラグ',
    display_order int(11) AUTO_INCREMENT UNIQUE KEY COMMENT '表示順序'
) COMMENT = '川崎学園の部署情報を管理';

DROP TABLE IF EXISTS users;
CREATE TABLE users (
    user_id varchar(8) PRIMARY KEY COMMENT 'ユーザーID',
    username varchar(50) NOT NULL COMMENT 'ユーザー名',
    password_hash varchar(255) NOT NULL COMMENT 'パスワードハッシュ',
    facility_id varchar(30) COMMENT '所属施設',
    department_id varchar(30) COMMENT '所属部署',
    role enum('admin','editor','viewer') COMMENT '権限レベル',
    is_active boolean COMMENT 'アカウント有効フラグ',
    created_at datetime DEFAULT CURRENT_TIMESTAMP COMMENT '作成日時',
    updated_at datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新日時',
    last_login_at datetime DEFAULT NULL COMMENT '最終ログイン日時',
    FOREIGN KEY (facility_id) REFERENCES kawasaki_university_facilities(facility_id),
    FOREIGN KEY (department_id) REFERENCES kawasaki_university_departments(department_id)
) COMMENT = 'システム利用者の情報を管理';

DROP TABLE IF EXISTS unified_logs;
CREATE TABLE unified_logs (
    log_id bigint(20) PRIMARY KEY AUTO_INCREMENT COMMENT 'ログID',
    log_type enum('audit','login_attempt','access','security') NOT NULL COMMENT 'ログ種別',
    user_id varchar(8) COMMENT 'ユーザーID',
    session_id varchar(64) COMMENT 'セッションID',
    
    -- 監査ログ用フィールド
    table_name varchar(50) COMMENT '対象テーブル名（監査ログ用）',
    record_id varchar(50) COMMENT '対象レコードID（監査ログ用）',
    action_type enum('INSERT','UPDATE','DELETE') COMMENT '操作種別（監査ログ用）',
    old_values json COMMENT '変更前データ（監査ログ用）',
    new_values json COMMENT '変更後データ（監査ログ用）',
    
    -- アクセスログ用フィールド
    access_type enum('login','logout','page_access','api_access','download','upload','error') COMMENT 'アクセス種別',
    page_url varchar(500) COMMENT 'アクセスページURL',
    page_name varchar(100) COMMENT 'ページ名',
    http_method enum('GET','POST','PUT','DELETE','PATCH') COMMENT 'HTTPメソッド',
    request_params json COMMENT 'リクエストパラメータ',
    response_status int(11) COMMENT 'レスポンスステータス',
    response_time_ms int(11) COMMENT 'レスポンス時間（ミリ秒）',
    referer varchar(500) COMMENT 'リファラー',
    
    -- セキュリティログ用フィールド
    event_type enum('login_success','login_failure','password_change','account_lock','permission_denied','suspicious_access','data_export','admin_access') COMMENT 'セキュリティイベント種別',
    severity enum('low','medium','high','critical') DEFAULT 'medium' COMMENT '重要度',
    target_resource varchar(200) COMMENT '対象リソース',
    failure_reason varchar(200) COMMENT '失敗理由',
    
    -- 共通フィールド
    description text COMMENT 'イベント詳細・説明',
    ip_address varchar(45) COMMENT 'IPアドレス',
    user_agent text COMMENT 'ユーザーエージェント',
    facility_id varchar(30) COMMENT '所属施設ID',
    department_id varchar(30) COMMENT '所属部署ID',
    is_admin boolean DEFAULT false COMMENT '管理者フラグ',
    additional_data json COMMENT '追加データ・その他情報',
    created_at datetime DEFAULT CURRENT_TIMESTAMP COMMENT 'ログ記録日時',
    
    -- インデックス
    INDEX idx_log_type (log_type),
    INDEX idx_user_id (user_id),
    INDEX idx_action_type (action_type),
    INDEX idx_access_type (access_type),
    INDEX idx_event_type (event_type),
    INDEX idx_severity (severity),
    INDEX idx_created_at (created_at),
    INDEX idx_session_id (session_id),
    INDEX idx_ip_address (ip_address),
    INDEX idx_table_record (table_name, record_id),
    
    FOREIGN KEY (user_id) REFERENCES users(user_id)
) COMMENT = '統合ログテーブル（監査・アクセス・セキュリティ・ログイン試行すべてを管理）';

DROP TABLE IF EXISTS introductions;
CREATE TABLE introductions (
    hospital_id varchar(10) COMMENT '医療機関コード',
    user_id varchar(8) COMMENT 'ユーザーID',
    intro_type enum('intro','inverse_intro') DEFAULT 'intro' COMMENT '紹介・逆紹介判定',
    year year(4) COMMENT '年度',
    date date COMMENT '診療日',
    department_name varchar(30) COMMENT '診療科',
    department_code int(11) COMMENT '診療科コード',
    intro int(11) COMMENT '紹介・逆紹介件数',
    FOREIGN KEY (user_id) REFERENCES users(user_id)
) COMMENT = '医療機関間の紹介・逆紹介情報を管理';

-- 職名マスタテーブルを追加
DROP TABLE IF EXISTS positions;
CREATE TABLE positions (
    position_id varchar(20) PRIMARY KEY COMMENT '職名ID',
    position_name varchar(60) NOT NULL COMMENT '職名',
    is_active boolean DEFAULT true COMMENT '有効フラグ',
    display_order int(11) NOT NULL DEFAULT 0 COMMENT '表示順序'
) COMMENT = '職名マスタテーブル';

DROP TABLE IF EXISTS training;
CREATE TABLE training (
    hospital_id varchar(10) COMMENT '医療機関コード',
    user_id varchar(8) COMMENT 'ユーザーID',
    year year(4) COMMENT '年度',
    training_name varchar(200) COMMENT '研修先医療機関名',
    department varchar(60) COMMENT '診療科',
    staff_name varchar(60) COMMENT '氏名',
    start_date date COMMENT '診療支援開始日',
    end_date date COMMENT '診療支援終了日',
    date varchar(300) COMMENT '日付',
    diagnostic_aid varchar(50) COMMENT '診療支援区分',
    position varchar(30) COMMENT '職名',
    position_id varchar(20) COMMENT '職名ID',
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (position_id) REFERENCES positions(position_id)
) COMMENT = '院外診療支援・研修情報を管理';

DROP TABLE IF EXISTS contacts;
CREATE TABLE contacts (
    hospital_id varchar(10) COMMENT '医療機関コード',
    user_id varchar(8) COMMENT 'ユーザーID',
    hospital_name varchar(100) COMMENT '医療機関名',
    year year(4) COMMENT '年度',
    date date COMMENT '日付',
    method varchar(50) COMMENT '方法',
    external_department varchar(50) COMMENT '連携機関対応者部署',
    external_position varchar(50) COMMENT '連携機関対応者役職',
    external_contact_name varchar(10) COMMENT '連携機関対応者氏名',
    external_additional_participants varchar(100) COMMENT '連携機関対応人数・氏名',
    internal_department varchar(50) COMMENT '当院対応者所属',
    internal_contact_name varchar(10) COMMENT '当院対応者氏名',
    internal_additional_participants varchar(100) COMMENT '当院対応人数・氏名',
    detail varchar(100) COMMENT '内容',
    notes varchar(100) COMMENT '備考',
    data_department varchar(50) COMMENT 'データ部署',
    FOREIGN KEY (user_id) REFERENCES users(user_id)
) COMMENT = '医療機関同士のコンタクト履歴を保管';

-- 外部キー制約チェックを再度有効化
SET FOREIGN_KEY_CHECKS = 1;

-- =================================================================
-- 自動ログ記録用トリガー
-- 各テーブルのINSERT、UPDATE、DELETEを自動的にunified_logsに記録
-- =================================================================

-- hospitals テーブル用トリガー
DELIMITER $$
CREATE TRIGGER hospitals_insert_audit AFTER INSERT ON hospitals
FOR EACH ROW BEGIN
    INSERT INTO unified_logs (log_type, table_name, record_id, action_type, new_values, created_at)
    VALUES ('audit', 'hospitals', NEW.hospital_id, 'INSERT', 
            JSON_OBJECT('hospital_id', NEW.hospital_id, 'hospital_type_id', NEW.hospital_type_id, 
                       'hospital_name', NEW.hospital_name, 'status', NEW.status, 'bed_count', NEW.bed_count, 
                       'notes', NEW.notes, 'created_at', NEW.created_at, 'updated_at', NEW.updated_at),
            NOW());
END$$

CREATE TRIGGER hospitals_update_audit AFTER UPDATE ON hospitals
FOR EACH ROW BEGIN
    INSERT INTO unified_logs (log_type, table_name, record_id, action_type, old_values, new_values, created_at)
    VALUES ('audit', 'hospitals', NEW.hospital_id, 'UPDATE',
            JSON_OBJECT('hospital_id', OLD.hospital_id, 'hospital_type_id', OLD.hospital_type_id, 
                       'hospital_name', OLD.hospital_name, 'status', OLD.status, 'bed_count', OLD.bed_count, 
                       'notes', OLD.notes, 'created_at', OLD.created_at, 'updated_at', OLD.updated_at),
            JSON_OBJECT('hospital_id', NEW.hospital_id, 'hospital_type_id', NEW.hospital_type_id, 
                       'hospital_name', NEW.hospital_name, 'status', NEW.status, 'bed_count', NEW.bed_count, 
                       'notes', NEW.notes, 'created_at', NEW.created_at, 'updated_at', NEW.updated_at),
            NOW());
END$$

CREATE TRIGGER hospitals_delete_audit AFTER DELETE ON hospitals
FOR EACH ROW BEGIN
    INSERT INTO unified_logs (log_type, table_name, record_id, action_type, old_values, created_at)
    VALUES ('audit', 'hospitals', OLD.hospital_id, 'DELETE',
            JSON_OBJECT('hospital_id', OLD.hospital_id, 'hospital_type_id', OLD.hospital_type_id, 
                       'hospital_name', OLD.hospital_name, 'status', OLD.status, 'bed_count', OLD.bed_count, 
                       'notes', OLD.notes, 'created_at', OLD.created_at, 'updated_at', OLD.updated_at),
            NOW());
END$$

-- users テーブル用トリガー
CREATE TRIGGER users_insert_audit AFTER INSERT ON users
FOR EACH ROW BEGIN
    INSERT INTO unified_logs (log_type, table_name, record_id, action_type, new_values, user_id, created_at)
    VALUES ('audit', 'users', NEW.user_id, 'INSERT', 
            JSON_OBJECT('user_id', NEW.user_id, 'username', NEW.username, 'facility_id', NEW.facility_id, 
                       'department_id', NEW.department_id, 'role', NEW.role, 'is_active', NEW.is_active,
                       'created_at', NEW.created_at, 'updated_at', NEW.updated_at, 'last_login_at', NEW.last_login_at),
            NEW.user_id, NOW());
END$$

CREATE TRIGGER users_update_audit AFTER UPDATE ON users
FOR EACH ROW BEGIN
    INSERT INTO unified_logs (log_type, table_name, record_id, action_type, old_values, new_values, user_id, created_at)
    VALUES ('audit', 'users', NEW.user_id, 'UPDATE',
            JSON_OBJECT('user_id', OLD.user_id, 'username', OLD.username, 'facility_id', OLD.facility_id, 
                       'department_id', OLD.department_id, 'role', OLD.role, 'is_active', OLD.is_active,
                       'created_at', OLD.created_at, 'updated_at', OLD.updated_at, 'last_login_at', OLD.last_login_at),
            JSON_OBJECT('user_id', NEW.user_id, 'username', NEW.username, 'facility_id', NEW.facility_id, 
                       'department_id', NEW.department_id, 'role', NEW.role, 'is_active', NEW.is_active,
                       'created_at', NEW.created_at, 'updated_at', NEW.updated_at, 'last_login_at', NEW.last_login_at),
            NEW.user_id, NOW());
END$$

CREATE TRIGGER users_delete_audit AFTER DELETE ON users
FOR EACH ROW BEGIN
    INSERT INTO unified_logs (log_type, table_name, record_id, action_type, old_values, created_at)
    VALUES ('audit', 'users', OLD.user_id, 'DELETE',
            JSON_OBJECT('user_id', OLD.user_id, 'username', OLD.username, 'facility_id', OLD.facility_id, 
                       'department_id', OLD.department_id, 'role', OLD.role, 'is_active', OLD.is_active,
                       'created_at', OLD.created_at, 'updated_at', OLD.updated_at, 'last_login_at', OLD.last_login_at),
            NOW());
END$$

-- contact_details テーブル用トリガー
CREATE TRIGGER contact_details_insert_audit AFTER INSERT ON contact_details
FOR EACH ROW BEGIN
    INSERT INTO unified_logs (log_type, table_name, record_id, action_type, new_values, created_at)
    VALUES ('audit', 'contact_details', NEW.contact_id, 'INSERT', 
            JSON_OBJECT('contact_id', NEW.contact_id, 'hospital_id', NEW.hospital_id, 'phone', NEW.phone, 
                       'fax', NEW.fax, 'email', NEW.email, 'website', NEW.website),
            NOW());
END$$

CREATE TRIGGER contact_details_update_audit AFTER UPDATE ON contact_details
FOR EACH ROW BEGIN
    INSERT INTO unified_logs (log_type, table_name, record_id, action_type, old_values, new_values, created_at)
    VALUES ('audit', 'contact_details', NEW.contact_id, 'UPDATE',
            JSON_OBJECT('contact_id', OLD.contact_id, 'hospital_id', OLD.hospital_id, 'phone', OLD.phone, 
                       'fax', OLD.fax, 'email', OLD.email, 'website', OLD.website),
            JSON_OBJECT('contact_id', NEW.contact_id, 'hospital_id', NEW.hospital_id, 'phone', NEW.phone, 
                       'fax', NEW.fax, 'email', NEW.email, 'website', NEW.website),
            NOW());
END$$

CREATE TRIGGER contact_details_delete_audit AFTER DELETE ON contact_details
FOR EACH ROW BEGIN
    INSERT INTO unified_logs (log_type, table_name, record_id, action_type, old_values, created_at)
    VALUES ('audit', 'contact_details', OLD.contact_id, 'DELETE',
            JSON_OBJECT('contact_id', OLD.contact_id, 'hospital_id', OLD.hospital_id, 'phone', OLD.phone, 
                       'fax', OLD.fax, 'email', OLD.email, 'website', OLD.website),
            NOW());
END$$

-- hospital_staffs テーブル用トリガー
CREATE TRIGGER hospital_staffs_insert_audit AFTER INSERT ON hospital_staffs
FOR EACH ROW BEGIN
    INSERT INTO unified_logs (log_type, table_name, record_id, action_type, new_values, created_at)
    VALUES ('audit', 'hospital_staffs', NEW.staff_id, 'INSERT', 
            JSON_OBJECT('staff_id', NEW.staff_id, 'hospital_id', NEW.hospital_id, 'role_type', NEW.role_type, 
                       'staff_name', NEW.staff_name, 'specialty', NEW.specialty, 'graduation_year', NEW.graduation_year, 
                       'alma_mater', NEW.alma_mater, 'notes', NEW.notes),
            NOW());
END$$

CREATE TRIGGER hospital_staffs_update_audit AFTER UPDATE ON hospital_staffs
FOR EACH ROW BEGIN
    INSERT INTO unified_logs (log_type, table_name, record_id, action_type, old_values, new_values, created_at)
    VALUES ('audit', 'hospital_staffs', NEW.staff_id, 'UPDATE',
            JSON_OBJECT('staff_id', OLD.staff_id, 'hospital_id', OLD.hospital_id, 'role_type', OLD.role_type, 
                       'staff_name', OLD.staff_name, 'specialty', OLD.specialty, 'graduation_year', OLD.graduation_year, 
                       'alma_mater', OLD.alma_mater, 'notes', OLD.notes),
            JSON_OBJECT('staff_id', NEW.staff_id, 'hospital_id', NEW.hospital_id, 'role_type', NEW.role_type, 
                       'staff_name', NEW.staff_name, 'specialty', NEW.specialty, 'graduation_year', NEW.graduation_year, 
                       'alma_mater', NEW.alma_mater, 'notes', NEW.notes),
            NOW());
END$$

CREATE TRIGGER hospital_staffs_delete_audit AFTER DELETE ON hospital_staffs
FOR EACH ROW BEGIN
    INSERT INTO unified_logs (log_type, table_name, record_id, action_type, old_values, created_at)
    VALUES ('audit', 'hospital_staffs', OLD.staff_id, 'DELETE',
            JSON_OBJECT('staff_id', OLD.staff_id, 'hospital_id', OLD.hospital_id, 'role_type', OLD.role_type, 
                       'staff_name', OLD.staff_name, 'specialty', OLD.specialty, 'graduation_year', OLD.graduation_year, 
                       'alma_mater', OLD.alma_mater, 'notes', OLD.notes),
            NOW());
END$$

-- introductions テーブル用トリガー
CREATE TRIGGER introductions_insert_audit AFTER INSERT ON introductions
FOR EACH ROW BEGIN
    INSERT INTO unified_logs (log_type, table_name, record_id, action_type, new_values, user_id, created_at)
    VALUES ('audit', 'introductions', CONCAT(NEW.hospital_id, '_', NEW.user_id, '_', NEW.year, '_', NEW.date), 'INSERT', 
            JSON_OBJECT('hospital_id', NEW.hospital_id, 'user_id', NEW.user_id, 'intro_type', NEW.intro_type, 
                       'year', NEW.year, 'date', NEW.date, 'department_name', NEW.department_name, 
                       'department_code', NEW.department_code, 'intro', NEW.intro),
            NEW.user_id, NOW());
END$$

CREATE TRIGGER introductions_update_audit AFTER UPDATE ON introductions
FOR EACH ROW BEGIN
    INSERT INTO unified_logs (log_type, table_name, record_id, action_type, old_values, new_values, user_id, created_at)
    VALUES ('audit', 'introductions', CONCAT(NEW.hospital_id, '_', NEW.user_id, '_', NEW.year, '_', NEW.date), 'UPDATE',
            JSON_OBJECT('hospital_id', OLD.hospital_id, 'user_id', OLD.user_id, 'intro_type', OLD.intro_type, 
                       'year', OLD.year, 'date', OLD.date, 'department_name', OLD.department_name, 
                       'department_code', OLD.department_code, 'intro', OLD.intro),
            JSON_OBJECT('hospital_id', NEW.hospital_id, 'user_id', NEW.user_id, 'intro_type', NEW.intro_type, 
                       'year', NEW.year, 'date', NEW.date, 'department_name', NEW.department_name, 
                       'department_code', NEW.department_code, 'intro', NEW.intro),
            NEW.user_id, NOW());
END$$

CREATE TRIGGER introductions_delete_audit AFTER DELETE ON introductions
FOR EACH ROW BEGIN
    INSERT INTO unified_logs (log_type, table_name, record_id, action_type, old_values, created_at)
    VALUES ('audit', 'introductions', CONCAT(OLD.hospital_id, '_', OLD.user_id, '_', OLD.year, '_', OLD.date), 'DELETE',
            JSON_OBJECT('hospital_id', OLD.hospital_id, 'user_id', OLD.user_id, 'intro_type', OLD.intro_type, 
                       'year', OLD.year, 'date', OLD.date, 'department_name', OLD.department_name, 
                       'department_code', OLD.department_code, 'intro', OLD.intro),
            NOW());
END$$

DELIMITER ;

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

-- アクセス統計ビュー
CREATE VIEW access_summary AS
SELECT 
    DATE(created_at) as access_date,
    access_type,
    COUNT(*) as access_count,
    COUNT(DISTINCT user_id) as unique_users,
    COUNT(DISTINCT ip_address) as unique_ips
FROM unified_logs 
WHERE log_type = 'access' 
   AND created_at >= DATE_SUB(NOW(), INTERVAL 30 DAY)
GROUP BY DATE(created_at), access_type
ORDER BY access_date DESC, access_type;

-- セキュリティアラートビュー
CREATE VIEW security_alerts AS
SELECT 
    ul.*,
    u.username,
    u.facility_id,
    u.department_id
FROM unified_logs ul
LEFT JOIN users u ON ul.user_id = u.user_id
WHERE ul.log_type = 'security'
   AND (ul.severity IN ('high', 'critical')
        OR ul.event_type IN ('login_failure', 'permission_denied', 'suspicious_access'))
ORDER BY ul.created_at DESC;

-- ユーザーアクティビティビュー
CREATE VIEW user_activity AS
SELECT 
    u.user_id,
    u.username,
    u.facility_id,
    u.department_id,
    COUNT(DISTINCT DATE(ul.created_at)) as active_days,
    COUNT(ul.log_id) as total_accesses,
    MAX(ul.created_at) as last_access,
    COUNT(CASE WHEN ul.access_type = 'login' THEN 1 END) as login_count
FROM users u
LEFT JOIN unified_logs ul ON u.user_id = ul.user_id 
WHERE ul.log_type = 'access'
   AND ul.created_at >= DATE_SUB(NOW(), INTERVAL 30 DAY)
GROUP BY u.user_id, u.username, u.facility_id, u.department_id
ORDER BY last_access DESC;

-- ログイン試行統計ビュー
CREATE VIEW login_attempt_summary AS
SELECT 
    DATE(created_at) as attempt_date,
    event_type,
    COUNT(*) as attempt_count,
    COUNT(DISTINCT user_id) as unique_users,
    COUNT(DISTINCT ip_address) as unique_ips
FROM unified_logs 
WHERE log_type = 'login_attempt'
   AND created_at >= DATE_SUB(NOW(), INTERVAL 30 DAY)
GROUP BY DATE(created_at), event_type
ORDER BY attempt_date DESC, event_type;
