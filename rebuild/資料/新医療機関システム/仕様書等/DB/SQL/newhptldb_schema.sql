CREATE DATABASE IF NOT EXISTS newhptldb
  DEFAULT CHARACTER SET utf8mb4
  COLLATE utf8mb4_general_ci;

USE newhptldb;

-- 外部キー制約チェックを一時的に無効化（安全なテーブル削除のため）
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS hospital_types;
CREATE TABLE hospital_types (
    type_id varchar(11) PRIMARY KEY NOT NULL COMMENT '病院区分ID',
    type_name varchar(50) NOT NULL COMMENT '区分名'
) COMMENT = '病院の種別を管理するマスタテーブル（病院、特定機能病院など）';


DROP TABLE IF EXISTS hospitals;
CREATE TABLE hospitals (
    hospital_id varchar(10) PRIMARY KEY COMMENT '医療機関コード',
    hospital_type_id varchar(11) COMMENT '病院区分ID',
    hospital_name varchar(100) NOT NULL COMMENT '医療機関名',
    status enum('active','closed') COMMENT '運営状況',
    bed int(11) COMMENT '許可病床数',
    notes text COMMENT '備考（基本情報）',
    created_at datetime DEFAULT CURRENT_TIMESTAMP COMMENT '作成日時',
    updated_at datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新日時',
    FOREIGN KEY (hospital_type_id) REFERENCES hospital_types(type_id)
) COMMENT = '医療機関の基本情報を格納するメインテーブル';

DROP TABLE IF EXISTS areas;
CREATE TABLE areas (
    area_id int(11) PRIMARY KEY AUTO_INCREMENT COMMENT '地域ID',
    area_code int(11) NOT NULL UNIQUE COMMENT '地区コード',
    secondary_medical_area_code int(11) COMMENT '二次医療圏コード',
    secondary_medical_area_name varchar(50) COMMENT '二次医療圏名',
    search_area_name varchar(50) COMMENT '検索用地域名',
    display_area_name varchar(50) COMMENT '表示用地域名',
    city varchar(30) COMMENT '市',
    ward varchar(20) COMMENT '区',
    town varchar(30) COMMENT '町'
) COMMENT = '地域マスタ情報（旧areaテーブルの改良版）';

DROP TABLE IF EXISTS addresses;
CREATE TABLE addresses (
    address_id int(11) PRIMARY KEY AUTO_INCREMENT COMMENT '住所ID',
    hospital_id varchar(10) COMMENT '医療機関コード',
    area_code int(11) COMMENT '地区コード（areasテーブル参照）',
    postal_code varchar(7) COMMENT '郵便番号',
    street_number varchar(200) COMMENT '番地',
    full_address varchar(400) COMMENT '完全住所',
    FOREIGN KEY (hospital_id) REFERENCES hospitals(hospital_id),
    FOREIGN KEY (area_code) REFERENCES areas(area_code)
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

DROP TABLE IF EXISTS hospital_staff;
CREATE TABLE hospital_staff (
    staff_id int(11) PRIMARY KEY AUTO_INCREMENT COMMENT 'スタッフ管理ID',
    hospital_id varchar(10) COMMENT '医療機関コード',
    role_type enum('chairman','director') NOT NULL COMMENT '役職種別（理事長・病院長）',
    name varchar(60) NOT NULL COMMENT '氏名',
    specialty varchar(50) COMMENT '専門分野',
    graduation_year year(4) COMMENT '卒業年度',
    alma_mater varchar(100) COMMENT '出身校',
    notes text COMMENT '備考',
    FOREIGN KEY (hospital_id) REFERENCES hospitals(hospital_id)
) COMMENT = '理事長、病院長などの重要人物情報を管理';

-- DROP TABLE IF EXISTS medical_association;
-- CREATE TABLE medical_association (
--     section_id int(11) PRIMARY KEY AUTO_INCREMENT COMMENT '区分コード',
--     area_id varchar(20) /* FOREIGN KEY */ COMMENT '地域コード',
--     med_area varchar(60) NOT NULL COMMENT '二次医療圏',
--     med_association varchar(60) NOT NULL COMMENT '医師会名'
-- ) COMMENT = '医師会についての情報を管理';

DROP TABLE IF EXISTS consultation_hours;
CREATE TABLE consultation_hours (
    schedule_id int(11) PRIMARY KEY AUTO_INCREMENT COMMENT 'スケジュールID',
    hospital_id varchar(10) COMMENT '医療機関コード',
    day_of_week enum('monday','tuesday','wednesday','thursday','friday','saturday','sunday','holiday') NOT NULL COMMENT '曜日',
    period enum('AM','PM','AM_PM') NOT NULL COMMENT '時間帯',
    is_available boolean COMMENT '診療可否',
    start_time time COMMENT '開始時間',
    end_time time COMMENT '終了時間',
    notes varchar(200) COMMENT '備考',
    FOREIGN KEY (hospital_id) REFERENCES hospitals(hospital_id)
) COMMENT = '医療機関の診療時間を管理';

DROP TABLE IF EXISTS medical_departments;
CREATE TABLE medical_departments (
    department_id int(11) PRIMARY KEY AUTO_INCREMENT COMMENT '診療科ID',
    department_code varchar(10) NOT NULL UNIQUE COMMENT '診療科コード',
    department_name varchar(100) NOT NULL COMMENT '診療科名',
    category varchar(100) NOT NULL COMMENT '診療科カテゴリ名'
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
    relation_id int(11) PRIMARY KEY AUTO_INCREMENT COMMENT '関連ID',
    hospital_id varchar(10) COMMENT '医療機関コード',
    department_id int(11) COMMENT '診療科ID',
    FOREIGN KEY (hospital_id) REFERENCES hospitals(hospital_id),
    FOREIGN KEY (department_id) REFERENCES medical_departments(department_id)
) COMMENT = '医療機関が対応している診療科を管理';

-- 先に医療サービスマスタを作成
DROP TABLE IF EXISTS medical_services;
CREATE TABLE medical_services (
    service_id varchar(10) PRIMARY KEY COMMENT '診療内容コード',
    service_division varchar(100) COMMENT '診療区分',
    service_category varchar(100) COMMENT '診療部門',
    service_name varchar(300) NOT NULL COMMENT '診療内容名'
) COMMENT = '提供可能な医療サービスを管理';

DROP TABLE IF EXISTS hospital_services;
CREATE TABLE hospital_services (
    hospital_id varchar(10) COMMENT '医療機関コード',
    service_id varchar(10) COMMENT '診療内容ID',
    notes text COMMENT '個別備考',
    PRIMARY KEY (hospital_id, service_id),
    FOREIGN KEY (hospital_id) REFERENCES hospitals(hospital_id),
    FOREIGN KEY (service_id) REFERENCES medical_services(service_id)
) COMMENT = '医療機関が提供している診療内容を管理';

DROP TABLE IF EXISTS carna_connect;
CREATE TABLE carna_connect (
    hospital_id varchar(10) PRIMARY KEY COMMENT '医療機関コード',
    is_deleted boolean DEFAULT false COMMENT '削除フラグ'
) COMMENT = 'カルナコネクトと連携しているかどうかを管理';

-- 川崎学園マスタテーブルを先に作成
DROP TABLE IF EXISTS kawasaki_university_facility;
CREATE TABLE kawasaki_university_facility (
    facility_id varchar(30) PRIMARY KEY COMMENT '所属施設ID',
    name varchar(50) NOT NULL COMMENT '施設名',
    formal_name varchar(60) NOT NULL COMMENT '正式名称',
    abbreviation varchar(50) NOT NULL COMMENT '略称'
) COMMENT = '川崎学園の病院情報を管理（附属病院、総合医療センター、高齢者医療センター）';

DROP TABLE IF EXISTS kawasaki_university_department;
CREATE TABLE kawasaki_university_department (
    department_id varchar(30) PRIMARY KEY COMMENT '部署ID',
    name varchar(50) NOT NULL COMMENT '部署名'
) COMMENT = '川崎学園の部署情報を管理';

DROP TABLE IF EXISTS users;
CREATE TABLE users (
    user_id varchar(8) PRIMARY KEY COMMENT 'ユーザーID',
    user_name varchar(50) NOT NULL COMMENT 'ユーザー名',
    pwd_hash varchar(255) NOT NULL COMMENT 'パスワードハッシュ',
    facility_id varchar(30) COMMENT '所属施設',
    department_id varchar(30) COMMENT '所属部署',
    role enum('admin','editor','viewer') COMMENT '権限レベル',
    is_active boolean COMMENT 'アカウント有効フラグ',
    created_at datetime DEFAULT CURRENT_TIMESTAMP COMMENT '作成日時',
    updated_at datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新日時',
    last_login_at datetime DEFAULT NULL COMMENT '最終ログイン日時',
    FOREIGN KEY (facility_id) REFERENCES kawasaki_university_facility(facility_id),
    FOREIGN KEY (department_id) REFERENCES kawasaki_university_department(department_id)
) COMMENT = 'システム利用者の情報を管理';

DROP TABLE IF EXISTS audit_logs;
CREATE TABLE audit_logs (
    log_id bigint(20) PRIMARY KEY AUTO_INCREMENT COMMENT 'ログID',
    table_name varchar(50) NOT NULL COMMENT '対象テーブル名',
    record_id varchar(50) NOT NULL COMMENT '対象レコードID',
    action_type enum('INSERT','UPDATE','DELETE') NOT NULL COMMENT '操作種別',
    old_values json COMMENT '変更前データ',
    new_values json COMMENT '変更後データ',
    user_id varchar(8) COMMENT '操作者ID',
    is_admin boolean COMMENT '管理者フラグ',
    created_at datetime DEFAULT CURRENT_TIMESTAMP COMMENT '操作日時',
    ip_address varchar(45) COMMENT 'IPアドレス',
    user_agent text COMMENT 'ユーザーエージェント',
    FOREIGN KEY (user_id) REFERENCES users(user_id)
) COMMENT = 'データ変更の監査ログを統合管理';

DROP TABLE IF EXISTS `login_attempts`;
CREATE TABLE IF NOT EXISTS `login_attempts` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `key_name` varchar(128) NOT NULL COMMENT 'ユーザーID',
  `attempted` datetime NOT NULL DEFAULT current_timestamp() COMMENT '日時',
  PRIMARY KEY (`id`),
  KEY `key_name` (`key_name`),
  KEY `attempted` (`attempted`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='ログイン試行制限用テーブル';

-- DROP TABLE IF EXISTS documents;
-- CREATE TABLE documents (
--     document_id int(11) PRIMARY KEY AUTO_INCREMENT COMMENT 'ドキュメントID',
--     document_type enum('message','maintenance','qa','manual','other') NOT NULL COMMENT 'ドキュメント種別',
--     title varchar(200) NOT NULL COMMENT 'タイトル',
--     content text COMMENT '内容',
--     status enum('draft','published','archived') COMMENT 'ステータス',
--     priority enum('low','normal','high','urgent') COMMENT '優先度',
--     target_facility varchar(50) COMMENT '対象施設',
--     target_department varchar(50) COMMENT '対象部署',
--     target_version varchar(50) COMMENT '対象システムバージョン',
--     published_date date COMMENT '公開日',
--     effective_start_date date COMMENT '有効開始日',
--     effective_end_date date COMMENT '有効終了日',
--     author_user_id varchar(10) /* FOREIGN KEY */ COMMENT '作成者ID',
--     is_visible boolean COMMENT '表示フラグ',
--     created_at timestamp COMMENT '作成日時',
--     updated_at timestamp COMMENT '更新日時'
-- ) COMMENT = 'システム関連ドキュメントを統合管理';

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

DROP TABLE IF EXISTS training;
CREATE TABLE training (
    hospital_id varchar(10) COMMENT '医療機関コード',
    user_id varchar(8) COMMENT 'ユーザーID',
    year year(4) COMMENT '年度',
    training_name varchar(200) COMMENT '研修先医療機関名',
    department varchar(60) COMMENT '診療科',
    name varchar(60) COMMENT '氏名',
    start_date date COMMENT '診療支援開始日',
    end_date date COMMENT '診療支援終了日',
    date varchar(300) COMMENT '日付',
    diagnostic_aid varchar(50) COMMENT '診療支援区分',
    occ varchar(30) COMMENT '職名',
    FOREIGN KEY (user_id) REFERENCES users(user_id)
) COMMENT = '院外診療支援・研修情報を管理';

DROP TABLE IF EXISTS contact;
CREATE TABLE contact (
    hospital_id varchar(10) COMMENT '医療機関コード',
    user_id varchar(8) COMMENT 'ユーザーID',
    hospital_name varchar(100) COMMENT '医療機関名',
    year year(4) COMMENT '年度',
    date date COMMENT '日付',
    method varchar(50) COMMENT '方法',
    ex_department varchar(50) COMMENT '連携機関対応者部署',
    ex_position varchar(50) COMMENT '連携機関対応者役職',
    ex_name varchar(10) COMMENT '連携機関対応者氏名',
    ex_subnames varchar(100) COMMENT '連携機関対応人数・氏名',
    in_department varchar(50) COMMENT '当院対応者所属',
    in_name varchar(10) COMMENT '当院対応者氏名',
    in_subnames varchar(100) COMMENT '当院対応人数・氏名',
    detail varchar(100) COMMENT '内容',
    notes varchar(100) COMMENT '備考',
    data_department varchar(50) COMMENT 'データ部署',
    FOREIGN KEY (user_id) REFERENCES users(user_id)
) COMMENT = '医療機関同士のコンタクト履歴を保管';

-- 外部キー制約チェックを再度有効化
SET FOREIGN_KEY_CHECKS = 1;

-- =================================================================
-- 自動ログ記録用トリガー
-- 各テーブルのINSERT、UPDATE、DELETEを自動的にaudit_logsに記録
-- =================================================================

-- hospitals テーブル用トリガー
DELIMITER $$
CREATE TRIGGER hospitals_insert_audit AFTER INSERT ON hospitals
FOR EACH ROW BEGIN
    INSERT INTO audit_logs (table_name, record_id, action_type, new_values, created_at)
    VALUES ('hospitals', NEW.hospital_id, 'INSERT', 
            JSON_OBJECT('hospital_id', NEW.hospital_id, 'hospital_type_id', NEW.hospital_type_id, 
                       'hospital_name', NEW.hospital_name, 'status', NEW.status, 'bed', NEW.bed, 
                       'notes', NEW.notes, 'created_at', NEW.created_at, 'updated_at', NEW.updated_at),
            NOW());
END$$

CREATE TRIGGER hospitals_update_audit AFTER UPDATE ON hospitals
FOR EACH ROW BEGIN
    INSERT INTO audit_logs (table_name, record_id, action_type, old_values, new_values, created_at)
    VALUES ('hospitals', NEW.hospital_id, 'UPDATE',
            JSON_OBJECT('hospital_id', OLD.hospital_id, 'hospital_type_id', OLD.hospital_type_id, 
                       'hospital_name', OLD.hospital_name, 'status', OLD.status, 'bed', OLD.bed, 
                       'notes', OLD.notes, 'created_at', OLD.created_at, 'updated_at', OLD.updated_at),
            JSON_OBJECT('hospital_id', NEW.hospital_id, 'hospital_type_id', NEW.hospital_type_id, 
                       'hospital_name', NEW.hospital_name, 'status', NEW.status, 'bed', NEW.bed, 
                       'notes', NEW.notes, 'created_at', NEW.created_at, 'updated_at', NEW.updated_at),
            NOW());
END$$

CREATE TRIGGER hospitals_delete_audit AFTER DELETE ON hospitals
FOR EACH ROW BEGIN
    INSERT INTO audit_logs (table_name, record_id, action_type, old_values, created_at)
    VALUES ('hospitals', OLD.hospital_id, 'DELETE',
            JSON_OBJECT('hospital_id', OLD.hospital_id, 'hospital_type_id', OLD.hospital_type_id, 
                       'hospital_name', OLD.hospital_name, 'status', OLD.status, 'bed', OLD.bed, 
                       'notes', OLD.notes, 'created_at', OLD.created_at, 'updated_at', OLD.updated_at),
            NOW());
END$$

-- users テーブル用トリガー
CREATE TRIGGER users_insert_audit AFTER INSERT ON users
FOR EACH ROW BEGIN
    INSERT INTO audit_logs (table_name, record_id, action_type, new_values, user_id, created_at)
    VALUES ('users', NEW.user_id, 'INSERT', 
            JSON_OBJECT('user_id', NEW.user_id, 'user_name', NEW.user_name, 'facility_id', NEW.facility_id, 
                       'department_id', NEW.department_id, 'role', NEW.role, 'is_active', NEW.is_active,
                       'created_at', NEW.created_at, 'updated_at', NEW.updated_at, 'last_login_at', NEW.last_login_at),
            NEW.user_id, NOW());
END$$

CREATE TRIGGER users_update_audit AFTER UPDATE ON users
FOR EACH ROW BEGIN
    INSERT INTO audit_logs (table_name, record_id, action_type, old_values, new_values, user_id, created_at)
    VALUES ('users', NEW.user_id, 'UPDATE',
            JSON_OBJECT('user_id', OLD.user_id, 'user_name', OLD.user_name, 'facility_id', OLD.facility_id, 
                       'department_id', OLD.department_id, 'role', OLD.role, 'is_active', OLD.is_active,
                       'created_at', OLD.created_at, 'updated_at', OLD.updated_at, 'last_login_at', OLD.last_login_at),
            JSON_OBJECT('user_id', NEW.user_id, 'user_name', NEW.user_name, 'facility_id', NEW.facility_id, 
                       'department_id', NEW.department_id, 'role', NEW.role, 'is_active', NEW.is_active,
                       'created_at', NEW.created_at, 'updated_at', NEW.updated_at, 'last_login_at', NEW.last_login_at),
            NEW.user_id, NOW());
END$$

CREATE TRIGGER users_delete_audit AFTER DELETE ON users
FOR EACH ROW BEGIN
    INSERT INTO audit_logs (table_name, record_id, action_type, old_values, created_at)
    VALUES ('users', OLD.user_id, 'DELETE',
            JSON_OBJECT('user_id', OLD.user_id, 'user_name', OLD.user_name, 'facility_id', OLD.facility_id, 
                       'department_id', OLD.department_id, 'role', OLD.role, 'is_active', OLD.is_active,
                       'created_at', OLD.created_at, 'updated_at', OLD.updated_at, 'last_login_at', OLD.last_login_at),
            NOW());
END$$

-- contact_details テーブル用トリガー
CREATE TRIGGER contact_details_insert_audit AFTER INSERT ON contact_details
FOR EACH ROW BEGIN
    INSERT INTO audit_logs (table_name, record_id, action_type, new_values, created_at)
    VALUES ('contact_details', NEW.contact_id, 'INSERT', 
            JSON_OBJECT('contact_id', NEW.contact_id, 'hospital_id', NEW.hospital_id, 'phone', NEW.phone, 
                       'fax', NEW.fax, 'email', NEW.email, 'website', NEW.website),
            NOW());
END$$

CREATE TRIGGER contact_details_update_audit AFTER UPDATE ON contact_details
FOR EACH ROW BEGIN
    INSERT INTO audit_logs (table_name, record_id, action_type, old_values, new_values, created_at)
    VALUES ('contact_details', NEW.contact_id, 'UPDATE',
            JSON_OBJECT('contact_id', OLD.contact_id, 'hospital_id', OLD.hospital_id, 'phone', OLD.phone, 
                       'fax', OLD.fax, 'email', OLD.email, 'website', OLD.website),
            JSON_OBJECT('contact_id', NEW.contact_id, 'hospital_id', NEW.hospital_id, 'phone', NEW.phone, 
                       'fax', NEW.fax, 'email', NEW.email, 'website', NEW.website),
            NOW());
END$$

CREATE TRIGGER contact_details_delete_audit AFTER DELETE ON contact_details
FOR EACH ROW BEGIN
    INSERT INTO audit_logs (table_name, record_id, action_type, old_values, created_at)
    VALUES ('contact_details', OLD.contact_id, 'DELETE',
            JSON_OBJECT('contact_id', OLD.contact_id, 'hospital_id', OLD.hospital_id, 'phone', OLD.phone, 
                       'fax', OLD.fax, 'email', OLD.email, 'website', OLD.website),
            NOW());
END$$

-- hospital_staff テーブル用トリガー
CREATE TRIGGER hospital_staff_insert_audit AFTER INSERT ON hospital_staff
FOR EACH ROW BEGIN
    INSERT INTO audit_logs (table_name, record_id, action_type, new_values, created_at)
    VALUES ('hospital_staff', NEW.staff_id, 'INSERT', 
            JSON_OBJECT('staff_id', NEW.staff_id, 'hospital_id', NEW.hospital_id, 'role_type', NEW.role_type, 
                       'name', NEW.name, 'specialty', NEW.specialty, 'graduation_year', NEW.graduation_year, 
                       'alma_mater', NEW.alma_mater, 'notes', NEW.notes),
            NOW());
END$$

CREATE TRIGGER hospital_staff_update_audit AFTER UPDATE ON hospital_staff
FOR EACH ROW BEGIN
    INSERT INTO audit_logs (table_name, record_id, action_type, old_values, new_values, created_at)
    VALUES ('hospital_staff', NEW.staff_id, 'UPDATE',
            JSON_OBJECT('staff_id', OLD.staff_id, 'hospital_id', OLD.hospital_id, 'role_type', OLD.role_type, 
                       'name', OLD.name, 'specialty', OLD.specialty, 'graduation_year', OLD.graduation_year, 
                       'alma_mater', OLD.alma_mater, 'notes', OLD.notes),
            JSON_OBJECT('staff_id', NEW.staff_id, 'hospital_id', NEW.hospital_id, 'role_type', NEW.role_type, 
                       'name', NEW.name, 'specialty', NEW.specialty, 'graduation_year', NEW.graduation_year, 
                       'alma_mater', NEW.alma_mater, 'notes', NEW.notes),
            NOW());
END$$

CREATE TRIGGER hospital_staff_delete_audit AFTER DELETE ON hospital_staff
FOR EACH ROW BEGIN
    INSERT INTO audit_logs (table_name, record_id, action_type, old_values, created_at)
    VALUES ('hospital_staff', OLD.staff_id, 'DELETE',
            JSON_OBJECT('staff_id', OLD.staff_id, 'hospital_id', OLD.hospital_id, 'role_type', OLD.role_type, 
                       'name', OLD.name, 'specialty', OLD.specialty, 'graduation_year', OLD.graduation_year, 
                       'alma_mater', OLD.alma_mater, 'notes', OLD.notes),
            NOW());
END$$

-- introductions テーブル用トリガー
CREATE TRIGGER introductions_insert_audit AFTER INSERT ON introductions
FOR EACH ROW BEGIN
    INSERT INTO audit_logs (table_name, record_id, action_type, new_values, user_id, created_at)
    VALUES ('introductions', CONCAT(NEW.hospital_id, '_', NEW.user_id, '_', NEW.year, '_', NEW.date), 'INSERT', 
            JSON_OBJECT('hospital_id', NEW.hospital_id, 'user_id', NEW.user_id, 'intro_type', NEW.intro_type, 
                       'year', NEW.year, 'date', NEW.date, 'department_name', NEW.department_name, 
                       'department_code', NEW.department_code, 'intro', NEW.intro),
            NEW.user_id, NOW());
END$$

CREATE TRIGGER introductions_update_audit AFTER UPDATE ON introductions
FOR EACH ROW BEGIN
    INSERT INTO audit_logs (table_name, record_id, action_type, old_values, new_values, user_id, created_at)
    VALUES ('introductions', CONCAT(NEW.hospital_id, '_', NEW.user_id, '_', NEW.year, '_', NEW.date), 'UPDATE',
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
    INSERT INTO audit_logs (table_name, record_id, action_type, old_values, created_at)
    VALUES ('introductions', CONCAT(OLD.hospital_id, '_', OLD.user_id, '_', OLD.year, '_', OLD.date), 'DELETE',
            JSON_OBJECT('hospital_id', OLD.hospital_id, 'user_id', OLD.user_id, 'intro_type', OLD.intro_type, 
                       'year', OLD.year, 'date', OLD.date, 'department_name', OLD.department_name, 
                       'department_code', OLD.department_code, 'intro', OLD.intro),
            NOW());
END$$

DELIMITER ;

-- =================================================================
-- ログ確認用ビュー（参考）
-- =================================================================
CREATE VIEW audit_summary AS
SELECT 
    table_name,
    action_type,
    COUNT(*) as count,
    MIN(created_at) as first_action,
    MAX(created_at) as last_action
FROM audit_logs 
GROUP BY table_name, action_type
ORDER BY table_name, action_type;

-- =================================================================
-- アクセスログ専用テーブル（ログイン・画面アクセス記録）
-- =================================================================
DROP TABLE IF EXISTS access_logs;
CREATE TABLE access_logs (
    log_id bigint(20) PRIMARY KEY AUTO_INCREMENT COMMENT 'ログID',
    user_id varchar(8) COMMENT 'ユーザーID',
    session_id varchar(64) COMMENT 'セッションID',
    access_type enum('login','logout','page_access','api_access','download','upload','error') NOT NULL COMMENT 'アクセス種別',
    page_url varchar(500) COMMENT 'アクセスページURL',
    page_name varchar(100) COMMENT 'ページ名',
    http_method enum('GET','POST','PUT','DELETE','PATCH') COMMENT 'HTTPメソッド',
    request_params json COMMENT 'リクエストパラメータ',
    response_status int(11) COMMENT 'レスポンスステータス',
    response_time_ms int(11) COMMENT 'レスポンス時間（ミリ秒）',
    ip_address varchar(45) COMMENT 'IPアドレス',
    user_agent text COMMENT 'ユーザーエージェント',
    referer varchar(500) COMMENT 'リファラー',
    facility_id varchar(30) COMMENT '所属施設ID',
    department_id varchar(30) COMMENT '所属部署ID',
    error_message text COMMENT 'エラーメッセージ',
    additional_info json COMMENT '追加情報',
    created_at datetime DEFAULT CURRENT_TIMESTAMP COMMENT 'アクセス日時',
    INDEX idx_user_id (user_id),
    INDEX idx_access_type (access_type),
    INDEX idx_created_at (created_at),
    INDEX idx_session_id (session_id),
    INDEX idx_ip_address (ip_address),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
) COMMENT = 'システムアクセスログ（ログイン・画面アクセス・API呼び出し等）';

-- =================================================================
-- セキュリティログ専用テーブル（セキュリティ関連イベント）
-- =================================================================
DROP TABLE IF EXISTS security_logs;
CREATE TABLE security_logs (
    log_id bigint(20) PRIMARY KEY AUTO_INCREMENT COMMENT 'ログID',
    user_id varchar(8) COMMENT 'ユーザーID',
    event_type enum('login_success','login_failure','password_change','account_lock','permission_denied','suspicious_access','data_export','admin_access') NOT NULL COMMENT 'セキュリティイベント種別',
    severity enum('low','medium','high','critical') DEFAULT 'medium' COMMENT '重要度',
    description text COMMENT 'イベント詳細',
    ip_address varchar(45) COMMENT 'IPアドレス',
    user_agent text COMMENT 'ユーザーエージェント',
    session_id varchar(64) COMMENT 'セッションID',
    target_resource varchar(200) COMMENT '対象リソース',
    failure_reason varchar(200) COMMENT '失敗理由',
    additional_data json COMMENT '追加データ',
    created_at datetime DEFAULT CURRENT_TIMESTAMP COMMENT 'イベント発生日時',
    INDEX idx_user_id (user_id),
    INDEX idx_event_type (event_type),
    INDEX idx_severity (severity),
    INDEX idx_created_at (created_at),
    INDEX idx_ip_address (ip_address),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
) COMMENT = 'セキュリティイベントログ（認証・権限・不正アクセス等）';

-- =================================================================
-- ログ確認用便利ビュー
-- =================================================================

-- アクセス統計ビュー
CREATE VIEW access_summary AS
SELECT 
    DATE(created_at) as access_date,
    access_type,
    COUNT(*) as access_count,
    COUNT(DISTINCT user_id) as unique_users,
    COUNT(DISTINCT ip_address) as unique_ips
FROM access_logs 
WHERE created_at >= DATE_SUB(NOW(), INTERVAL 30 DAY)
GROUP BY DATE(created_at), access_type
ORDER BY access_date DESC, access_type;

-- セキュリティアラートビュー
CREATE VIEW security_alerts AS
SELECT 
    s.*,
    u.user_name,
    u.facility_id,
    u.department_id
FROM security_logs s
LEFT JOIN users u ON s.user_id = u.user_id
WHERE s.severity IN ('high', 'critical')
   OR s.event_type IN ('login_failure', 'permission_denied', 'suspicious_access')
ORDER BY s.created_at DESC;

-- ユーザーアクティビティビュー
CREATE VIEW user_activity AS
SELECT 
    u.user_id,
    u.user_name,
    u.facility_id,
    u.department_id,
    COUNT(DISTINCT DATE(a.created_at)) as active_days,
    COUNT(a.log_id) as total_accesses,
    MAX(a.created_at) as last_access,
    COUNT(CASE WHEN a.access_type = 'login' THEN 1 END) as login_count
FROM users u
LEFT JOIN access_logs a ON u.user_id = a.user_id 
WHERE a.created_at >= DATE_SUB(NOW(), INTERVAL 30 DAY)
GROUP BY u.user_id, u.user_name, u.facility_id, u.department_id
ORDER BY last_access DESC;
