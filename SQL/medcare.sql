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


-- 診療内容カテゴリマスタ
CREATE TABLE IF NOT EXISTS `medcare_categories` (
  `med_item_cd` INT NOT NULL PRIMARY KEY,
  `med_item_name` VARCHAR(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='診療内容カテゴリ';

-- 正規化後の診療内容テーブル
CREATE TABLE IF NOT EXISTS `medcare` (
  `hos_cd` VARCHAR(10) NOT NULL,
  `med_item_cd` INT NOT NULL,
  `value` INT DEFAULT 0,
  `med_note` VARCHAR(1000) DEFAULT NULL,
  `delete_flg` INT NOT NULL DEFAULT 0,
  PRIMARY KEY (`hos_cd`, `med_item_cd`),
  FOREIGN KEY (`med_item_cd`) REFERENCES `medcare_categories`(`med_item_cd`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='診療内容';

-- エクスポートするデータが選択されていません

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
