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

-- テーブル new_hossysdb.users: ~3 rows (約) のデータをダンプしています
INSERT INTO `users` (`user_id`, `user_name`, `pwd_hash`, `facility_id`, `department_id`, `role`, `is_active`, `created_at`, `updated_at`, `last_login_at`) VALUES
	('doctor01', 'ドクター', '$2y$10$QPoxlrkl4rO0Cji13e4TqeSwVUFOv9L9MkYnlyHNDS1rVp.piutkC', NULL, NULL, 'system_admin', 1, '2025-08-16 21:22:18', NULL, '2025-08-26 10:49:53'),
	('nurse01', 'ナース', '$2y$10$QPoxlrkl4rO0Cji13e4TqeSwVUFOv9L9MkYnlyHNDS1rVp.piutkC', NULL, NULL, 'editor', 1, '2025-08-16 21:22:18', NULL, NULL),
	('admin01', '管理者', '$2y$10$QPoxlrkl4rO0Cji13e4TqeSwVUFOv9L9MkYnlyHNDS1rVp.piutkC', NULL, NULL, 'admin', 1, '2025-08-16 21:22:18', NULL, NULL);

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
