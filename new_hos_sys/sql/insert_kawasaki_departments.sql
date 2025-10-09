-- =====================================================
-- 川崎大学部署データ インポート用SQLファイル
-- 作成日: 2025年10月5日
-- 概要: config.phpの3つの配列から部署データを統合し、
--       kawasaki_university_departmentsテーブルにインポート
-- =====================================================

USE newhptldb;

-- 外部キー制約チェックを一時的に無効化
SET FOREIGN_KEY_CHECKS = 0;

-- =====================================================
-- 1. データの削除（逆順で削除）
-- =====================================================
DELETE FROM `users`;
DELETE FROM `kawasaki_university_departments`;
DELETE FROM `kawasaki_university_facilities`;

-- 外部キー制約チェックを再有効化
SET FOREIGN_KEY_CHECKS = 1;

-- =====================================================
-- 2. 最初に施設データ（親テーブル）を挿入
-- =====================================================
INSERT INTO `kawasaki_university_facilities` (`facility_id`, `facility_name`, `abbreviation`, `is_active`, `display_order`) VALUES
	('GeneralMCenter', '川崎医科大学総合医療センター', '総', 1, 1),
	('GeriatricMCenter', '川崎医科大学高齢者医療センター', '高', 1, 2),
	('KMSHospital', '川崎医科大学附属病院', '附', 1, 0);

-- =====================================================
-- 3. 次に部署データ（facility_idを参照）を挿入
-- =====================================================
-- 部署データの挿入
-- 出典: config.php内の$user_bel, $center_bel, $kourei_bel配列より統合
INSERT INTO kawasaki_university_departments (department_id, department_name, facility_id) VALUES
-- user_bel配列より
('PSUPPORT', '患者診療支援センター','KMSHospital'),
('PLANNING', '企画部企画室','KMSHospital'),
('WORKREFORM', '病院働き方改革推進室','KMSHospital'),
('ADMIN', '病院庶務課','KMSHospital'),
('MEDRECORD', '医療資料部','KMSHospital'),
('MEDAFFAIR', '医事課','KMSHospital'),

-- center_bel配列より（重複除く）
('ADMINSEC', '病院庶務課 庶務係','GeneralMCenter'),

-- kourei_bel配列より（重複除く）
('OFFICE', '病院事務室','GeriatricMCenter');

-- =====================================================
-- 4. 最後にユーザーデータ（department_idを参照）を挿入
-- =====================================================
INSERT INTO `users` (`user_id`, `user_name`, `password_hash`, `department_id`, `role`, `is_active`, `last_login_at`, `created_at`, `updated_at`) VALUES
	('doctor01', 'ドクター', '$2y$10$QPoxlrkl4rO0Cji13e4TqeSwVUFOv9L9MkYnlyHNDS1rVp.piutkC', 'MEDRECORD', 'viewer', 1, NULL, '2025-10-04 16:08:07', '2025-10-04 16:08:07'),
	('nurse01', 'ナース', '$2y$10$QPoxlrkl4rO0Cji13e4TqeSwVUFOv9L9MkYnlyHNDS1rVp.piutkC', 'PSUPPORT', 'editor', 1, '2025-08-16 21:22:18', NULL, NULL),
	('admin01', '管理者', '$2y$10$QPoxlrkl4rO0Cji13e4TqeSwVUFOv9L9MkYnlyHNDS1rVp.piutkC', 'MEDRECORD', 'system_admin', 1, '2025-08-16 21:22:18', NULL, NULL);
