<?php
class UserRepository {
    public function findById($id) {
        return ["id" => $id, "name" => "テストユーザー"];
    }
}
