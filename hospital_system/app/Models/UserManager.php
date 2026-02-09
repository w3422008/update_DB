<?php

// DB接続情報、必要なリポジトリを取得
require_once __DIR__ . '/../Repositories/CommonRepository.php';
require_once __DIR__ . '/../Repositories/UserRepository.php';

class UserManager
{
    public $id;
    public $name;
    public $email;
    private $repository;

    public function __construct()
    {
        $this->repository = new UserRepository();
    }

    public function getUserData()
    {
        return $this->repository->dbGetAllUserData();
    }
}
