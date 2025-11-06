<?php
class CommonRepository {
    public function getdbConnection() {
        // データベース接続の共通ロジックをここに記述
        $db = require __DIR__ . '/../config/config.php';
        $dsn = "mysql:host={$db['host']};port={$db['port']};dbname={$db['database']};charset=utf8mb4";
        $dbh = new PDO($dsn, $db['username'], $db['password']);
        $dbh->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        
        return $dbh;
    }
}