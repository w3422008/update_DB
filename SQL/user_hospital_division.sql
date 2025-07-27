-- --------------------------------------------------------
-- ホスト:                          127.0.0.1
-- サーバーのバージョン:                   10.4.24-MariaDB - mariadb.org binary distribution
-- サーバー OS:                      Win64
-- HeidiSQL バージョン:               12.10.0.7000
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- hosplistdb のデータベース構造をダンプしています
CREATE DATABASE IF NOT EXISTS `hosplistdb` /*!40100 DEFAULT CHARACTER SET utf8mb4 */;
USE `hosplistdb`;


-- 病院マスタテーブル
CREATE TABLE IF NOT EXISTS `hospital` (
  `hospital_id` varchar(10) NOT NULL,
  `hospital_name` varchar(100) NOT NULL,
  `abbreviation` varchar(50),
  PRIMARY KEY (`hospital_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='病院マスタ';

-- 部署マスタテーブル
CREATE TABLE IF NOT EXISTS `division` (
  `division_id` varchar(30) NOT NULL,
  `division_name` varchar(100) NOT NULL,
  PRIMARY KEY (`division_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='部署マスタ';

-- ユーザーテーブル
CREATE TABLE IF NOT EXISTS `user` (
  `user_id` varchar(10) NOT NULL,
  `user_name` varchar(50) NOT NULL,
  `ins_id` varchar(10) NOT NULL,
  `bel_id` varchar(30) NOT NULL,
  `pw` varchar(255) NOT NULL,
  `adm_user` int(11) DEFAULT NULL,
  `edi_user` int(11) DEFAULT NULL,
  `start` varchar(30) DEFAULT NULL,
  `end` varchar(30) DEFAULT NULL,
  `onf` int(11) NOT NULL,
  `up_date` varchar(1000) NOT NULL,
  PRIMARY KEY (`user_id`),
  FOREIGN KEY (`ins_id`) REFERENCES `hospital`(`hospital_id`),
  FOREIGN KEY (`bel_id`) REFERENCES `division`(`division_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='ユーザー情報';

-- エクスポートするデータが選択されていません

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
