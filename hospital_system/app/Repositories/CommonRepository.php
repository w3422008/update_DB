<?php
/**
 * CommonRepository.php
 * DB接続情報を一元管理するクラス
 * - DB接続情報は config.php から取得
 */
class CommonRepository
{
    /**
     * DB接続を取得
     * config.php からDB情報を取得し、PDOインスタンスを返す
     * @return PDO
     * @throws PDOException
     */
    public static function getDbConnection(): PDO
    {
        // database.php から DB接続情報を取得
        $config = require __DIR__ . '/../../config/database.php';
        $dbConfig = $config['db'];

        // 接続情報を変数に展開
        $host = $dbConfig['host'];
        $port = $dbConfig['port'];
        $db = $dbConfig['database'];
        $user = $dbConfig['user'];
        $pass = $dbConfig['password'];

        $dsn = "mysql:host={$host};port={$port};dbname={$db};charset=utf8mb4";

        try {
            $pdo = new PDO($dsn, $user, $pass, [
                PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                PDO::ATTR_EMULATE_PREPARES => false,
            ]);
            return $pdo;
        } catch (PDOException $e) {
            throw new PDOException('DB connection failed: ' . $e->getMessage());
        }
    }
}