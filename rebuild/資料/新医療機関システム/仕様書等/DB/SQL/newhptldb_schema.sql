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
    display_order int(11) NOT NULL DEFAULT 0 COMMENT '表示順序'
) COMMENT = '病院の種別を管理するマスタテーブル（病院、特定機能病院など）';


DROP TABLE IF EXISTS hospitals;
CREATE TABLE hospitals (
    hospital_id varchar(10) PRIMARY KEY COMMENT '医療機関コード',
    hospital_type_id varchar(11) COMMENT '病院区分ID',
    hospital_name varchar(100) NOT NULL COMMENT '医療機関名',
    status enum('active','closed') DEFAULT 'active' COMMENT '運営状況',
    bed_count int(11) DEFAULT 0 COMMENT '許可病床数',
    consultation_hour varchar(200) COMMENT '診療時間',
    has_pt boolean DEFAULT false COMMENT '理学療法士在籍フラグ',
    has_ot boolean DEFAULT false COMMENT '作業療法士在籍フラグ',
    has_st boolean DEFAULT false COMMENT '言語聴覚療法士在籍フラグ',
    notes text COMMENT '備考',
    closed_at date COMMENT '閉院日',
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
    contact_detail varchar(30) COMMENT '連絡先（診療科・部署など）',
    phone varchar(20) COMMENT '電話番号',
    fax varchar(20) COMMENT 'FAX番号',
    email varchar(254) COMMENT 'メールアドレス',
    website varchar(500) COMMENT 'ウェブサイト',
    note text COMMENT '備考',
    is_deleted boolean DEFAULT false COMMENT '削除フラグ',
    FOREIGN KEY (hospital_id) REFERENCES hospitals(hospital_id)
) COMMENT = '医療機関の連絡先情報を管理';

DROP TABLE IF EXISTS ward_types;
CREATE TABLE ward_types (
    ward_id varchar(10) PRIMARY KEY NOT NULL COMMENT '病棟種類ID',
    ward_name varchar(20) NOT NULL COMMENT '病棟名',
    is_active boolean DEFAULT true COMMENT '有効フラグ',
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
    role_type enum('chairman','director') NOT NULL COMMENT '役職種別（理事長・病院長）',
    staff_name varchar(60) NOT NULL COMMENT '氏名',
    specialty varchar(50) COMMENT '専門分野',
    graduation_year year(4) COMMENT '卒業年度',
    alma_mater varchar(100) COMMENT '出身校',
    notes text COMMENT '備考',
    FOREIGN KEY (hospital_id) REFERENCES hospitals(hospital_id)
) COMMENT = '理事長、病院長などの重要人物情報を管理';

DROP TABLE IF EXISTS hospital_code_history;
CREATE TABLE hospital_code_history (
    history_id bigint(20) PRIMARY KEY AUTO_INCREMENT COMMENT '履歴ID',
    hospital_id varchar(10) NOT NULL COMMENT '現在の医療機関コード',
    former_hospital_id varchar(10) NOT NULL COMMENT '以前の医療機関コード',
    change_date date COMMENT 'コードが更新された日時',
    created_at datetime DEFAULT CURRENT_TIMESTAMP COMMENT '登録日時',
    FOREIGN KEY (hospital_id) REFERENCES hospitals(hospital_id)
) COMMENT = '現在の医療機関コードと、過去に使用されていたコードを紐づけ';

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
    service_division varchar(100) COMMENT '診療区分',
    service_category varchar(100) COMMENT '診療部門',
    service_name varchar(300) NOT NULL COMMENT '診療内容名',
    is_active boolean DEFAULT true COMMENT '有効フラグ',
    display_order int(11) NOT NULL DEFAULT 0 COMMENT '表示順序',
    PRIMARY KEY (service_id, service_division)
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
    facility_id varchar(20) PRIMARY KEY COMMENT '所属施設ID',
    facility_name varchar(50) NOT NULL COMMENT '施設名',
    formal_name varchar(60) NOT NULL COMMENT '正式名称',
    abbreviation varchar(50) NULL COMMENT '略称',
    is_active boolean DEFAULT true COMMENT '有効フラグ',
    display_order int(11) NOT NULL DEFAULT 0 COMMENT '表示順序'
) COMMENT = '川崎学園の病院情報を管理（附属病院、総合医療センター、高齢者医療センター）';

DROP TABLE IF EXISTS kawasaki_university_departments;
CREATE TABLE kawasaki_university_departments (
    department_id varchar(20) PRIMARY KEY COMMENT '部署ID',
    department_name varchar(50) NOT NULL COMMENT '部署名',
    is_active boolean DEFAULT true COMMENT '有効フラグ',
    display_order int(11) NOT NULL DEFAULT 0 COMMENT '表示順序'
) COMMENT = '川崎学園の部署情報を管理';

DROP TABLE IF EXISTS users;
CREATE TABLE users (
    user_id varchar(8) PRIMARY KEY COMMENT 'ユーザーID',
    user_name varchar(50) NOT NULL COMMENT 'ユーザー名',
    password_hash varchar(255) NOT NULL COMMENT 'パスワードハッシュ',
    facility_id varchar(20) NOT NULL COMMENT '所属施設',
    department_id varchar(20) NOT NULL COMMENT '所属部署',
    role enum('admin','editor','viewer') DEFAULT 'viewer' COMMENT '権限レベル',
    is_active boolean DEFAULT true COMMENT 'アカウント有効フラグ',
    last_login_at datetime NULL COMMENT '最終ログイン日時',
    created_at datetime DEFAULT CURRENT_TIMESTAMP COMMENT '作成日時',
    updated_at datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新日時',
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

-- 問い合わせテーブル
DROP TABLE IF EXISTS inquires;
CREATE TABLE inquires (
    inquire_id bigint(20) PRIMARY KEY AUTO_INCREMENT COMMENT '問い合わせID',
    user_id varchar(8) COMMENT '問い合わせ者ユーザーID',
    priority enum('general','urgent') DEFAULT 'general' COMMENT '優先度',
    status enum('open','in_progress','resolved','closed') DEFAULT 'open' COMMENT '対応状況',
    description text NOT NULL COMMENT '問い合わせ内容',
    assigned_to varchar(8) COMMENT '担当者ユーザーID',
    resolution text NULL COMMENT '解決方法・回答内容',
    created_at datetime DEFAULT CURRENT_TIMESTAMP COMMENT '問い合わせ日時',
    updated_at datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '最終更新日時',
    resolved_at datetime NULL COMMENT '解決日時',
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (assigned_to) REFERENCES users(user_id)
) COMMENT = 'システムに関する問い合わせ内容を管理';

-- =================================================================
-- システム運営管理系テーブル
-- =================================================================

-- メンテナンス通知テーブル
DROP TABLE IF EXISTS maintenance;
CREATE TABLE maintenance (
    maintenance_id bigint(20) PRIMARY KEY AUTO_INCREMENT COMMENT 'メンテナンスID',
    title varchar(200) NOT NULL COMMENT 'タイトル',
    comment text NOT NULL COMMENT '実施内容',
    date date NOT NULL COMMENT '予定作業日',
    start_time time NULL COMMENT '予定開始時刻',
    end_time time NULL COMMENT '予定終了時刻',
    view boolean NOT NULL DEFAULT true COMMENT '表示フラグ',
    created_by varchar(8) NOT NULL COMMENT '作成者ユーザーID',
    created_at datetime DEFAULT CURRENT_TIMESTAMP COMMENT '作成日時',
    updated_at datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新日時',
    FOREIGN KEY (created_by) REFERENCES users(user_id)
) COMMENT = '事前メンテナンス通知を管理';

-- メンテナンス実行中通知テーブル
DROP TABLE IF EXISTS maintenance_start;
CREATE TABLE maintenance_start (
    id bigint(20) PRIMARY KEY AUTO_INCREMENT COMMENT '実行通知ID',
    maintenance_id bigint(20) NOT NULL COMMENT 'メンテナンスID',
    title varchar(200) NOT NULL COMMENT '通知タイトル',
    description text NULL COMMENT '通知詳細',
    implementation_details text NULL COMMENT '実施内容',
    view boolean NOT NULL DEFAULT true COMMENT '表示フラグ',
    created_by varchar(8) NOT NULL COMMENT '作成者ユーザーID',
    created_at datetime DEFAULT CURRENT_TIMESTAMP COMMENT '作成日時',
    updated_at datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新日時',
    FOREIGN KEY (maintenance_id) REFERENCES maintenance(maintenance_id),
    FOREIGN KEY (created_by) REFERENCES users(user_id)
) COMMENT = 'メンテナンス実行中の通知を管理';

-- システムバージョン管理テーブル
DROP TABLE IF EXISTS system_versions;
CREATE TABLE system_versions (
    version_id int(11) PRIMARY KEY AUTO_INCREMENT COMMENT 'バージョン管理ID',
    version_number varchar(20) NOT NULL UNIQUE COMMENT 'バージョン番号（例：4.5.2）',
    release_date date NOT NULL COMMENT 'リリース日',
    is_current boolean NOT NULL DEFAULT false COMMENT '現在稼働バージョンフラグ',
    release_notes text NULL COMMENT 'リリースノート・変更内容',
    created_at datetime DEFAULT CURRENT_TIMESTAMP COMMENT '作成日時'
) COMMENT = 'システムのバージョン情報を最小限で管理';

-- メッセージテーブル（システム更新履歴・要望管理）
DROP TABLE IF EXISTS message;
CREATE TABLE message (
    message_id bigint(20) PRIMARY KEY AUTO_INCREMENT COMMENT 'メッセージID',
    status enum('open','in_progress','completed','rejected') DEFAULT 'open' COMMENT '対応状況',
    comment text NOT NULL COMMENT '内容',
    view boolean NOT NULL DEFAULT true COMMENT '表示フラグ',
    version_id int(11) NULL COMMENT '実装バージョンID',
    assigned_to varchar(8) NOT NULL COMMENT '担当者ユーザーID',
    priority enum('low','normal','urgent') DEFAULT 'normal' COMMENT '優先度',
    res_date date NULL COMMENT '対応日',
    created_at datetime DEFAULT CURRENT_TIMESTAMP COMMENT '作成日時',
    updated_at datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新日時',
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
    FOREIGN KEY (maintenance_id) REFERENCES maintenance(maintenance_id),
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
    relative_name varchar(60) NOT NULL COMMENT '人物名',
    connection varchar(30) COMMENT '関係',
    school_name varchar(100) COMMENT '学校名',
    entrance_year year(4) COMMENT '入学年',
    graduation_year year(4) COMMENT '卒業年',
    notes text COMMENT '備考',
    is_deleted boolean DEFAULT false COMMENT '削除フラグ',
    created_at datetime DEFAULT CURRENT_TIMESTAMP COMMENT '作成日時',
    updated_at datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新日時',
    FOREIGN KEY (hospital_id) REFERENCES hospitals(hospital_id)
) COMMENT = '医療機関に関連する人物の親族情報を管理';

-- =================================================================
-- 会議・イベント参加系
-- =================================================================

-- 医療連携懇話会参加年度テーブル
DROP TABLE IF EXISTS social_meetings;
CREATE TABLE social_meetings (
    hospital_id varchar(10) COMMENT '医療機関コード',
    user_id varchar(8) COMMENT 'ユーザーID（所属病院情報取得用）',
    meeting_year year(4) COMMENT '参加年度',
    is_deleted boolean DEFAULT false COMMENT '削除フラグ',
    created_at datetime DEFAULT CURRENT_TIMESTAMP COMMENT '作成日時',
    updated_at datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新日時',
    PRIMARY KEY (hospital_id, user_id, meeting_year),
    FOREIGN KEY (hospital_id) REFERENCES hospitals(hospital_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
) COMMENT = '医療連携懇話会への参加年度を管理';

-- 外部キー制約チェックを再度有効化
SET FOREIGN_KEY_CHECKS = 1;

-- =================================================================
-- インデックス追加（パフォーマンス向上）
-- =================================================================

-- maintenanceテーブル
CREATE INDEX idx_maintenance_date ON maintenance(date);
CREATE INDEX idx_maintenance_view ON maintenance(view);
CREATE INDEX idx_maintenance_created_by ON maintenance(created_by);

-- maintenance_startテーブル
CREATE INDEX idx_maintenance_start_maintenance_id ON maintenance_start(maintenance_id);
CREATE INDEX idx_maintenance_start_view ON maintenance_start(view);

-- system_versionsテーブル
CREATE INDEX idx_system_versions_is_current ON system_versions(is_current);
CREATE INDEX idx_system_versions_release_date ON system_versions(release_date);

-- messageテーブル
CREATE INDEX idx_message_status ON message(status);
CREATE INDEX idx_message_priority ON message(priority);
CREATE INDEX idx_message_assigned_to ON message(assigned_to);
CREATE INDEX idx_message_version_id ON message(version_id);
CREATE INDEX idx_message_created_at ON message(created_at);

-- system_statusテーブル
CREATE INDEX idx_system_status_system_mode ON system_status(system_mode);
CREATE INDEX idx_system_status_maintenance_id ON system_status(maintenance_id);
CREATE INDEX idx_system_status_created_at ON system_status(created_at);

-- inquiresテーブル
CREATE INDEX idx_inquires_user_id ON inquires(user_id);
CREATE INDEX idx_inquires_status ON inquires(status);
CREATE INDEX idx_inquires_priority ON inquires(priority);
CREATE INDEX idx_inquires_assigned_to ON inquires(assigned_to);
CREATE INDEX idx_inquires_created_at ON inquires(created_at);

-- hospital_code_historyテーブル
CREATE INDEX idx_hospital_code_history_hospital_id ON hospital_code_history(hospital_id);
CREATE INDEX idx_hospital_code_history_former_hospital_id ON hospital_code_history(former_hospital_id);
CREATE INDEX idx_hospital_code_history_change_date ON hospital_code_history(change_date);
CREATE INDEX idx_hospital_code_history_created_at ON hospital_code_history(created_at);

-- relativesテーブル
CREATE INDEX idx_relatives_hospital_id ON relatives(hospital_id);
CREATE INDEX idx_relatives_relative_name ON relatives(relative_name);
CREATE INDEX idx_relatives_connection ON relatives(connection);
CREATE INDEX idx_relatives_graduation_year ON relatives(graduation_year);
CREATE INDEX idx_relatives_is_deleted ON relatives(is_deleted);
CREATE INDEX idx_relatives_created_at ON relatives(created_at);

-- social_meetingsテーブル
CREATE INDEX idx_social_meetings_hospital_id ON social_meetings(hospital_id);
CREATE INDEX idx_social_meetings_user_id ON social_meetings(user_id);
CREATE INDEX idx_social_meetings_meeting_year ON social_meetings(meeting_year);
CREATE INDEX idx_social_meetings_is_deleted ON social_meetings(is_deleted);
CREATE INDEX idx_social_meetings_created_at ON social_meetings(created_at);

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

-- =================================================================
-- システム運営管理系テーブル用トリガー追加
-- =================================================================

-- maintenanceテーブル用監査トリガー
CREATE TRIGGER maintenance_insert_audit AFTER INSERT ON maintenance
FOR EACH ROW BEGIN
    INSERT INTO unified_logs (log_type, table_name, record_id, action_type, new_values, user_id, created_at)
    VALUES ('audit', 'maintenance', NEW.maintenance_id, 'INSERT', 
            JSON_OBJECT('maintenance_id', NEW.maintenance_id, 'title', NEW.title, 'comment', NEW.comment,
                       'date', NEW.date, 'start_time', NEW.start_time, 'end_time', NEW.end_time,
                       'view', NEW.view, 'created_by', NEW.created_by),
            NEW.created_by, NOW());
END$$

CREATE TRIGGER maintenance_update_audit AFTER UPDATE ON maintenance
FOR EACH ROW BEGIN
    INSERT INTO unified_logs (log_type, table_name, record_id, action_type, old_values, new_values, user_id, created_at)
    VALUES ('audit', 'maintenance', NEW.maintenance_id, 'UPDATE',
            JSON_OBJECT('maintenance_id', OLD.maintenance_id, 'title', OLD.title, 'comment', OLD.comment,
                       'date', OLD.date, 'start_time', OLD.start_time, 'end_time', OLD.end_time,
                       'view', OLD.view, 'created_by', OLD.created_by),
            JSON_OBJECT('maintenance_id', NEW.maintenance_id, 'title', NEW.title, 'comment', NEW.comment,
                       'date', NEW.date, 'start_time', NEW.start_time, 'end_time', NEW.end_time,
                       'view', NEW.view, 'created_by', NEW.created_by),
            NEW.created_by, NOW());
END$$

CREATE TRIGGER maintenance_delete_audit AFTER DELETE ON maintenance
FOR EACH ROW BEGIN
    INSERT INTO unified_logs (log_type, table_name, record_id, action_type, old_values, created_at)
    VALUES ('audit', 'maintenance', OLD.maintenance_id, 'DELETE',
            JSON_OBJECT('maintenance_id', OLD.maintenance_id, 'title', OLD.title, 'comment', OLD.comment,
                       'date', OLD.date, 'start_time', OLD.start_time, 'end_time', OLD.end_time,
                       'view', OLD.view, 'created_by', OLD.created_by),
            NOW());
END$$

-- messageテーブル用監査トリガー
CREATE TRIGGER message_insert_audit AFTER INSERT ON message
FOR EACH ROW BEGIN
    INSERT INTO unified_logs (log_type, table_name, record_id, action_type, new_values, user_id, created_at)
    VALUES ('audit', 'message', NEW.message_id, 'INSERT', 
            JSON_OBJECT('message_id', NEW.message_id, 'status', NEW.status, 'comment', NEW.comment,
                       'version_id', NEW.version_id, 'assigned_to', NEW.assigned_to, 'priority', NEW.priority),
            NEW.assigned_to, NOW());
END$$

CREATE TRIGGER message_update_audit AFTER UPDATE ON message
FOR EACH ROW BEGIN
    INSERT INTO unified_logs (log_type, table_name, record_id, action_type, old_values, new_values, user_id, created_at)
    VALUES ('audit', 'message', NEW.message_id, 'UPDATE',
            JSON_OBJECT('message_id', OLD.message_id, 'status', OLD.status, 'comment', OLD.comment,
                       'version_id', OLD.version_id, 'assigned_to', OLD.assigned_to, 'priority', OLD.priority),
            JSON_OBJECT('message_id', NEW.message_id, 'status', NEW.status, 'comment', NEW.comment,
                       'version_id', NEW.version_id, 'assigned_to', NEW.assigned_to, 'priority', NEW.priority),
            NEW.assigned_to, NOW());
END$$

CREATE TRIGGER message_delete_audit AFTER DELETE ON message
FOR EACH ROW BEGIN
    INSERT INTO unified_logs (log_type, table_name, record_id, action_type, old_values, created_at)
    VALUES ('audit', 'message', OLD.message_id, 'DELETE',
            JSON_OBJECT('message_id', OLD.message_id, 'status', OLD.status, 'comment', OLD.comment,
                       'version_id', OLD.version_id, 'assigned_to', OLD.assigned_to, 'priority', OLD.priority),
            NOW());
END$$

-- system_statusテーブル用監査トリガー
CREATE TRIGGER system_status_insert_audit AFTER INSERT ON system_status
FOR EACH ROW BEGIN
    INSERT INTO unified_logs (log_type, table_name, record_id, action_type, new_values, user_id, created_at)
    VALUES ('audit', 'system_status', NEW.status_id, 'INSERT', 
            JSON_OBJECT('status_id', NEW.status_id, 'system_mode', NEW.system_mode, 
                       'status_message', NEW.status_message, 'maintenance_id', NEW.maintenance_id,
                       'changed_by', NEW.changed_by),
            NEW.changed_by, NOW());
END$$

CREATE TRIGGER system_status_update_audit AFTER UPDATE ON system_status
FOR EACH ROW BEGIN
    INSERT INTO unified_logs (log_type, table_name, record_id, action_type, old_values, new_values, user_id, created_at)
    VALUES ('audit', 'system_status', NEW.status_id, 'UPDATE',
            JSON_OBJECT('status_id', OLD.status_id, 'system_mode', OLD.system_mode, 
                       'status_message', OLD.status_message, 'maintenance_id', OLD.maintenance_id,
                       'changed_by', OLD.changed_by),
            JSON_OBJECT('status_id', NEW.status_id, 'system_mode', NEW.system_mode, 
                       'status_message', NEW.status_message, 'maintenance_id', NEW.maintenance_id,
                       'changed_by', NEW.changed_by),
            NEW.changed_by, NOW());
END$$

-- inquiresテーブル用監査トリガー
CREATE TRIGGER inquires_insert_audit AFTER INSERT ON inquires
FOR EACH ROW BEGIN
    INSERT INTO unified_logs (log_type, table_name, record_id, action_type, new_values, user_id, created_at)
    VALUES ('audit', 'inquires', NEW.inquire_id, 'INSERT', 
            JSON_OBJECT('inquire_id', NEW.inquire_id, 'user_id', NEW.user_id, 'priority', NEW.priority,
                       'status', NEW.status, 'description', NEW.description, 'assigned_to', NEW.assigned_to,
                       'created_at', NEW.created_at, 'updated_at', NEW.updated_at, 'resolved_at', NEW.resolved_at),
            NEW.user_id, NOW());
END$$

CREATE TRIGGER inquires_update_audit AFTER UPDATE ON inquires
FOR EACH ROW BEGIN
    INSERT INTO unified_logs (log_type, table_name, record_id, action_type, old_values, new_values, user_id, created_at)
    VALUES ('audit', 'inquires', NEW.inquire_id, 'UPDATE',
            JSON_OBJECT('inquire_id', OLD.inquire_id, 'user_id', OLD.user_id, 'priority', OLD.priority,
                       'status', OLD.status, 'description', OLD.description, 'assigned_to', OLD.assigned_to,
                       'created_at', OLD.created_at, 'updated_at', OLD.updated_at, 'resolved_at', OLD.resolved_at),
            JSON_OBJECT('inquire_id', NEW.inquire_id, 'user_id', NEW.user_id, 'priority', NEW.priority,
                       'status', NEW.status, 'description', NEW.description, 'assigned_to', NEW.assigned_to,
                       'created_at', NEW.created_at, 'updated_at', NEW.updated_at, 'resolved_at', NEW.resolved_at),
            NEW.user_id, NOW());
END$$

CREATE TRIGGER inquires_delete_audit AFTER DELETE ON inquires
FOR EACH ROW BEGIN
    INSERT INTO unified_logs (log_type, table_name, record_id, action_type, old_values, user_id, created_at)
    VALUES ('audit', 'inquires', OLD.inquire_id, 'DELETE',
            JSON_OBJECT('inquire_id', OLD.inquire_id, 'user_id', OLD.user_id, 'priority', OLD.priority,
                       'status', OLD.status, 'description', OLD.description, 'assigned_to', OLD.assigned_to,
                       'created_at', OLD.created_at, 'updated_at', OLD.updated_at, 'resolved_at', OLD.resolved_at),
            OLD.user_id, NOW());
END$$

-- hospital_code_history テーブル用トリガー
CREATE TRIGGER hospital_code_history_insert_audit AFTER INSERT ON hospital_code_history
FOR EACH ROW BEGIN
    INSERT INTO unified_logs (log_type, table_name, record_id, action_type, new_values, created_at)
    VALUES ('audit', 'hospital_code_history', NEW.history_id, 'INSERT',
            JSON_OBJECT('history_id', NEW.history_id, 'hospital_id', NEW.hospital_id, 
                       'former_hospital_id', NEW.former_hospital_id, 'change_date', NEW.change_date,
                       'created_at', NEW.created_at),
            NOW());
END$$

CREATE TRIGGER hospital_code_history_update_audit AFTER UPDATE ON hospital_code_history
FOR EACH ROW BEGIN
    INSERT INTO unified_logs (log_type, table_name, record_id, action_type, old_values, new_values, created_at)
    VALUES ('audit', 'hospital_code_history', NEW.history_id, 'UPDATE',
            JSON_OBJECT('history_id', OLD.history_id, 'hospital_id', OLD.hospital_id, 
                       'former_hospital_id', OLD.former_hospital_id, 'change_date', OLD.change_date,
                       'created_at', OLD.created_at),
            JSON_OBJECT('history_id', NEW.history_id, 'hospital_id', NEW.hospital_id, 
                       'former_hospital_id', NEW.former_hospital_id, 'change_date', NEW.change_date,
                       'created_at', NEW.created_at),
            NOW());
END$$

CREATE TRIGGER hospital_code_history_delete_audit AFTER DELETE ON hospital_code_history
FOR EACH ROW BEGIN
    INSERT INTO unified_logs (log_type, table_name, record_id, action_type, old_values, created_at)
    VALUES ('audit', 'hospital_code_history', OLD.history_id, 'DELETE',
            JSON_OBJECT('history_id', OLD.history_id, 'hospital_id', OLD.hospital_id, 
                       'former_hospital_id', OLD.former_hospital_id, 'change_date', OLD.change_date,
                       'created_at', OLD.created_at),
            NOW());
END$$

-- relatives テーブル用トリガー
CREATE TRIGGER relatives_insert_audit AFTER INSERT ON relatives
FOR EACH ROW BEGIN
    INSERT INTO unified_logs (log_type, table_name, record_id, action_type, new_values, created_at)
    VALUES ('audit', 'relatives', NEW.relative_id, 'INSERT',
            JSON_OBJECT('relative_id', NEW.relative_id, 'hospital_id', NEW.hospital_id, 
                       'relative_name', NEW.relative_name, 'connection', NEW.connection,
                       'school_name', NEW.school_name, 'entrance_year', NEW.entrance_year,
                       'graduation_year', NEW.graduation_year, 'notes', NEW.notes,
                       'is_deleted', NEW.is_deleted, 'created_at', NEW.created_at, 'updated_at', NEW.updated_at),
            NOW());
END$$

CREATE TRIGGER relatives_update_audit AFTER UPDATE ON relatives
FOR EACH ROW BEGIN
    INSERT INTO unified_logs (log_type, table_name, record_id, action_type, old_values, new_values, created_at)
    VALUES ('audit', 'relatives', NEW.relative_id, 'UPDATE',
            JSON_OBJECT('relative_id', OLD.relative_id, 'hospital_id', OLD.hospital_id, 
                       'relative_name', OLD.relative_name, 'connection', OLD.connection,
                       'school_name', OLD.school_name, 'entrance_year', OLD.entrance_year,
                       'graduation_year', OLD.graduation_year, 'notes', OLD.notes,
                       'is_deleted', OLD.is_deleted, 'created_at', OLD.created_at, 'updated_at', OLD.updated_at),
            JSON_OBJECT('relative_id', NEW.relative_id, 'hospital_id', NEW.hospital_id, 
                       'relative_name', NEW.relative_name, 'connection', NEW.connection,
                       'school_name', NEW.school_name, 'entrance_year', NEW.entrance_year,
                       'graduation_year', NEW.graduation_year, 'notes', NEW.notes,
                       'is_deleted', NEW.is_deleted, 'created_at', NEW.created_at, 'updated_at', NEW.updated_at),
            NOW());
END$$

CREATE TRIGGER relatives_delete_audit AFTER DELETE ON relatives
FOR EACH ROW BEGIN
    INSERT INTO unified_logs (log_type, table_name, record_id, action_type, old_values, created_at)
    VALUES ('audit', 'relatives', OLD.relative_id, 'DELETE',
            JSON_OBJECT('relative_id', OLD.relative_id, 'hospital_id', OLD.hospital_id, 
                       'relative_name', OLD.relative_name, 'connection', OLD.connection,
                       'school_name', OLD.school_name, 'entrance_year', OLD.entrance_year,
                       'graduation_year', OLD.graduation_year, 'notes', OLD.notes,
                       'is_deleted', OLD.is_deleted, 'created_at', OLD.created_at, 'updated_at', OLD.updated_at),
            NOW());
END$$

-- social_meetings テーブル用トリガー
CREATE TRIGGER social_meetings_insert_audit AFTER INSERT ON social_meetings
FOR EACH ROW BEGIN
    INSERT INTO unified_logs (log_type, table_name, record_id, action_type, new_values, user_id, created_at)
    VALUES ('audit', 'social_meetings', CONCAT(NEW.hospital_id, '_', NEW.user_id, '_', NEW.meeting_year), 'INSERT',
            JSON_OBJECT('hospital_id', NEW.hospital_id, 'user_id', NEW.user_id, 
                       'meeting_year', NEW.meeting_year, 'is_deleted', NEW.is_deleted,
                       'created_at', NEW.created_at, 'updated_at', NEW.updated_at),
            NEW.user_id, NOW());
END$$

CREATE TRIGGER social_meetings_update_audit AFTER UPDATE ON social_meetings
FOR EACH ROW BEGIN
    INSERT INTO unified_logs (log_type, table_name, record_id, action_type, old_values, new_values, user_id, created_at)
    VALUES ('audit', 'social_meetings', CONCAT(NEW.hospital_id, '_', NEW.user_id, '_', NEW.meeting_year), 'UPDATE',
            JSON_OBJECT('hospital_id', OLD.hospital_id, 'user_id', OLD.user_id, 
                       'meeting_year', OLD.meeting_year, 'is_deleted', OLD.is_deleted,
                       'created_at', OLD.created_at, 'updated_at', OLD.updated_at),
            JSON_OBJECT('hospital_id', NEW.hospital_id, 'user_id', NEW.user_id, 
                       'meeting_year', NEW.meeting_year, 'is_deleted', NEW.is_deleted,
                       'created_at', NEW.created_at, 'updated_at', NEW.updated_at),
            NEW.user_id, NOW());
END$$

CREATE TRIGGER social_meetings_delete_audit AFTER DELETE ON social_meetings
FOR EACH ROW BEGIN
    INSERT INTO unified_logs (log_type, table_name, record_id, action_type, old_values, created_at)
    VALUES ('audit', 'social_meetings', CONCAT(OLD.hospital_id, '_', OLD.user_id, '_', OLD.meeting_year), 'DELETE',
            JSON_OBJECT('hospital_id', OLD.hospital_id, 'user_id', OLD.user_id, 
                       'meeting_year', OLD.meeting_year, 'is_deleted', OLD.is_deleted,
                       'created_at', OLD.created_at, 'updated_at', OLD.updated_at),
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
    uf.facility_name,
    ud.department_name,
    m.title as maintenance_title,
    m.date as maintenance_date,
    m.start_time as maintenance_start,
    m.end_time as maintenance_end
FROM system_status ss
LEFT JOIN users u ON ss.changed_by = u.user_id
LEFT JOIN kawasaki_university_facilities uf ON u.facility_id = uf.facility_id
LEFT JOIN kawasaki_university_departments ud ON u.department_id = ud.department_id
LEFT JOIN maintenance m ON ss.maintenance_id = m.maintenance_id
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
    uf.facility_name,
    ud.department_name,
    m.created_at,
    CASE 
        WHEN m.date < CURDATE() THEN '完了'
        WHEN m.date = CURDATE() AND CURTIME() BETWEEN COALESCE(m.start_time, '00:00:00') AND COALESCE(m.end_time, '23:59:59') THEN '実行中'
        WHEN m.date = CURDATE() AND CURTIME() < COALESCE(m.start_time, '00:00:00') THEN '本日予定'
        WHEN m.date > CURDATE() THEN '予定'
        ELSE '完了'
    END as status
FROM maintenance m
LEFT JOIN users u ON m.created_by = u.user_id
LEFT JOIN kawasaki_university_facilities uf ON u.facility_id = uf.facility_id
LEFT JOIN kawasaki_university_departments ud ON u.department_id = ud.department_id
WHERE m.view = true
ORDER BY m.date DESC, m.start_time ASC;

-- メッセージ・要望管理ビュー
CREATE VIEW message_management AS
SELECT 
    msg.message_id,
    msg.status,
    msg.comment,
    msg.priority,
    msg.res_date,
    msg.created_at,
    msg.updated_at,
    u_assigned.user_name as assigned_to_name,
    uf_assigned.facility_name as assigned_facility,
    ud_assigned.department_name as assigned_department,
    sv.version_number as implemented_version,
    sv.release_date as version_release_date,
    CASE 
        WHEN msg.status = 'completed' THEN DATEDIFF(msg.res_date, DATE(msg.created_at))
        WHEN msg.status IN ('open', 'in_progress') THEN DATEDIFF(CURDATE(), DATE(msg.created_at))
        ELSE NULL
    END as days_elapsed
FROM message msg
LEFT JOIN users u_assigned ON msg.assigned_to = u_assigned.user_id
LEFT JOIN kawasaki_university_facilities uf_assigned ON u_assigned.facility_id = uf_assigned.facility_id
LEFT JOIN kawasaki_university_departments ud_assigned ON u_assigned.department_id = ud_assigned.department_id
LEFT JOIN system_versions sv ON msg.version_id = sv.version_id
WHERE msg.view = true
ORDER BY 
    CASE msg.priority 
        WHEN 'urgent' THEN 1
        WHEN 'normal' THEN 2
        WHEN 'low' THEN 3
    END,
    msg.created_at DESC;

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
LEFT JOIN message msg ON sv.version_id = msg.version_id
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
    uf_user.facility_name as inquirer_facility,
    ud_user.department_name as inquirer_department,
    u_assigned.user_name as assigned_to_name,
    uf_assigned.facility_name as assigned_facility,
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
LEFT JOIN kawasaki_university_facilities uf_user ON u_user.facility_id = uf_user.facility_id
LEFT JOIN kawasaki_university_departments ud_user ON u_user.department_id = ud_user.department_id
LEFT JOIN users u_assigned ON inq.assigned_to = u_assigned.user_id
LEFT JOIN kawasaki_university_facilities uf_assigned ON u_assigned.facility_id = uf_assigned.facility_id
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
    COUNT(CASE WHEN ul.access_type = 'login' THEN 1 END) as login_count,
    COUNT(CASE WHEN ul.log_type = 'audit' THEN 1 END) as audit_actions,
    COUNT(CASE WHEN ul.log_type = 'security' AND ul.severity IN ('high', 'critical') THEN 1 END) as security_alerts
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

-- バージョンアップ時の安全な切り替えプロシージャ
CREATE PROCEDURE switch_current_version(IN new_version_id INT)
MODIFIES SQL DATA
BEGIN
    DECLARE version_exists INT DEFAULT 0;
    
    -- 指定バージョンが存在するかチェック
    SELECT COUNT(*) INTO version_exists
    FROM system_versions
    WHERE version_id = new_version_id;
    
    IF version_exists > 0 THEN
        -- 全バージョンのis_currentを無効化
        UPDATE system_versions SET is_current = false;
        
        -- 指定バージョンのみ有効化
        UPDATE system_versions 
        SET is_current = true 
        WHERE version_id = new_version_id;
        
        -- ログに記録
        INSERT INTO unified_logs (log_type, table_name, record_id, action_type, description, created_at)
        VALUES ('audit', 'system_versions', new_version_id, 'UPDATE', 
                CONCAT('バージョン切り替え: version_id=', new_version_id), NOW());
    END IF;
END$$

-- 問い合わせの自動エスカレーション処理プロシージャ
CREATE PROCEDURE escalate_urgent_inquiries()
MODIFIES SQL DATA
BEGIN
    -- 緊急度高の問い合わせで24時間以上未対応のものを対応中に移行
    UPDATE inquires 
    SET status = 'in_progress',
        updated_at = CURRENT_TIMESTAMP
    WHERE priority = 'urgent' 
    AND status = 'open'
    AND created_at <= DATE_SUB(NOW(), INTERVAL 24 HOUR);
    
    -- 一般問い合わせで72時間以上未対応のものをログに記録
    INSERT INTO unified_logs (log_type, table_name, record_id, action_type, description, created_at)
    SELECT 'security', 'inquires', inquire_id, 'UPDATE', 
           CONCAT('自動エスカレーション: 72時間未対応 - ', LEFT(description, 100)), NOW()
    FROM inquires
    WHERE priority = 'general'
    AND status = 'open'
    AND created_at <= DATE_SUB(NOW(), INTERVAL 72 HOUR);
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
