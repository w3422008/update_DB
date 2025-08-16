-- 認証用ユーザテーブル
CREATE TABLE IF NOT EXISTS users (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  user_id VARCHAR(50) NOT NULL UNIQUE,   -- ログインID
  pwd_hash VARCHAR(255) NOT NULL,        -- パスワードハッシュ
  is_active TINYINT(1) NOT NULL DEFAULT 1, -- 有効/無効フラグ
  last_login_at DATETIME DEFAULT NULL,   -- 最終ログイン日時
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- サンプルアカウント (パスワードは "password123")
INSERT INTO users (user_id, pwd_hash, is_active) VALUES
('doctor01', '$2y$10$gB.Tki6PdIRklZP2g2tRKe6hxLk.8hQ3eUqk8Chpf68kdOqjDqIBW', 1),
('nurse01',  '$2y$10$gB.Tki6PdIRklZP2g2tRKe6hxLk.8hQ3eUqk8Chpf68kdOqjDqIBW', 1),
('admin01',  '$2y$10$gB.Tki6PdIRklZP2g2tRKe6hxLk.8hQ3eUqk8Chpf68kdOqjDqIBW', 1);
