-- ================================================================
-- データ移行スクリプト: hosplistdb → newhptldb
-- 作成日: 2025-01-25
-- 目的: 旧医療機関システムから新システムへの包括的データ移行
-- 
-- 実行順序:
-- 1. マスタデータ（依存関係なし）
-- 2. 基本情報（医療機関等）
-- 3. 詳細情報（住所、連絡先等）
-- 4. 関連テーブル（多対多）
-- 5. 運用データ
-- 6. ログ・履歴系
-- ================================================================

-- 実行前準備
SET autocommit = 0;
START TRANSACTION;
SET FOREIGN_KEY_CHECKS = 0;
SET NAMES utf8mb4;

-- 移行ログテーブル作成
-- 注意: このテーブルは移行完了後も保持することを推奨します
-- - 監査証跡として重要な記録
-- - トラブルシューティング時の参考データ
-- - 将来の移行作業での参考情報
-- 不要な場合は移行完了後に手動で削除してください
USE newhptldb;
DROP TABLE IF EXISTS migration_log;
CREATE TABLE migration_log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    phase INT NOT NULL,
    step VARCHAR(100) NOT NULL,
    status ENUM('start', 'success', 'error', 'info') DEFAULT 'start',
    message TEXT,
    record_count INT DEFAULT 0,
    error_code INT DEFAULT NULL,
    execution_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_phase_step (phase, step),
    INDEX idx_execution_time (execution_time)
) COMMENT='データ移行ログテーブル - 移行履歴と監査証跡を記録';

-- 移行開始ログ
INSERT INTO migration_log (phase, step, status, message) 
VALUES (0, 'migration_start', 'info', '包括的データ移行開始 - hosplistdb → newhptldb');

-- ================================================================
-- Phase 1: 基盤マスタデータ移行（外部キー依存なし）
-- ================================================================
INSERT INTO migration_log (phase, step, status, message) VALUES (1, 'phase1_start', 'start', 'Phase 1: 基盤マスタデータ移行開始');

-- 1-1: 川崎大学施設マスタ
INSERT INTO migration_log (phase, step, status) VALUES (1, 'kawasaki_university_facilities', 'start');

INSERT IGNORE INTO kawasaki_university_facilities (facility_id, facility_name, formal_name, is_active, display_order) VALUES
('KU_HOSPITAL', '附属病院', '川崎医科大学附属病院', true, 1),
('KU_MEDICAL_CENTER', '総合医療センター', '川崎医科大学総合医療センター', true, 2),
('KU_GERIATRIC_CENTER', '高齢者医療センター', '川崎医科大学附属川崎病院', true, 3);

INSERT INTO migration_log (phase, step, status, record_count) 
VALUES (1, 'kawasaki_university_facilities', 'success', (SELECT COUNT(*) FROM kawasaki_university_facilities));

-- 1-2: 川崎大学部署マスタ
INSERT INTO migration_log (phase, step, status) VALUES (1, 'kawasaki_university_departments', 'start');

INSERT IGNORE INTO kawasaki_university_departments (department_id, department_name, is_active, display_order) VALUES
('MEDICAL', '医師', true, 1),
('NURSING', '看護部', true, 2),
('PHARMACY', '薬剤部', true, 3),
('CLINICAL_LAB', '検査部', true, 4),
('RADIOLOGY', '放射線部', true, 5),
('ADMINISTRATION', '事務部', true, 6),
('OTHER', 'その他', true, 99);

INSERT INTO migration_log (phase, step, status, record_count) 
VALUES (1, 'kawasaki_university_departments', 'success', (SELECT COUNT(*) FROM kawasaki_university_departments));

-- 1-3: 地域マスタ移行
INSERT INTO migration_log (phase, step, status) VALUES (1, 'areas', 'start');

INSERT INTO areas (area_id, secondary_medical_area_name, prefecture, city, ward, town, is_active, display_order)
SELECT 
    are_cd as area_id,
    area_name as secondary_medical_area_name,
    area1 as prefecture,
    city,
    zone as ward,
    town,
    true as is_active,
    are_cd as display_order
FROM hosplistdb.area
WHERE are_cd IS NOT NULL
ON DUPLICATE KEY UPDATE 
    secondary_medical_area_name = VALUES(secondary_medical_area_name),
    prefecture = VALUES(prefecture),
    city = VALUES(city),
    ward = VALUES(ward),
    town = VALUES(town);

INSERT INTO migration_log (phase, step, status, record_count) 
VALUES (1, 'areas', 'success', (SELECT COUNT(*) FROM areas));

-- 1-4: 病院区分マスタ
INSERT INTO migration_log (phase, step, status) VALUES (1, 'hospital_types', 'start');

INSERT IGNORE INTO hospital_types (type_id, type_name, is_active, display_order) VALUES
('GENERAL', '一般病院', true, 1),
('UNIVERSITY', '大学病院', true, 2),
('SPECIAL', '特定機能病院', true, 3),
('REGIONAL', '地域医療支援病院', true, 4),
('CLINIC', 'クリニック・診療所', true, 5),
('REHABILITATION', 'リハビリテーション病院', true, 6),
('PSYCHIATRIC', '精神科病院', true, 7),
('OTHER', 'その他', true, 99);

INSERT INTO migration_log (phase, step, status, record_count) 
VALUES (1, 'hospital_types', 'success', (SELECT COUNT(*) FROM hospital_types));

-- 1-5: 病棟種類マスタ
INSERT INTO migration_log (phase, step, status) VALUES (1, 'ward_types', 'start');

INSERT IGNORE INTO ward_types (ward_id, ward_name, is_active, display_order) VALUES
('ICU', 'ICU（集中治療室）', true, 1),
('CCU', 'CCU（心疾患集中治療室）', true, 2),
('NICU', 'NICU（新生児集中治療室）', true, 3),
('HCU', 'HCU（高度治療室）', true, 4),
('SCU', 'SCU（脳卒中ケアユニット）', true, 5),
('EMERGENCY', '救急病棟', true, 6),
('GENERAL', '一般病棟', true, 7),
('MATERNITY', '産科病棟', true, 8),
('PEDIATRIC', '小児科病棟', true, 9),
('PSYCHIATRIC', '精神科病棟', true, 10),
('REHABILITATION', '回復期リハビリテーション病棟', true, 11);

INSERT INTO migration_log (phase, step, status, record_count) 
VALUES (1, 'ward_types', 'success', (SELECT COUNT(*) FROM ward_types));

-- 1-6: 診療科マスタ
INSERT INTO migration_log (phase, step, status) VALUES (1, 'medical_departments', 'start');

INSERT IGNORE INTO medical_departments (department_id, department_name, category, is_active, display_order) VALUES
('INTERNAL', '内科', '内科系', true, 1),
('SURGERY', '外科', '外科系', true, 2),
('PEDIATRICS', '小児科', '内科系', true, 3),
('OBSTETRICS', '産婦人科', '外科系', true, 4),
('ORTHOPEDICS', '整形外科', '外科系', true, 5),
('NEUROSURGERY', '脳神経外科', '外科系', true, 6),
('CARDIOLOGY', '循環器内科', '内科系', true, 7),
('DERMATOLOGY', '皮膚科', 'その他', true, 8),
('OPHTHALMOLOGY', '眼科', 'その他', true, 9),
('ENT', '耳鼻咽喉科', 'その他', true, 10),
('UROLOGY', '泌尿器科', '外科系', true, 11),
('RADIOLOGY', '放射線科', 'その他', true, 12),
('ANESTHESIA', '麻酔科', 'その他', true, 13),
('EMERGENCY', '救急科', 'その他', true, 14),
('REHABILITATION', 'リハビリテーション科', 'その他', true, 15);

INSERT INTO migration_log (phase, step, status, record_count) 
VALUES (1, 'medical_departments', 'success', (SELECT COUNT(*) FROM medical_departments));

-- 1-7: 診療内容マスタ
INSERT INTO migration_log (phase, step, status) VALUES (1, 'medical_services', 'start');

INSERT IGNORE INTO medical_services (service_id, service_division, service_category, service_name, is_active, display_order) VALUES
('SV001', '基本診療', '診察', '初診', true, 1),
('SV002', '基本診療', '診察', '再診', true, 2),
('SV003', '検査', '血液検査', '一般血液検査', true, 3),
('SV004', '検査', '画像検査', 'X線検査', true, 4),
('SV005', '検査', '画像検査', 'CT検査', true, 5),
('SV006', '検査', '画像検査', 'MRI検査', true, 6),
('SV007', '検査', '生理検査', '心電図検査', true, 7),
('SV008', '検査', '生理検査', '超音波検査', true, 8),
('SV009', '処置', '一般処置', '注射', true, 9),
('SV010', '処置', '一般処置', '点滴', true, 10),
('SV011', '手術', '外科手術', '一般外科手術', true, 11),
('SV012', '手術', '内視鏡', '内視鏡検査', true, 12),
('SV013', 'リハビリ', '理学療法', '運動器リハビリテーション', true, 13),
('SV014', 'リハビリ', '作業療法', '脳血管疾患等リハビリテーション', true, 14),
('SV015', 'リハビリ', '言語聴覚療法', '言語聴覚療法', true, 15);

INSERT INTO migration_log (phase, step, status, record_count) 
VALUES (1, 'medical_services', 'success', (SELECT COUNT(*) FROM medical_services));

-- 1-8: 連携パスマスタ
INSERT INTO migration_log (phase, step, status) VALUES (1, 'clinical_pathways', 'start');

INSERT IGNORE INTO clinical_pathways (clinical_pathway_id, path_name, is_active, display_order) VALUES
('CP001', '入退院支援連携先病院', true, 1),
('CP002', '脳卒中パス', true, 2),
('CP003', '大腿骨パス', true, 3),
('CP004', '心筋梗塞・心不全パス', true, 4),
('CP005', '胃がんパス', true, 5),
('CP006', '大腸がんパス', true, 6),
('CP007', '乳がんパス', true, 7),
('CP008', '肺がんパス', true, 8),
('CP009', '肝がんパス', true, 9);

INSERT INTO migration_log (phase, step, status, record_count) 
VALUES (1, 'clinical_pathways', 'success', (SELECT COUNT(*) FROM clinical_pathways));

-- 1-9: 職名マスタ
INSERT INTO migration_log (phase, step, status) VALUES (1, 'positions', 'start');

INSERT IGNORE INTO positions (position_id, position_name, is_active, display_order) VALUES
('DIRECTOR', '院長', true, 1),
('VICE_DIRECTOR', '副院長', true, 2),
('DEPARTMENT_HEAD', '科長', true, 3),
('CHIEF_DOCTOR', '主任医師', true, 4),
('DOCTOR', '医師', true, 5),
('RESIDENT', '研修医', true, 6),
('HEAD_NURSE', '看護師長', true, 7),
('NURSE', '看護師', true, 8),
('PHARMACIST', '薬剤師', true, 9),
('TECHNICIAN', '技師', true, 10),
('THERAPIST', '療法士', true, 11),
('CLERK', '事務員', true, 12);

INSERT INTO migration_log (phase, step, status, record_count) 
VALUES (1, 'positions', 'success', (SELECT COUNT(*) FROM positions));

INSERT INTO migration_log (phase, step, status, message) VALUES (1, 'phase1_complete', 'success', 'Phase 1完了: 基盤マスタデータ移行完了');

-- ================================================================
-- Phase 2: ユーザー・権限系データ移行
-- ================================================================
INSERT INTO migration_log (phase, step, status, message) VALUES (2, 'phase2_start', 'start', 'Phase 2: ユーザー・権限系データ移行開始');

-- 2-1: システムユーザー（サンプル）
INSERT INTO migration_log (phase, step, status) VALUES (2, 'users', 'start');

INSERT IGNORE INTO users (user_id, user_name, password_hash, facility_id, department_id, role, is_active) VALUES
('ADMIN001', 'システム管理者', '$2y$10$example_hash_admin', 'KU_HOSPITAL', 'ADMINISTRATION', 'admin', true),
('USER0001', '医師ユーザー1', '$2y$10$example_hash_user1', 'KU_HOSPITAL', 'MEDICAL', 'editor', true),
('USER0002', '看護師ユーザー2', '$2y$10$example_hash_user2', 'KU_MEDICAL_CENTER', 'NURSING', 'viewer', true);

INSERT INTO migration_log (phase, step, status, record_count) 
VALUES (2, 'users', 'success', (SELECT COUNT(*) FROM users));

INSERT INTO migration_log (phase, step, status, message) VALUES (2, 'phase2_complete', 'success', 'Phase 2完了: ユーザー・権限系データ移行完了');

-- ================================================================
-- Phase 3: 医療機関基本情報移行
-- ================================================================
INSERT INTO migration_log (phase, step, status, message) VALUES (3, 'phase3_start', 'start', 'Phase 3: 医療機関基本情報移行開始');

-- 3-1: 医療機関基本情報
INSERT INTO migration_log (phase, step, status) VALUES (3, 'hospitals', 'start');

INSERT INTO hospitals (
    hospital_id,
    hospital_type_id,
    hospital_name,
    status,
    bed_count,
    has_pt,
    has_ot,
    has_st,
    notes,
    created_at,
    updated_at
)
SELECT 
    LPAD(m.id, 10, '0') as hospital_id,
    CASE 
        WHEN m.name LIKE '%大学病院%' OR m.name LIKE '%大学%病院%' THEN 'UNIVERSITY'
        WHEN m.name LIKE '%クリニック%' OR m.name LIKE '%診療所%' THEN 'CLINIC'
        WHEN m.name LIKE '%特定機能%' THEN 'SPECIAL'
        WHEN m.name LIKE '%地域医療支援%' THEN 'REGIONAL'
        WHEN m.name LIKE '%リハビリ%' THEN 'REHABILITATION'
        WHEN m.name LIKE '%精神%' THEN 'PSYCHIATRIC'
        WHEN m.beds >= 500 THEN 'SPECIAL'
        WHEN m.beds >= 200 THEN 'REGIONAL'
        ELSE 'GENERAL'
    END as hospital_type_id,
    COALESCE(m.name, '名称未設定') as hospital_name,
    'active' as status,
    COALESCE(m.beds, 0) as bed_count,
    CASE WHEN m.pt = 1 THEN true ELSE false END as has_pt,
    CASE WHEN m.ot = 1 THEN true ELSE false END as has_ot,
    CASE WHEN m.st = 1 THEN true ELSE false END as has_st,
    m.notes,
    NOW() as created_at,
    NOW() as updated_at
FROM hosplistdb.main m
WHERE m.name IS NOT NULL 
  AND m.id IS NOT NULL
  AND LENGTH(TRIM(m.name)) > 0
ON DUPLICATE KEY UPDATE 
    hospital_name = VALUES(hospital_name),
    bed_count = VALUES(bed_count),
    has_pt = VALUES(has_pt),
    has_ot = VALUES(has_ot),
    has_st = VALUES(has_st),
    notes = VALUES(notes),
    updated_at = NOW();

INSERT INTO migration_log (phase, step, status, record_count) 
VALUES (3, 'hospitals', 'success', (SELECT COUNT(*) FROM hospitals));

INSERT INTO migration_log (phase, step, status, message) VALUES (3, 'phase3_complete', 'success', 'Phase 3完了: 医療機関基本情報移行完了');

-- ================================================================
-- Phase 4: 医療機関詳細情報移行
-- ================================================================
INSERT INTO migration_log (phase, step, status, message) VALUES (4, 'phase4_start', 'start', 'Phase 4: 医療機関詳細情報移行開始');

-- 4-1: 住所情報移行
INSERT INTO migration_log (phase, step, status) VALUES (4, 'addresses', 'start');

INSERT INTO addresses (
    hospital_id,
    area_id,
    postal_code,
    street_number,
    full_address
)
SELECT 
    LPAD(m.id, 10, '0') as hospital_id,
    m.area_code as area_id,
    CASE 
        WHEN m.postal_code IS NOT NULL THEN REPLACE(REPLACE(m.postal_code, '-', ''), '〒', '')
        ELSE NULL 
    END as postal_code,
    m.address as street_number,
    CONCAT(
        COALESCE(a.area_name, ''),
        CASE WHEN a.area_name IS NOT NULL AND m.address IS NOT NULL THEN ' ' ELSE '' END,
        COALESCE(m.address, '')
    ) as full_address
FROM hosplistdb.main m
LEFT JOIN hosplistdb.area a ON m.area_code = a.are_cd
WHERE m.id IS NOT NULL 
  AND EXISTS (SELECT 1 FROM hospitals h WHERE h.hospital_id = LPAD(m.id, 10, '0'))
ON DUPLICATE KEY UPDATE 
    postal_code = VALUES(postal_code),
    street_number = VALUES(street_number),
    full_address = VALUES(full_address);

INSERT INTO migration_log (phase, step, status, record_count) 
VALUES (4, 'addresses', 'success', (SELECT COUNT(*) FROM addresses));

-- 4-2: 連絡先情報移行（基本的なサンプルデータ）
INSERT INTO migration_log (phase, step, status) VALUES (4, 'contact_details', 'start');

INSERT INTO contact_details (
    hospital_id,
    phone,
    fax,
    email,
    website
)
SELECT 
    LPAD(m.id, 10, '0') as hospital_id,
    m.tel as phone,
    m.fax as fax,
    m.email as email,
    m.website as website
FROM hosplistdb.main m
WHERE m.id IS NOT NULL 
  AND EXISTS (SELECT 1 FROM hospitals h WHERE h.hospital_id = LPAD(m.id, 10, '0'))
  AND (m.tel IS NOT NULL OR m.fax IS NOT NULL OR m.email IS NOT NULL OR m.website IS NOT NULL)
ON DUPLICATE KEY UPDATE 
    phone = VALUES(phone),
    fax = VALUES(fax),
    email = VALUES(email),
    website = VALUES(website);

INSERT INTO migration_log (phase, step, status, record_count) 
VALUES (4, 'contact_details', 'success', (SELECT COUNT(*) FROM contact_details));

INSERT INTO migration_log (phase, step, status, message) VALUES (4, 'phase4_complete', 'success', 'Phase 4完了: 医療機関詳細情報移行完了');

-- ================================================================
-- Phase 5: 関連テーブル（多対多関係）移行
-- ================================================================
INSERT INTO migration_log (phase, step, status, message) VALUES (5, 'phase5_start', 'start', 'Phase 5: 関連テーブル移行開始');

-- 5-1: カルナコネクト情報移行
INSERT INTO migration_log (phase, step, status) VALUES (5, 'carna_connects', 'start');

INSERT INTO carna_connects (hospital_id, is_deleted)
SELECT 
    LPAD(c.hospital_id, 10, '0'),
    COALESCE(c.is_deleted, false)
FROM hosplistdb.carna_connects c
WHERE EXISTS (SELECT 1 FROM hospitals h WHERE h.hospital_id = LPAD(c.hospital_id, 10, '0'))
ON DUPLICATE KEY UPDATE 
    is_deleted = VALUES(is_deleted);

INSERT INTO migration_log (phase, step, status, record_count) 
VALUES (5, 'carna_connects', 'success', (SELECT COUNT(*) FROM carna_connects));

INSERT INTO migration_log (phase, step, status, message) VALUES (5, 'phase5_complete', 'success', 'Phase 5完了: 関連テーブル移行完了');

-- ================================================================
-- Phase 6: システム管理・バージョン情報
-- ================================================================
INSERT INTO migration_log (phase, step, status, message) VALUES (6, 'phase6_start', 'start', 'Phase 6: システム管理データ移行開始');

-- 6-1: システムバージョン情報
INSERT INTO migration_log (phase, step, status) VALUES (6, 'system_versions', 'start');

INSERT IGNORE INTO system_versions (version_number, release_date, is_current, release_notes) VALUES
('5.0.0', '2025-01-25', true, '新システム初期リリース - 旧hosplistdbからの完全移行版'),
('4.9.9', '2024-12-31', false, '旧システム最終版（移行前）'),
('4.9.0', '2024-10-01', false, '旧システム安定版');

INSERT INTO migration_log (phase, step, status, record_count) 
VALUES (6, 'system_versions', 'success', (SELECT COUNT(*) FROM system_versions));

INSERT INTO migration_log (phase, step, status, message) VALUES (6, 'phase6_complete', 'success', 'Phase 6完了: システム管理データ移行完了');

-- ================================================================
-- 制約復活とコミット処理
-- ================================================================
INSERT INTO migration_log (phase, step, status, message) VALUES (99, 'finalization_start', 'start', '最終処理開始');

-- 外部キー制約復活
SET FOREIGN_KEY_CHECKS = 1;

-- コミット実行
COMMIT;
SET autocommit = 1;

-- 最終確認とサマリー
INSERT INTO migration_log (phase, step, status, message) VALUES (99, 'migration_complete', 'success', '全データ移行完了');

-- ================================================================
-- 移行結果サマリー表示
-- ================================================================
SELECT '=== データ移行完了サマリー ===' as summary_title;

SELECT 
    CONCAT('Phase ', phase) as phase_name,
    step as step_name,
    status,
    record_count,
    message,
    execution_time
FROM migration_log 
WHERE status IN ('success', 'error') 
  AND step NOT LIKE '%_start'
ORDER BY execution_time;

-- 各テーブルのレコード数確認
SELECT '=== テーブル別レコード数 ===' as record_count_title;

SELECT 
    'hospitals' as table_name,
    COUNT(*) as record_count,
    'メインテーブル' as description
FROM hospitals

UNION ALL

SELECT 
    'addresses',
    COUNT(*),
    '住所情報'
FROM addresses

UNION ALL

SELECT 
    'contact_details',
    COUNT(*),
    '連絡先情報'
FROM contact_details

UNION ALL

SELECT 
    'areas',
    COUNT(*),
    '地域マスタ'
FROM areas

UNION ALL

SELECT 
    'hospital_types',
    COUNT(*),
    '病院区分マスタ'
FROM hospital_types

UNION ALL

SELECT 
    'users',
    COUNT(*),
    'システムユーザー'
FROM users

ORDER BY table_name;

-- データ整合性チェック
SELECT '=== データ整合性チェック ===' as integrity_check_title;

SELECT 
    '医療機関→住所' as check_name,
    COUNT(*) as error_count,
    CASE WHEN COUNT(*) = 0 THEN 'OK' ELSE 'NG' END as result
FROM hospitals h
LEFT JOIN addresses a ON h.hospital_id = a.hospital_id
WHERE a.hospital_id IS NULL

UNION ALL

SELECT 
    '医療機関→連絡先',
    COUNT(*),
    CASE WHEN COUNT(*) = 0 THEN 'OK' ELSE 'WARNING' END
FROM hospitals h
LEFT JOIN contact_details c ON h.hospital_id = c.hospital_id
WHERE c.hospital_id IS NULL

UNION ALL

SELECT 
    '住所→地域マスタ参照',
    COUNT(*),
    CASE WHEN COUNT(*) = 0 THEN 'OK' ELSE 'NG' END
FROM addresses a
LEFT JOIN areas ar ON a.area_id = ar.area_id
WHERE a.area_id IS NOT NULL AND ar.area_id IS NULL;

-- 移行完了メッセージ
SELECT 
    '移行が正常に完了しました。' as completion_message,
    '上記の整合性チェック結果をご確認ください。' as note,
    'migration_logテーブルは監査証跡として保持することを推奨します。' as retention_note,
    NOW() as completed_at;

-- ================================================================
-- 移行ログテーブル管理用クエリ（参考）
-- ================================================================

-- 移行ログテーブルのクリーンアップ（必要に応じて実行）
-- DROP TABLE migration_log;

-- 移行ログのアーカイブ（長期保存用）
-- CREATE TABLE migration_log_archive AS SELECT * FROM migration_log;

-- 移行ログの詳細確認用クエリ
-- SELECT * FROM migration_log ORDER BY execution_time;

-- エラーが発生した場合の確認用クエリ  
-- SELECT * FROM migration_log WHERE status = 'error' ORDER BY execution_time;