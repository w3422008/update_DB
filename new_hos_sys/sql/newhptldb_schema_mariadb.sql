-- =====================================================
-- newhptldb データベース スキーマファイル (MariaDB対応版)
-- 作成日: 2025年10月5日
-- 対象: MariaDB 10.3+
-- 変更点: boolean型 → TINYINT(1)に変更
-- =====================================================

DROP DATABASE IF EXISTS newhptldb;
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
    is_active TINYINT(1) DEFAULT 1 COMMENT '有効フラグ',
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
    has_pt TINYINT(1) DEFAULT 0 COMMENT '理学療法士在籍フラグ',
    has_ot TINYINT(1) DEFAULT 0 COMMENT '作業療法士在籍フラグ',
    has_st TINYINT(1) DEFAULT 0 COMMENT '言語聴覚療法士在籍フラグ',
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
    is_active TINYINT(1) DEFAULT 1 COMMENT '有効フラグ',
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
    is_deleted TINYINT(1) DEFAULT 0 COMMENT '削除フラグ',
    FOREIGN KEY (hospital_id) REFERENCES hospitals(hospital_id)
) COMMENT = '医療機関の連絡先情報を管理';

DROP TABLE IF EXISTS ward_types;
CREATE TABLE ward_types (
    ward_id varchar(10) PRIMARY KEY NOT NULL COMMENT '病棟種類ID',
    ward_name varchar(20) NOT NULL COMMENT '病棟名',
    is_active TINYINT(1) DEFAULT 1 COMMENT '有効フラグ',
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
    is_available TINYINT(1) DEFAULT 1 COMMENT '診療可否',
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
    is_active TINYINT(1) DEFAULT 1 COMMENT '有効フラグ',
    display_order int(11) NOT NULL DEFAULT 0 COMMENT '表示順序'
) COMMENT = '診療科の分類と詳細を管理';

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
    is_active TINYINT(1) DEFAULT 1 COMMENT '有効フラグ',
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
    is_active TINYINT(1) DEFAULT 1 COMMENT '有効フラグ',
    display_order int(11) AUTO_INCREMENT UNIQUE KEY COMMENT '表示順序'
) COMMENT = '地域連携クリニカルパス名を管理';

DROP TABLE IF EXISTS clinical_pathway_hospitals;
CREATE TABLE clinical_pathway_hospitals (
    hospital_id varchar(10) COMMENT '医療機関コード',
    clinical_pathway_id varchar(10) COMMENT '連携パスID',
    user_facility_id varchar(20) COMMENT '登録者所属施設ID',
    PRIMARY KEY (hospital_id, clinical_pathway_id, user_facility_id),
    FOREIGN KEY (hospital_id) REFERENCES hospitals(hospital_id),
    FOREIGN KEY (clinical_pathway_id) REFERENCES clinical_pathways(clinical_pathway_id)
) COMMENT = '地域連携クリニカルパスの存在有無を管理';

DROP TABLE IF EXISTS carna_connects;
CREATE TABLE carna_connects (
    hospital_id varchar(10) PRIMARY KEY COMMENT '医療機関コード',
    is_deleted TINYINT(1) DEFAULT 0 COMMENT '削除フラグ'
) COMMENT = 'カルナコネクトと連携しているかどうかを管理';

-- 川崎学園マスタテーブルを先に作成
DROP TABLE IF EXISTS kawasaki_university_facilities;
CREATE TABLE kawasaki_university_facilities (
    facility_id varchar(20) PRIMARY KEY COMMENT '所属施設ID',
    facility_name varchar(50) NOT NULL COMMENT '施設名',
    formal_name varchar(60) NOT NULL COMMENT '正式名称',
    abbreviation varchar(50) NULL COMMENT '略称',
    is_active TINYINT(1) DEFAULT 1 COMMENT '有効フラグ',
    display_order int(11) NOT NULL DEFAULT 0 COMMENT '表示順序'
) COMMENT = '川崎学園の病院情報を管理（附属病院、総合医療センター、高齢者医療センター）';

DROP TABLE IF EXISTS kawasaki_university_departments;
CREATE TABLE kawasaki_university_departments (
    department_id varchar(20) PRIMARY KEY COMMENT '部署ID',
    department_name varchar(50) NOT NULL COMMENT '部署名',
    is_active TINYINT(1) DEFAULT 1 COMMENT '有効フラグ',
    display_order int(11) NOT NULL DEFAULT 0 COMMENT '表示順序'
) COMMENT = '川崎学園の部署情報を管理';

DROP TABLE IF EXISTS users;
CREATE TABLE users (
    user_id varchar(8) PRIMARY KEY COMMENT 'ユーザーID',
    user_name varchar(50) NOT NULL COMMENT 'ユーザー名',
    password_hash varchar(255) NOT NULL COMMENT 'パスワードハッシュ',
    facility_id varchar(20) NOT NULL COMMENT '所属施設',
    department_id varchar(20) NOT NULL COMMENT '所属部署',
    role enum('system_admin','admin','editor','viewer') DEFAULT 'viewer' COMMENT '権限レベル',
    is_active TINYINT(1) DEFAULT 1 COMMENT 'アカウント有効フラグ',
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
    is_admin TINYINT(1) DEFAULT 0 COMMENT '管理者フラグ',
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
    user_facility_id varchar(20) COMMENT '登録者所属施設ID',
    year year COMMENT '年度',
    date date COMMENT '診療日',
    department_name varchar(30) COMMENT '診療科',
    intro_type enum('intro','invers_intro') DEFAULT 'intro' COMMENT '紹介・逆紹介判定',
    department_id varchar(10) COMMENT '診療科コード',
    intro_count int(11) NOT NULL COMMENT '紹介・逆紹介件数',
    PRIMARY KEY (hospital_id, user_facility_id, year, date, department_name, intro_type),
    FOREIGN KEY (hospital_id) REFERENCES hospitals(hospital_id)
) COMMENT = '医療機関間の紹介情報を管理';

-- 職名マスタテーブルを追加
DROP TABLE IF EXISTS positions;
CREATE TABLE positions (
    position_id varchar(20) PRIMARY KEY COMMENT '職名ID',
    position_name varchar(60) NOT NULL COMMENT '職名',
    is_active TINYINT(1) DEFAULT 1 COMMENT '有効フラグ',
    display_order int(11) NOT NULL DEFAULT 0 COMMENT '表示順序'
) COMMENT = '職名マスタテーブル';

DROP TABLE IF EXISTS training;
CREATE TABLE training (
    hospital_id varchar(10) COMMENT '医療機関コード',
    year year COMMENT '年度',
    user_facility_id varchar(20) COMMENT '登録者所属施設ID',
    department varchar(60) COMMENT '診療科',
    staff_name varchar(60) NOT NULL COMMENT '氏名',
    position_id varchar(20) COMMENT '職名',
    start_date date COMMENT '診療支援開始日',
    end_date date COMMENT '診療支援終了日',
    date varchar(300) COMMENT '日付',
    diagnostic_aid varchar(50) COMMENT '診療支援区分',
    PRIMARY KEY (hospital_id, year, user_facility_id, department, start_date),
    FOREIGN KEY (hospital_id) REFERENCES hospitals(hospital_id),
    FOREIGN KEY (position_id) REFERENCES positions(position_id)
) COMMENT = '複数の医療機関へ研修・勤務している人物を管理';

DROP TABLE IF EXISTS contacts;
CREATE TABLE contacts (
    hospital_id varchar(10) COMMENT '医療機関コード',
    year year(4) COMMENT '年度',
    user_facility_id varchar(20) COMMENT '登録者所属施設ID',
    date date COMMENT '日付',
    method varchar(50) COMMENT '方法（来院、訪問、オンライン等）',
    external_contact_name varchar(10) NOT NULL COMMENT '連携機関対応者氏名',
    external_department varchar(50) COMMENT '連携機関対応者部署',
    external_position varchar(50) COMMENT '連携機関対応者役職',
    external_additional_participants varchar(100) COMMENT '連携機関対応人数・氏名',
    internal_contact_name varchar(10) NOT NULL COMMENT '当院対応者氏名',
    internal_department varchar(50) COMMENT '当院対応者所属',
    internal_additional_participants varchar(100) COMMENT '当院対応人数・氏名',
    detail varchar(100) COMMENT '内容',
    notes varchar(100) COMMENT '備考',
    data_department varchar(50) COMMENT 'データ作成部署',
    PRIMARY KEY (hospital_id, year, user_facility_id, date, method),
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
DROP TABLE IF EXISTS maintenances;
CREATE TABLE maintenances (
    maintenance_id bigint(20) PRIMARY KEY AUTO_INCREMENT COMMENT 'メンテナンスID',
    title varchar(200) NOT NULL COMMENT 'タイトル',
    comment text NOT NULL COMMENT '実施内容',
    date date NOT NULL COMMENT '予定作業日',
    start_time time NULL COMMENT '予定開始時刻',
    end_time time NULL COMMENT '予定終了時刻',
    view TINYINT(1) NOT NULL DEFAULT 1 COMMENT '表示フラグ',
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
    view TINYINT(1) NOT NULL DEFAULT 1 COMMENT '表示フラグ',
    created_by varchar(8) NOT NULL COMMENT '作成者ユーザーID',
    created_at datetime DEFAULT CURRENT_TIMESTAMP COMMENT '作成日時',
    updated_at datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新日時',
    FOREIGN KEY (maintenance_id) REFERENCES maintenances(maintenance_id),
    FOREIGN KEY (created_by) REFERENCES users(user_id)
) COMMENT = 'メンテナンス実行中の通知を管理';

-- システムバージョン管理テーブル
DROP TABLE IF EXISTS system_versions;
CREATE TABLE system_versions (
    version_id int(11) PRIMARY KEY AUTO_INCREMENT COMMENT 'バージョン管理ID',
    version_number varchar(20) NOT NULL UNIQUE COMMENT 'バージョン番号（例：4.5.2）',
    release_date date NOT NULL COMMENT 'リリース日',
    is_current TINYINT(1) NOT NULL DEFAULT 0 COMMENT '現在稼働バージョンフラグ',
    release_notes text NULL COMMENT 'リリースノート・変更内容',
    created_at datetime DEFAULT CURRENT_TIMESTAMP COMMENT '作成日時'
) COMMENT = 'システムのバージョン情報を最小限で管理';

-- メッセージテーブル（システム更新履歴・要望管理）
DROP TABLE IF EXISTS messages;
CREATE TABLE messages (
    message_id bigint(20) PRIMARY KEY AUTO_INCREMENT COMMENT 'メッセージID',
    status enum('open','in_progress','completed','rejected') DEFAULT 'open' COMMENT '対応状況',
    comment text NOT NULL COMMENT '内容',
    view TINYINT(1) NOT NULL DEFAULT 1 COMMENT '表示フラグ',
    version_id int(11) NULL COMMENT '実装バージョンID',
    assigned_to varchar(8) COMMENT '担当者ユーザーID',
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
    relative_name varchar(60) NOT NULL COMMENT '人物名',
    connection varchar(30) COMMENT '関係',
    school_name varchar(100) COMMENT '学校名',
    entrance_year year(4) COMMENT '入学年',
    graduation_year year(4) COMMENT '卒業年',
    notes text COMMENT '備考',
    is_deleted TINYINT(1) DEFAULT 0 COMMENT '削除フラグ',
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
    user_facility_id varchar(20) COMMENT '登録者所属施設ID',
    meeting_year year(4) COMMENT '参加年度',
    is_deleted TINYINT(1) DEFAULT 0 COMMENT '削除フラグ',
    created_at datetime DEFAULT CURRENT_TIMESTAMP COMMENT '作成日時',
    updated_at datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新日時',
    PRIMARY KEY (hospital_id, user_facility_id, meeting_year),
    FOREIGN KEY (hospital_id) REFERENCES hospitals(hospital_id)
) COMMENT = '医療連携懇話会への参加年度を管理';

-- 外部キー制約チェックを再度有効化
SET FOREIGN_KEY_CHECKS = 1;

-- =================================================================
-- インデックス追加（パフォーマンス向上）
-- =================================================================

-- maintenancesテーブル
CREATE INDEX idx_maintenances_date ON maintenances(date);
CREATE INDEX idx_maintenances_view ON maintenances(view);
CREATE INDEX idx_maintenances_created_by ON maintenances(created_by);

-- maintenance_startテーブル
CREATE INDEX idx_maintenance_start_maintenance_id ON maintenance_start(maintenance_id);
CREATE INDEX idx_maintenance_start_view ON maintenance_start(view);

-- system_versionsテーブル
CREATE INDEX idx_system_versions_is_current ON system_versions(is_current);
CREATE INDEX idx_system_versions_release_date ON system_versions(release_date);

-- messagesテーブル
CREATE INDEX idx_messages_status ON messages(status);
CREATE INDEX idx_messages_assigned_to ON messages(assigned_to);
CREATE INDEX idx_messages_version_id ON messages(version_id);
CREATE INDEX idx_messages_created_at ON messages(created_at);

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

-- usersテーブル
CREATE INDEX idx_users_user_name ON users(user_name);
CREATE INDEX idx_users_active ON users(is_active);
CREATE INDEX idx_users_facility_department ON users(facility_id, department_id);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_last_login ON users(last_login_at);
CREATE INDEX idx_users_created_at ON users(created_at);
CREATE INDEX idx_users_active_role ON users(is_active, role);

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
CREATE INDEX idx_social_meetings_user_facility_id ON social_meetings(user_facility_id);
CREATE INDEX idx_social_meetings_meeting_year ON social_meetings(meeting_year);
CREATE INDEX idx_social_meetings_is_deleted ON social_meetings(is_deleted);
CREATE INDEX idx_social_meetings_created_at ON social_meetings(created_at);

-- =================================================================
-- 自動ログ記録用トリガー（MariaDB対応版）
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

-- users テーブル用トリガー（パスワードハッシュ除外）
CREATE TRIGGER users_insert_audit AFTER INSERT ON users
FOR EACH ROW BEGIN
    INSERT INTO unified_logs (log_type, table_name, record_id, action_type, new_values, user_id, created_at)
    VALUES ('audit', 'users', NEW.user_id, 'INSERT', 
            JSON_OBJECT('user_id', NEW.user_id, 'user_name', NEW.user_name, 'facility_id', NEW.facility_id, 
                       'department_id', NEW.department_id, 'role', NEW.role, 'is_active', NEW.is_active,
                       'created_at', NEW.created_at, 'updated_at', NEW.updated_at, 'last_login_at', NEW.last_login_at),
            NEW.user_id, NOW());
END$$

CREATE TRIGGER users_update_audit AFTER UPDATE ON users
FOR EACH ROW BEGIN
    INSERT INTO unified_logs (log_type, table_name, record_id, action_type, old_values, new_values, user_id, created_at)
    VALUES ('audit', 'users', NEW.user_id, 'UPDATE',
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
    INSERT INTO unified_logs (log_type, table_name, record_id, action_type, old_values, created_at)
    VALUES ('audit', 'users', OLD.user_id, 'DELETE',
            JSON_OBJECT('user_id', OLD.user_id, 'user_name', OLD.user_name, 'facility_id', OLD.facility_id, 
                       'department_id', OLD.department_id, 'role', OLD.role, 'is_active', OLD.is_active,
                       'created_at', OLD.created_at, 'updated_at', OLD.updated_at, 'last_login_at', OLD.last_login_at),
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
    COUNT(*) as action_count,
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
    u.user_name,
    u.facility_id as user_facility_id,
    u.department_id as user_department_id
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
    u.user_name,
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
GROUP BY u.user_id, u.user_name, u.facility_id, u.department_id
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
    ss.created_at,
    u.user_name as changed_by_name,
    uf.facility_name as changed_by_facility,
    ud.department_name as changed_by_department,
    m.title as maintenance_title,
    m.date as maintenance_date,
    m.start_time as maintenance_start,
    m.end_time as maintenance_end
FROM system_status ss
LEFT JOIN users u ON ss.changed_by = u.user_id
LEFT JOIN kawasaki_university_facilities uf ON u.facility_id = uf.facility_id
LEFT JOIN kawasaki_university_departments ud ON u.department_id = ud.department_id
LEFT JOIN maintenances m ON ss.maintenance_id = m.maintenance_id
ORDER BY ss.created_at DESC
LIMIT 1;

-- =================================================================
-- 便利な関数・プロシージャ（MariaDB対応版）
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
    WHERE is_current = 1
    ORDER BY version_id DESC
    LIMIT 1;
    RETURN current_ver;
END$$

DELIMITER ;

-- =================================================================
-- MariaDB固有の最適化設定
-- =================================================================

-- 文字セットとコロケーションの確認
-- MariaDBでのutf8mb4最適化
SET @old_sql_mode = @@sql_mode;
SET sql_mode = 'NO_AUTO_VALUE_ON_ZERO';

-- MariaDBでのJSON型サポート確認（10.2.3以降）
-- 古いバージョンの場合はTEXTまたはLONGTEXTに変更を検討

-- 完了メッセージ
SELECT 
    'MariaDB対応スキーマファイルの作成が完了しました' as message,
    '主な変更点: boolean型 → TINYINT(1)' as changes,
    get_current_version() as current_version;