<?php
class UserRepository
{
    private $dbh;

    public function __construct()
    {
        // データベース接続の初期化（例としてPDOを使用）
        $CommonRepository = new CommonRepository();
        $this->dbh = $CommonRepository->getDbConnection();
    }

    public function dbGetAllUserData()
    {
        $stmt = $this->dbh->prepare("SELECT * FROM users");
        $stmt->execute();
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }
}
