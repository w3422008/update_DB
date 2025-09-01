# ToDoリスト
- [ToDoリスト](#todoリスト)
  - [確認事項](#確認事項)
    - [mainテーブル](#mainテーブル)
- [メモ](#メモ)
  - [既存テーブルの修正](#既存テーブルの修正)
      - [`hospital_types` テーブル](#hospital_types-テーブル)
      - [`hospital_staff` テーブル](#hospital_staff-テーブル)
      - [`hospital_staff` テーブル](#hospital_staff-テーブル-1)
      - [`medical_services` テーブル](#medical_services-テーブル)
      - [`hospital_departments` テーブル](#hospital_departments-テーブル)
      - [`audit_logs` テーブル](#audit_logs-テーブル)
      - [`areas` テーブル](#areas-テーブル)
      - [`addresses` テーブル](#addresses-テーブル)
      - [`medical_departments` テーブル](#medical_departments-テーブル)
      - [`madical_categories` テーブル](#madical_categories-テーブル)
      - [`inquiries`テーブル](#inquiriesテーブル)
      - [`documents`テーブル](#documentsテーブル)
  - [付け加えたいテーブル](#付け加えたいテーブル)
      - [`maintenance`テーブル](#maintenanceテーブル)
      - [`message_template`テーブル(なくてよし)](#message_templateテーブルなくてよし)
      - [`message`テーブル](#messageテーブル)

## 確認事項
### mainテーブル
- [ ] `hos_div`に存在する内容をSQLで抽出
    →``` SELECT DISTINCT `hos_div` FROM `main`; ```を実行
    ↳重複を削除した保存されているデータが出力される

- [ ] `med_ass`(医師会)に対応する病院長、理事長情報がすべてあるのか
→ 新テーブルでは、病院長、理事長情報へ医師会情報を紐づけるため
↳ 確認のため、```SELECT `med_ass`, `chi_name`, `pre_name` FROM `main` WHERE TRIM(`med_ass`) <> '' AND `med_ass` IS NOT NULL;```を実行する
☆☆☆ そもそも医師会名は存在するのか

- [ ] あ

# メモ

## 既存テーブルの修正

#### `hospital_types` テーブル
 `description` `type_id` → 不要？
PK：`type_code`で代用

#### `hospital_staff` テーブル
`staff_id` → カラム名変更
各医療機関の人物のIDはわからないかつAIのため

#### `hospital_staff` テーブル
`role_type` → 理事長、病院長のみ？の役職を登録

#### `medical_services` テーブル
`service_id` 削除

#### `hospital_departments` テーブル
`is_primary`、`notes`、`created_at`　削除

#### `audit_logs` テーブル
`user_name`、`user_facility`、`user_department`　削除

#### `areas` テーブル
`area_id`、`search_area_name`、`display_area_name`　削除

#### `addresses` テーブル
`area_name`、`city`、`ward`、`town`　削除

#### `medical_departments` テーブル
`display_order`、`medical_department`　削除
`category_id` → `category`　診療科カテゴリ(名)へ変更

#### `madical_categories` テーブル
`display_order`　削除
最悪テーブル削除

#### `inquiries`テーブル
コンタクト履歴(インポート)のため、削除

#### `documents`テーブル
`message`、`maintenance`、`q_a`を統合しているため、不都合あり



## 付け加えたいテーブル
#### `maintenance`テーブル
メンテナンステーブル

#### `message_template`テーブル(なくてよし)
メッセージのテンプレートマスタ

#### `message`テーブル
メンテナンスお知らせ、問い合わせ(Q&A)情報を管理
