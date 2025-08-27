CREATE DATABASE IF NOT EXISTS newhptldb
  DEFAULT CHARACTER SET utf8mb4
  COLLATE utf8mb4_general_ci;

USE newhptldb;

DROP TABLE IF EXISTS hospitals;
CREATE TABLE hospitals (
    hospital_id varchar(10) PRIMARY KEY COMMENT '医療機関コード',
    hospital_name varchar(100) NOT NULL COMMENT '医療機関名',
    hospital_type_id int(11) /* FOREIGN KEY */ COMMENT '病院区分ID',
    status enum('active','closed') COMMENT '運営状況',
    notes text COMMENT '備考（基本情報）',
    created_at timestamp COMMENT '作成日時',
    updated_at timestamp COMMENT '更新日時'
) COMMENT = '医療機関の基本情報を格納するメインテーブル';

DROP TABLE IF EXISTS hospital_types;
CREATE TABLE hospital_types (
    type_id int(11) PRIMARY KEY AUTO_INCREMENT COMMENT '病院区分ID',
    type_code varchar(5) NOT NULL UNIQUE COMMENT '区分コード',
    type_name varchar(50) NOT NULL COMMENT '区分名',
    description text COMMENT '説明'
) COMMENT = '病院の種別を管理するマスタテーブル（病院、特定機能病院など）';

DROP TABLE IF EXISTS addresses;
CREATE TABLE addresses (
    address_id int(11) PRIMARY KEY AUTO_INCREMENT COMMENT '住所ID',
    hospital_id varchar(10) /* FOREIGN KEY */ COMMENT '医療機関コード',
    postal_code varchar(7) COMMENT '郵便番号',
    prefecture varchar(10) COMMENT '都道府県',
    area_name varchar(40) COMMENT '地域名',
    city varchar(40) COMMENT '市',
    ward varchar(40) COMMENT '区',
    town varchar(40) COMMENT '町',
    street_number varchar(200) COMMENT '番地',
    full_address varchar(400) COMMENT '完全住所',
    area_code int(11) /* FOREIGN KEY */ COMMENT '地区コード（areaテーブル参照）'
) COMMENT = '医療機関の住所情報を管理';

DROP TABLE IF EXISTS contact_details;
CREATE TABLE contact_details (
    contact_id int(11) PRIMARY KEY AUTO_INCREMENT COMMENT '連絡先ID',
    hospital_id varchar(10) /* FOREIGN KEY */ COMMENT '医療機関コード',
    phone varchar(20) COMMENT '電話番号',
    fax varchar(20) COMMENT 'FAX番号',
    email varchar(254) COMMENT 'メールアドレス',
    website varchar(500) COMMENT 'ウェブサイト',
    contact_type enum('main','emergency','office') COMMENT '連絡先種別'
) COMMENT = '医療機関の連絡先情報を管理';

DROP TABLE IF EXISTS hospital_staff;
CREATE TABLE hospital_staff (
    staff_id int(11) PRIMARY KEY AUTO_INCREMENT COMMENT 'スタッフID',
    hospital_id varchar(10) /* FOREIGN KEY */ COMMENT '医療機関コード',
    role_type enum('chairman','director','vice_director','other') NOT NULL COMMENT '役職種別',
    name varchar(60) NOT NULL COMMENT '氏名',
    specialty varchar(50) COMMENT '専門分野',
    graduation_year year(4) COMMENT '卒業年度',
    alma_mater varchar(100) COMMENT '出身校',
    association_id varchar(20) COMMENT '医師会地域コード',
    notes text COMMENT '備考'
) COMMENT = '理事長、病院長などの重要人物情報を管理';

DROP TABLE IF EXISTS medical_association;
CREATE TABLE medical_association (
    section_id int(11) PRIMARY KEY AUTO_INCREMENT COMMENT '区分コード',
    area_id varchar(20) /* FOREIGN KEY */ COMMENT '地域コード',
    med_area varchar(60) NOT NULL COMMENT '二次医療圏',
    med_association varchar(60) NOT NULL COMMENT '医師会名'
) COMMENT = '医師会についての情報を管理';

DROP TABLE IF EXISTS consultation_hours;
CREATE TABLE consultation_hours (
    schedule_id int(11) PRIMARY KEY AUTO_INCREMENT COMMENT 'スケジュールID',
    hospital_id varchar(10) /* FOREIGN KEY */ COMMENT '医療機関コード',
    day_of_week enum('monday','tuesday','wednesday','thursday','friday','saturday','sunday','holiday') NOT NULL COMMENT '曜日',
    period enum('AM','PM','AM_PM') NOT NULL COMMENT '時間帯',
    is_available boolean COMMENT '診療可否',
    start_time time COMMENT '開始時間',
    end_time time COMMENT '終了時間',
    notes varchar(200) COMMENT '備考'
) COMMENT = '医療機関の診療時間を管理';

DROP TABLE IF EXISTS medical_departments;
CREATE TABLE medical_departments (
    department_id int(11) PRIMARY KEY AUTO_INCREMENT COMMENT '診療科ID',
    department_code varchar(10) NOT NULL UNIQUE COMMENT '診療科コード',
    department_name varchar(100) NOT NULL COMMENT '診療科名',
    category_id int(11) /* FOREIGN KEY */ COMMENT '診療科カテゴリID',
    display_order int(11) COMMENT '表示順序',
    is_active boolean COMMENT '有効フラグ'
) COMMENT = '診療科の分類と詳細を管理';

DROP TABLE IF EXISTS medical_categories;
CREATE TABLE medical_categories (
    category_id int(11) PRIMARY KEY AUTO_INCREMENT COMMENT 'カテゴリID',
    category_code varchar(10) NOT NULL UNIQUE COMMENT 'カテゴリコード',
    category_name varchar(50) NOT NULL COMMENT 'カテゴリ名',
    display_order int(11) COMMENT '表示順序'
) COMMENT = '診療科の大分類を管理';

DROP TABLE IF EXISTS hospital_departments;
CREATE TABLE hospital_departments (
    relation_id int(11) PRIMARY KEY AUTO_INCREMENT COMMENT '関連ID',
    hospital_id varchar(10) /* FOREIGN KEY */ COMMENT '医療機関コード',
    department_id int(11) /* FOREIGN KEY */ COMMENT '診療科ID',
    is_primary boolean COMMENT '主要診療科フラグ',
    notes text COMMENT '診療科別備考',
    created_at timestamp COMMENT '作成日時'
) COMMENT = '医療機関が対応している診療科を管理';

DROP TABLE IF EXISTS medical_services;
CREATE TABLE medical_services (
    service_id varchar(20) PRIMARY KEY AUTO_INCREMENT COMMENT '診療内容ID',
    service_code varchar(10) NOT NULL UNIQUE COMMENT '診療内容コード',
    service_division varchar(100) COMMENT '診療区分',
    service_category varchar(100) COMMENT '診療部門',
    service_name varchar(300) NOT NULL COMMENT '診療内容名'
) COMMENT = '提供可能な医療サービスを管理';

DROP TABLE IF EXISTS hospital_services;
CREATE TABLE hospital_services (
    hospital_id varchar(10) PRIMARY KEY COMMENT '医療機関コード',
    service_id varchar(20) PRIMARY KEY COMMENT '診療内容ID',
    notes text COMMENT '個別備考',
    created_at timestamp COMMENT '作成日時'
) COMMENT = '医療機関が提供している診療内容を管理';

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

DROP TABLE IF EXISTS carna_connect;
CREATE TABLE carna_connect (
    hospital_code varchar(10) PRIMARY KEY COMMENT '医療機関コード',
    is_deleted boolean COMMENT '削除フラグ'
) COMMENT = 'カルナコネクトと連携しているかどうかを管理';

DROP TABLE IF EXISTS audit_logs;
CREATE TABLE audit_logs (
    log_id bigint(20) PRIMARY KEY AUTO_INCREMENT COMMENT 'ログID',
    table_name varchar(50) NOT NULL COMMENT '対象テーブル名',
    record_id varchar(50) NOT NULL COMMENT '対象レコードID',
    action_type enum('INSERT','UPDATE','DELETE') NOT NULL COMMENT '操作種別',
    old_values json COMMENT '変更前データ',
    new_values json COMMENT '変更後データ',
    user_id varchar(10) COMMENT '操作者ID',
    user_name varchar(50) COMMENT '操作者氏名',
    user_facility varchar(30) COMMENT '操作者施設',
    user_department varchar(30) COMMENT '操作者所属',
    is_admin boolean COMMENT '管理者フラグ',
    created_at timestamp COMMENT '操作日時',
    ip_address varchar(45) COMMENT 'IPアドレス',
    user_agent text COMMENT 'ユーザーエージェント'
) COMMENT = 'データ変更の監査ログを統合管理';

DROP TABLE IF EXISTS inquiries;
CREATE TABLE inquiries (
    inquiry_id int(11) PRIMARY KEY AUTO_INCREMENT COMMENT '問い合わせID',
    hospital_id varchar(10) /* FOREIGN KEY */ COMMENT '医療機関コード',
    inquiry_type enum('contact','visit','online','phone','other') NOT NULL COMMENT '問い合わせ種別',
    inquiry_date date NOT NULL COMMENT '問い合わせ日',
    fiscal_year year(4) NOT NULL COMMENT '年度',
    facility_type enum('affiliated_hospital','medical_center') NOT NULL COMMENT '施設区分',
    external_contact_dept varchar(50) COMMENT '連携機関対応者部署',
    external_contact_position varchar(50) COMMENT '連携機関対応者役職',
    external_contact_name varchar(50) COMMENT '連携機関対応者氏名',
    external_participants text COMMENT '連携機関参加者',
    internal_contact_dept varchar(50) COMMENT '当院対応者所属',
    internal_contact_name varchar(50) COMMENT '当院対応者氏名',
    internal_participants text COMMENT '当院参加者',
    content_summary text COMMENT '内容要約',
    detailed_notes text COMMENT '詳細備考',
    data_created_dept varchar(50) COMMENT 'データ作成部署',
    status enum('open','in_progress','closed') COMMENT 'ステータス'
) COMMENT = '医療機関との問い合わせを統合管理';

DROP TABLE IF EXISTS users;
CREATE TABLE users (
    id int(11) PRIMARY KEY AUTO_INCREMENT COMMENT 'ID',
    user_id varchar(10) PRIMARY KEY COMMENT 'ユーザーID',
    user_name varchar(50) NOT NULL COMMENT 'ユーザー名',
    pwd_hash varchar(255) NOT NULL COMMENT 'パスワードハッシュ',
    facility varchar(30) COMMENT '所属施設',
    department varchar(30) COMMENT '所属部署',
    role enum('admin','editor','viewer') COMMENT '権限レベル',
    is_active boolean COMMENT 'アカウント有効フラグ',
    created_at timestamp COMMENT '作成日時',
    updated_at timestamp COMMENT '更新日時',
    last_login_at timestamp COMMENT '最終ログイン日時'
) COMMENT = 'システム利用者の情報を管理';

DROP TABLE IF EXISTS kawasaki_university_facility_id;
CREATE TABLE kawasaki_university_facility_id (
    facility_id varchar(20) PRIMARY KEY COMMENT '所属施設ID',
    name varchar(50) NOT NULL COMMENT '施設名',
    fomal_name varchar(60) NOT NULL COMMENT '正式名称',
    abbreviation varchar(50) NOT NULL COMMENT '略称'
) COMMENT = '川崎学園の病院情報を管理（附属病院、総合医療センター、高齢者医療センター）';

DROP TABLE IF EXISTS kawasaki_university_department;
CREATE TABLE kawasaki_university_department (
    department_id varchar(20) PRIMARY KEY COMMENT '部署ID',
    name varchar(50) NOT NULL COMMENT '部署名'
) COMMENT = '川崎学園の部署情報を管理';

DROP TABLE IF EXISTS documents;
CREATE TABLE documents (
    document_id int(11) PRIMARY KEY AUTO_INCREMENT COMMENT 'ドキュメントID',
    document_type enum('message','maintenance','qa','manual','other') NOT NULL COMMENT 'ドキュメント種別',
    title varchar(200) NOT NULL COMMENT 'タイトル',
    content text COMMENT '内容',
    status enum('draft','published','archived') COMMENT 'ステータス',
    priority enum('low','normal','high','urgent') COMMENT '優先度',
    target_facility varchar(50) COMMENT '対象施設',
    target_department varchar(50) COMMENT '対象部署',
    target_version varchar(50) COMMENT '対象システムバージョン',
    published_date date COMMENT '公開日',
    effective_start_date date COMMENT '有効開始日',
    effective_end_date date COMMENT '有効終了日',
    author_user_id varchar(10) /* FOREIGN KEY */ COMMENT '作成者ID',
    is_visible boolean COMMENT '表示フラグ',
    created_at timestamp COMMENT '作成日時',
    updated_at timestamp COMMENT '更新日時'
) COMMENT = 'システム関連ドキュメントを統合管理';

DROP TABLE IF EXISTS training;
CREATE TABLE training (
    hos_cd varchar(10),
    year year(4),
    ins int(11),
    tra_name varchar(200),
    dep varchar(60),
    name varchar(60),
    start date,
    end date,
    date varchar(300),
    dia_div varchar(50),
    occ varchar(30)
) COMMENT = '院外診療支援・研修情報を管理';

DROP TABLE IF EXISTS contact;
CREATE TABLE contact (
    hos_cd varchar(10),
    hos_name varchar(100),
    year year(4),
    ins int(11),
    date date,
    method varchar(50),
    ex_dept varchar(50),
    ex_position varchar(50),
    ex_name varchar(10),
    ex_subnames varchar(100),
    in_dept varchar(50),
    in_name varchar(10),
    in_subnames varchar(100),
    detail varchar(100),
    con_note varchar(100),
    data_dept varchar(50)
) COMMENT = '医療機関同士のコンタクト履歴を保管';

