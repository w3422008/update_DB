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

--  テーブル hosplistdb.c_path の構造をダンプしています

-- パスマスタテーブル
CREATE TABLE IF NOT EXISTS `path_master` (
  `path_type` INT NOT NULL PRIMARY KEY,
  `path_name` VARCHAR(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='パス種別マスタ';
  
-- 正規化後の連携パステーブル
CREATE TABLE IF NOT EXISTS `c_path` (
  `hos_cd` VARCHAR(10) NOT NULL,
  `ins` INT NOT NULL DEFAULT 0 COMMENT '0(附)or1(総)',
  `path_type` INT NOT NULL COMMENT 'パス種別',
  `value` INT DEFAULT 0 COMMENT 'パスの値',
  `delete_flg` INT NOT NULL DEFAULT 0 COMMENT '削除フラグ',
  PRIMARY KEY (`hos_cd`, `ins`, `path_type`),
  FOREIGN KEY (`path_type`) REFERENCES `path_master`(`path_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='連携パス（地域連携クリティカルパス）';

-- エクスポートするデータが選択されていません

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
