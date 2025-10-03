##### 1. 医療機関基本情報系

```mermaid
erDiagram
    hospitals {
        varchar hospital_id PK "医療機関コード"
        varchar hospital_type_id FK "病院区分ID"
        varchar hospital_name "医療機関名"
        enum status "運営状況"
        int bed_count "許可病床数"
        varchar consultation_hour "診療時間"
        boolean has_pt "理学療法士在籍フラグ"
        boolean has_ot "作業療法士在籍フラグ"
        boolean has_st "言語聴覚療法士在籍フラグ"
        text notes "備考"
        date closed_at "閉院日"
        datetime created_at "作成日時"
        datetime updated_at "更新日時"
    }
    
    hospital_types {
        varchar type_id PK "病院区分ID"
        varchar type_name "区分名"
        boolean is_active "有効フラグ"
        int display_order "表示順序"
    }
    
    addresses {
        int address_id PK "住所ID"
        varchar hospital_id FK "医療機関コード"
        int area_id FK "地区コード"
        varchar postal_code "郵便番号"
        varchar street_number "番地"
        varchar full_address "完全住所"
    }
    
    contact_details {
        int contact_id PK "連絡先ID"
        varchar hospital_id FK "医療機関コード"
        varchar contact_detail "連絡先詳細"
        varchar phone "電話番号"
        varchar fax "FAX番号"
        varchar email "メールアドレス"
        varchar website "ウェブサイト"
        text note "備考"
        boolean is_deleted "削除フラグ"
    }
    
    areas {
        int area_id PK "地区コード"
        varchar secondary_medical_area_name "二次医療圏名"
        varchar prefecture "都道府県"
        varchar city "市"
        varchar ward "区"
        varchar town "町"
        boolean is_active "有効フラグ"
        int display_order "表示順序"
    }
    
    hospital_code_history {
        bigint history_id PK "履歴ID"
        varchar hospital_id FK "現在の医療機関コード"
        varchar former_hospital_id "以前の医療機関コード"
        date change_date "コード更新日"
        datetime created_at "登録日時"
    }
    
    hospitals_ward_types {
        varchar hospital_id PK "医療機関コード"
        varchar ward_id PK "病棟種類ID"
    }
    
    ward_types {
        varchar ward_id PK "病棟種類ID"
        varchar ward_name "病棟名"
        boolean is_active "有効フラグ"
        int display_order "表示順序"
    }
    
    %% リレーションシップ
    hospital_types ||--o{ hospitals : "categorizes"
    hospitals ||--o{ addresses : "has"
    hospitals ||--o{ contact_details : "has"
    hospitals ||--o{ hospital_code_history : "has_history"
    hospitals ||--o{ hospitals_ward_types : "has_ward_types"
    ward_types ||--o{ hospitals_ward_types : "defines"
    areas ||--o{ addresses : "locates"
```

---

##### 2. 人員・組織情報系

```mermaid
erDiagram
    hospitals {
        varchar hospital_id PK "医療機関コード"
        varchar hospital_name "医療機関名"
    }
    
    hospital_staffs {
        int staff_id PK "スタッフ管理ID"
        varchar hospital_id FK "医療機関コード"
        enum role_type "役職種別"
        varchar staff_name "氏名"
        varchar specialty "専門分野"
        year graduation_year "卒業年度"
        varchar alma_mater "出身校"
        text notes "備考"
    }
    
    consultation_hours {
        varchar hospital_id PK "医療機関コード"
        enum day_of_week PK "曜日"
        enum period PK "時間帯"
        boolean is_available "診療可否"
    }
    
    %% リレーションシップ
    hospitals ||--o{ hospital_staffs : "employs"
    hospitals ||--o{ consultation_hours : "schedules"
```

---

##### 3. 診療科・診療内容系

```mermaid
erDiagram
    hospitals {
        varchar hospital_id PK "医療機関コード"
        varchar hospital_name "医療機関名"
    }
    
    medical_departments {
        varchar department_id PK "診療科コード"
        varchar department_name "診療科名"
        varchar category "診療科カテゴリ名"
        boolean is_active "有効フラグ"
        int display_order "表示順序"
    }
    
    hospital_departments {
        varchar hospital_id PK "医療機関コード"
        varchar department_id PK "診療科ID"
    }
    
    medical_services {
        varchar service_id PK "診療内容コード"
        varchar service_division PK "診療区分"
        varchar service_category "診療部門"
        varchar service_name "診療内容名"
        boolean is_active "有効フラグ"
        int display_order "表示順序"
    }
    
    hospital_services {
        varchar hospital_id PK "医療機関コード"
        varchar service_id PK "診療内容コード"
        varchar service_division PK "診療区分"
    }
    
    %% リレーションシップ
    hospitals ||--o{ hospital_departments : "offers"
    hospitals ||--o{ hospital_services : "provides"
    medical_departments ||--o{ hospital_departments : "relates"
    medical_services ||--o{ hospital_services : "provides"
```

---

##### 4. 連携・ネットワーク系

```mermaid
erDiagram
    hospitals {
        varchar hospital_id PK "医療機関コード"
        varchar hospital_name "医療機関名"
    }
    
    clinical_pathways {
        varchar clinical_pathway_id PK "連携パスID"
        varchar path_name "連携パス名"
        boolean is_active "有効フラグ"
        int display_order "表示順序"
    }
    
    clinical_pathway_hospitals {
        varchar hospital_id PK "医療機関コード"
        varchar clinical_pathway_id PK "連携パスID"
        varchar user_facility_id PK "登録者所属施設ID"
    }
    
    carna_connects {
        varchar hospital_id PK "医療機関コード"
        boolean is_deleted "削除フラグ"
    }
    
    %% リレーションシップ
    hospitals ||--o{ clinical_pathway_hospitals : "participates"
    hospitals ||--|| carna_connects : "connects"
    clinical_pathways ||--o{ clinical_pathway_hospitals : "defines"
```

---

##### 5. 紹介・診療支援系

```mermaid
erDiagram
    hospitals {
        varchar hospital_id PK "医療機関コード"
        varchar hospital_name "医療機関名"
    }
    
    introductions {
        varchar hospital_id PK "医療機関コード"
        varchar user_facility_id PK "登録者所属施設ID"
        year year PK "年度"
        date date PK "診療日"
        varchar department_name PK "診療科"
        enum intro_type PK "紹介・逆紹介判定"
        varchar department_id "診療科コード"
        int intro_count "紹介・逆紹介件数"
    }
    
    training {
        varchar hospital_id PK "医療機関コード"
        year year PK "年度"
        varchar user_facility_id PK "登録者所属施設ID"
        varchar department PK "診療科"
        date start_date PK "診療支援開始日"
        varchar staff_name "氏名"
        varchar position_id FK "職名"
        date end_date "診療支援終了日"
        varchar date "日付"
        varchar diagnostic_aid "診療支援区分"
    }
    
    positions {
        varchar position_id PK "職名ID"
        varchar position_name "職名"
        boolean is_active "有効フラグ"
        int display_order "表示順序"
    }
    
    %% リレーションシップ
    hospitals ||--o{ introductions : "receives"
    hospitals ||--o{ training : "trains"
    positions ||--o{ training : "defines_position"
```

---

##### 6. システム管理・ユーザー系

```mermaid
erDiagram
    users {
        varchar user_id PK "ユーザーID"
        varchar user_name "ユーザー名"
        varchar password_hash "パスワードハッシュ"
        varchar facility_id FK "所属施設ID"
        varchar department_id FK "所属部署ID"
        enum role "権限レベル"
        boolean is_active "アカウント有効フラグ"
        datetime last_login_at "最終ログイン日時"
        datetime created_at "作成日時"
        datetime updated_at "更新日時"
    }
    
    kawasaki_university_facilities {
        varchar facility_id PK "所属施設ID"
        varchar facility_name "施設名"
        varchar formal_name "正式名称"
        varchar abbreviation "略称"
        boolean is_active "有効フラグ"
        int display_order "表示順序"
    }
    
    kawasaki_university_departments {
        varchar department_id PK "部署ID"
        varchar department_name "部署名"
        boolean is_active "有効フラグ"
        int display_order "表示順序"
    }
    
    %% リレーションシップ
    kawasaki_university_facilities ||--o{ users : "belongs_to"
    kawasaki_university_departments ||--o{ users : "belongs_to"
```

<div style="page-break-inside: avoid;">

##### 7. ログ・監査系

```mermaid
erDiagram
    users {
        varchar user_id PK "ユーザーID"
        varchar user_name "ユーザー名"
    }
    
    unified_logs {
        bigint log_id PK "ログID"
        enum log_type "ログ種別"
        varchar user_id FK "ユーザーID"
        varchar session_id "セッションID"
        varchar table_name "対象テーブル名"
        enum action_type "操作種別"
        json old_values "変更前データ"
        json new_values "変更後データ"
        enum access_type "アクセス種別"
        varchar page_url "アクセスページURL"
        enum event_type "セキュリティイベント種別"
        enum severity "重要度"
        varchar ip_address "IPアドレス"
        datetime created_at "ログ記録日時"
        text other_fields "その他のフィールド"
    }
    
    %% リレーションシップ
    users ||--o{ unified_logs : "performs"
```

</div>

---

##### 8. 問い合わせ・サポート系

```mermaid
erDiagram
    users {
        varchar user_id PK "ユーザーID"
        varchar user_name "ユーザー名"
    }
    
    inquires {
        bigint inquire_id PK "問い合わせID"
        varchar user_id FK "問い合わせ者ユーザーID"
        enum priority "優先度"
        enum status "対応状況"
        text description "問い合わせ内容"
        varchar assigned_to FK "担当者ユーザーID"
        text resolution "解決方法・回答内容"
        datetime created_at "問い合わせ日時"
        datetime updated_at "最終更新日時"
        datetime resolved_at "解決日時"
    }
    
    %% リレーションシップ
    users ||--o{ inquires : "submits"
    users ||--o{ inquires : "assigned"
```

---

##### 9. システム運営管理系

```mermaid
erDiagram
    users {
        varchar user_id PK "ユーザーID"
        varchar user_name "ユーザー名"
    }
    
    maintenances {
        bigint maintenance_id PK "メンテナンスID"
        varchar title "タイトル"
        text comment "実施内容"
        date date "予定作業日"
        time start_time "予定開始時刻"
        time end_time "予定終了時刻"
        boolean view "表示フラグ"
        varchar created_by FK "作成者ユーザーID"
        datetime created_at "作成日時"
        datetime updated_at "更新日時"
    }
    
    system_status {
        int status_id PK "状態ID"
        enum system_mode "システムモード"
        varchar status_message "現在の状態メッセージ"
        bigint maintenance_id FK "関連メンテナンスID"
        varchar changed_by FK "状態変更者ユーザーID"
        datetime created_at "作成日時"
        datetime updated_at "更新日時"
    }
    
    system_versions {
        int version_id PK "バージョン管理ID"
        varchar version_number "バージョン番号"
        date release_date "リリース日"
        boolean is_current "現在稼働バージョンフラグ"
        text release_notes "リリースノート・変更内容"
        datetime created_at "作成日時"
    }
    
    maintenance_start {
        bigint id PK "実行通知ID"
        bigint maintenance_id FK "メンテナンスID"
        varchar title "通知タイトル"
        text description "通知詳細"
        text implementation_details "実施内容"
        boolean view "表示フラグ"
        varchar created_by FK "作成者ユーザーID"
        datetime created_at "作成日時"
        datetime updated_at "更新日時"
    }
    
    messages {
        bigint message_id PK "メッセージID"
        enum status "対応状況"
        text comment "内容"
        boolean view "表示フラグ"
        int version_id FK "実装バージョンID"
        varchar assigned_to FK "担当者ユーザーID"
        date res_date "対応日"
        datetime created_at "作成日時"
        datetime updated_at "更新日時"
    }
    

    %% リレーションシップ
    users ||--o{ maintenances : "creates"
    users ||--o{ system_status : "changes"
    users ||--o{ maintenance_start : "creates"
    users ||--o{ messages : "assigns"
    system_versions ||--o{ messages : "implements"
    maintenances ||--o{ system_status : "relates"
    maintenances ||--o{ maintenance_start : "generates"
```

---

##### 10. その他管理系

```mermaid
erDiagram
    hospitals {
        varchar hospital_id PK "医療機関コード"
        varchar hospital_name "医療機関名"
    }
    
    relatives {
        int relative_id PK "親族ID"
        varchar hospital_id FK "医療機関コード"
        varchar relative_name "人物名"
        varchar connection "関係"
        varchar school_name "学校名"
        year entrance_year "入学年"
        year graduation_year "卒業年"
        text notes "備考"
        boolean is_deleted "削除フラグ"
        datetime created_at "作成日時"
        datetime updated_at "更新日時"
    }
    
    social_meetings {
        varchar hospital_id PK "医療機関コード"
        varchar user_facility_id PK "登録者所属施設ID"
        year meeting_year PK "参加年度"
        boolean is_deleted "削除フラグ"
        datetime created_at "作成日時"
        datetime updated_at "更新日時"
    }
    
    contacts {
        varchar hospital_id PK "医療機関コード"
        year year PK "年度"
        varchar user_facility_id PK "登録者所属施設ID"
        date date PK "日付"
        varchar method PK "方法"
        varchar external_contact_name "連携機関対応者氏名"
        varchar external_department "連携機関対応者部署"
        varchar external_position "連携機関対応者役職"
        varchar external_additional_participants "連携機関対応人数・氏名"
        varchar internal_contact_name "当院対応者氏名"
        varchar internal_department "当院対応者所属"
        varchar internal_additional_participants "当院対応人数・氏名"
        varchar detail "内容"
        varchar notes "備考"
        varchar data_department "データ作成部署"
    }
    
    %% リレーションシップ
    hospitals ||--o{ relatives : "relates_to"
    hospitals ||--o{ social_meetings : "attends"
    hospitals ||--o{ contacts : "contacts"
```