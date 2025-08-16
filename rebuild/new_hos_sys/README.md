# PHP Auth Adapter Pack

このパッケージは、セキュリティを考慮した最小構成のユーザ認証機能です。
ユーザIDとパスワードによるログイン、CSRF対策、レート制限機能を備えています。

## 構成内容

- `public/login.php` : ログイン画面（タブUI付き）
- `public/dashboard.php` : ログイン後のページ
- `public/logout.php` : ログアウト処理
- `lib/csrf.php` : CSRF対策トークン
- `lib/rate_limit.php` : ログイン試行制限
- `lib/auth_adapter.php` : 認証アダプタ（既存DBと接続する部分を編集してください）
- `sql/login_attempts.sql` : ログイン試行制限テーブル
- `sql/users.sql` : ユーザテーブルとサンプルアカウント
- `README.md` : このファイル

## セットアップ手順

1. `sql/users.sql` と `sql/login_attempts.sql` をMySQLに適用してください。
2. `lib/auth_adapter.php` の `check_credentials()` を編集し、既存DBに合わせて調整してください。
3. `public/login.php` にアクセスして動作確認してください。

## サンプルユーザ

以下のアカウントがあらかじめ登録されています。パスワードはすべて `password123` です。

- doctor01
- nurse01
- admin01

## 注意点

- 本番環境では必ず **HTTPS** を利用してください。
- セッションハイジャック対策として `SameSite=Strict` クッキーを推奨します。
- この仕組みは最小構成です。2FAやパスワードリセット等は必要に応じて追加してください。
