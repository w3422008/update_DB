-- --------------------------------------------------------
-- ホスト:                          127.0.0.1
-- サーバーのバージョン:                   10.4.32-MariaDB - mariadb.org binary distribution
-- サーバー OS:                      Win64
-- HeidiSQL バージョン:               12.8.0.6908
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- new_hossysdb のデータベース構造をダンプしています
DROP DATABASE IF EXISTS `new_hossysdb`;
CREATE DATABASE IF NOT EXISTS `new_hossysdb` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci */;
USE `new_hossysdb`;

--  テーブル new_hossysdb.login_attempts の構造をダンプしています
DROP TABLE IF EXISTS `login_attempts`;
CREATE TABLE IF NOT EXISTS `login_attempts` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `key_name` varchar(128) NOT NULL COMMENT 'ユーザーID',
  `attempted` datetime NOT NULL DEFAULT current_timestamp() COMMENT '日時',
  PRIMARY KEY (`id`),
  KEY `key_name` (`key_name`),
  KEY `attempted` (`attempted`)
) ENGINE=InnoDB AUTO_INCREMENT=53 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='ログイン試行制限用テーブル';

-- テーブル new_hossysdb.login_attempts: ~0 rows (約) のデータをダンプしています
DELETE FROM `login_attempts`;

--  テーブル new_hossysdb.users の構造をダンプしています
DROP TABLE IF EXISTS `users`;
CREATE TABLE IF NOT EXISTS `users` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_id` varchar(50) NOT NULL COMMENT 'ユーザーID',
  `user_name` varchar(50) NOT NULL COMMENT 'ユーザー名',
  `pwd_hash` varchar(255) NOT NULL COMMENT 'パスワード(ハッシュ化済)',
  `facility` varchar(50) DEFAULT NULL COMMENT '所属施設',
  `department` varchar(50) DEFAULT NULL COMMENT '所属部署',
  `role` enum('system_admin','admin','editor','viewer') DEFAULT 'viewer' COMMENT '権限レベル',
  `is_active` tinyint(1) NOT NULL DEFAULT 1 COMMENT '有効フラグ',
  `created_at` datetime NOT NULL DEFAULT current_timestamp() COMMENT 'アカウント作成日時',
  `updated_at` datetime DEFAULT NULL COMMENT '更新日時',
  `last_login_at` datetime DEFAULT NULL COMMENT '最終ログイン日時',
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_id` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='ユーザーテーブル';

-- テーブル new_hossysdb.users: ~3 rows (約) のデータをダンプしています
DELETE FROM `users`;
INSERT INTO `users` (`id`, `user_id`, `user_name`, `pwd_hash`, `facility`, `department`, `role`, `is_active`, `created_at`, `updated_at`, `last_login_at`) VALUES
	(1, 'doctor01', 'ドクター', '$2y$10$QPoxlrkl4rO0Cji13e4TqeSwVUFOv9L9MkYnlyHNDS1rVp.piutkC', NULL, NULL, 'system_admin', 1, '2025-08-16 21:22:18', NULL, '2025-08-23 14:14:04'),
	(2, 'nurse01', 'ナース', '$2y$10$QPoxlrkl4rO0Cji13e4TqeSwVUFOv9L9MkYnlyHNDS1rVp.piutkC', NULL, NULL, 'editor', 1, '2025-08-16 21:22:18', NULL, NULL),
	(3, 'admin01', '管理者', '$2y$10$QPoxlrkl4rO0Cji13e4TqeSwVUFOv9L9MkYnlyHNDS1rVp.piutkC', NULL, NULL, 'admin', 1, '2025-08-16 21:22:18', NULL, NULL);

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
