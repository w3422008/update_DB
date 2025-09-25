# 旧DB→新DBカラム移行チェックシート

**作成日**: 2025年9月25日  
**目的**: 移行元DB（hosplistdb）の各カラムが新テーブル（newhptldb）で使用されているかを確認

---

## area テーブル（地域マスタ）

| カラム名 | データ型 | 説明 | 移行済み | 備考 |
|---------|---------|------|---------|------|
| are_cd | int(11) | 地域コード | <input type="checkbox"> |  |
| area_name | varchar(20) | エリア名 | <input type="checkbox" checked> |  |
| sec_cd | int(11) | セクションコード | <input type="checkbox" checked> |  |
| area1 | varchar(50) | エリア1 | <input type="checkbox"> |  |
| area2 | varchar(50) | エリア2 | <input type="checkbox"> |  |
| city | varchar(30) | 市 | <input type="checkbox" checked> |  |
| zone | varchar(20) | 区 | <input type="checkbox" checked> |  |
| town | varchar(30) | 町 | <input type="checkbox" checked> |  |

---

## carna_connect テーブル（カルナコネクト）

| カラム名 | データ型 | 説明 | 移行済み | 備考 |
|---------|---------|------|---------|------|
| hos_cd | varchar(10) | 医療機関コード | <input type="checkbox" checked> |  |
| delete_flg | int(11) | 削除フラグ | <input type="checkbox" checked> |  |

---

## contact テーブル（コンタクト履歴）

| カラム名 | データ型 | 説明 | 移行済み | 備考 |
|---------|---------|------|---------|------|
| con_cd | int(11) | コンタクトコード（主キー） | <input type="checkbox"> |  |
| hos_cd | varchar(10) | 医療機関コード | <input type="checkbox"> |  |
| hos_name | varchar(100) | 医療機関名 | <input type="checkbox"> |  |
| year | year(4) | 年度 | <input type="checkbox"> |  |
| ins | int(11) | 施設区分 | <input type="checkbox"> |  |
| date | date | 日付 | <input type="checkbox"> |  |
| method | varchar(50) | 方法 | <input type="checkbox"> |  |
| ex_dept | varchar(50) | 連携機関対応者部署 | <input type="checkbox"> |  |
| ex_position | varchar(50) | 連携機関対応者役職 | <input type="checkbox"> |  |
| ex_name | varchar(10) | 連携機関対応者氏名 | <input type="checkbox"> |  |
| ex_subnames | varchar(100) | 連携機関対応人数・氏名 | <input type="checkbox"> |  |
| in_dept | varchar(50) | 当院対応者所属 | <input type="checkbox"> |  |
| in_name | varchar(10) | 当院対応者氏名 | <input type="checkbox"> |  |
| in_subnames | varchar(100) | 当院対応人数・氏名 | <input type="checkbox"> |  |
| detail | varchar(100) | 内容 | <input type="checkbox"> |  |
| con_note | varchar(100) | 備考 | <input type="checkbox"> |  |
| data_dept | varchar(50) | データ作成部署 | <input type="checkbox"> |  |

---

## contact_backup テーブル（コンタクト履歴バックアップ）

| カラム名 | データ型 | 説明 | 移行済み | 備考 |
|---------|---------|------|---------|------|
| con_cd | int(11) | コンタクトコード（主キー） | <input type="checkbox"> |  |
| hos_cd | varchar(10) | 医療機関コード | <input type="checkbox"> |  |
| hos_name | varchar(100) | 医療機関名 | <input type="checkbox"> |  |
| year | year(4) | 年度 | <input type="checkbox"> |  |
| ins | int(11) | 施設区分 | <input type="checkbox"> |  |
| date | date | 日付 | <input type="checkbox"> |  |
| method | varchar(50) | 方法 | <input type="checkbox"> |  |
| ex_dept | varchar(50) | 連携機関対応者部署 | <input type="checkbox"> |  |
| ex_position | varchar(50) | 連携機関対応者役職 | <input type="checkbox"> |  |
| ex_name | varchar(10) | 連携機関対応者氏名 | <input type="checkbox"> |  |
| ex_subnames | varchar(100) | 連携機関対応人数・氏名 | <input type="checkbox"> |  |
| in_dept | varchar(50) | 当院対応者所属 | <input type="checkbox"> |  |
| in_name | varchar(10) | 当院対応者氏名 | <input type="checkbox"> |  |
| in_subnames | varchar(100) | 当院対応人数・氏名 | <input type="checkbox"> |  |
| detail | varchar(100) | 内容 | <input type="checkbox"> |  |
| con_note | varchar(100) | 備考 | <input type="checkbox"> |  |
| data_dept | varchar(50) | データ作成部署 | <input type="checkbox"> |  |

---

## c_path テーブル（連携パス）

| カラム名 | データ型 | 説明 | 移行済み | 備考 |
|---------|---------|------|---------|------|
| hos_cd | varchar(10) | 医療機関コード | <input type="checkbox" checked> |  |
| ins | int(11) | 施設区分（0:附属 1:総合） | <input type="checkbox"> |  |
| cp0 | int(11) | 入退院支援連携先病院 | <input type="checkbox" checked> |  |
| cp1 | int(11) | 脳卒中パス | <input type="checkbox" checked> |  |
| cp2 | int(11) | 大腿骨パス | <input type="checkbox" checked> |  |
| cp3 | int(11) | 心筋梗塞・心不全パス | <input type="checkbox" checked> |  |
| cp4 | int(11) | 胃がんパス | <input type="checkbox" checked> |  |
| cp5 | int(11) | 大腸がんパス | <input type="checkbox" checked> |  |
| cp6 | int(11) | 乳がんパス | <input type="checkbox" checked> |  |
| cp7 | int(11) | 肺がんパス | <input type="checkbox" checked> |  |
| cp8 | int(11) | 肝がんパス | <input type="checkbox" checked> |  |
| delete_flg | int(11) | 削除フラグ | <input type="checkbox" checked> |  |

---

## delete_log テーブル（削除ログ）

| カラム名 | データ型 | 説明 | 移行済み | 備考 |
|---------|---------|------|---------|------|
| hos_cd | varchar(10) | 医療機関コード | <input type="checkbox"> |  |
| hos_name | varchar(100) | 医療機関名 | <input type="checkbox"> |  |
| log_data | varchar(100) | ログデータ | <input type="checkbox"> |  |
| user_name | varchar(50) | ユーザー名 | <input type="checkbox"> |  |
| user_id | varchar(10) | ユーザーID | <input type="checkbox"> |  |
| ins | varchar(10) | 施設 | <input type="checkbox"> |  |
| bel | varchar(30) | 所属 | <input type="checkbox"> |  |
| adm_user | varchar(2) | 管理者ユーザー | <input type="checkbox"> |  |

---

## department テーブル（診療科マスタ）

| カラム名 | データ型 | 説明 | 移行済み | 備考 |
|---------|---------|------|---------|------|
| sec_cd | int(11) | セクションコード | <input type="checkbox"> |  |
| sec_name | varchar(10) | セクション名 | <input type="checkbox" checked> |  |
| dep_cd | varchar(30) | 診療科コード | <input type="checkbox" checked> |  |
| dep_name | varchar(30) | 診療科名 | <input type="checkbox" checked> |  |

---

## field_junction テーブル（部門連絡先）

| カラム名 | データ型 | 説明 | 移行済み | 備考 |
|---------|---------|------|---------|------|
| hos_cd | varchar(10) | 医療機関コード | <input type="checkbox" checked> |  |
| hos_name | varchar(100) | 医療機関名 | <input type="checkbox"> |  |
| fie_div | varchar(15) | 部門区分 | <input type="checkbox"> |  |
| fie_name | varchar(30) | 部門名 | <input type="checkbox" checked> |  |
| tel | varchar(20) | 電話番号 | <input type="checkbox" checked> |  |
| fax | varchar(20) | FAX番号 | <input type="checkbox" checked> |  |
| note | varchar(200) | 備考 | <input type="checkbox" checked> |  |
| delete_flg | int(11) | 削除フラグ | <input type="checkbox" checked> |  |
| fie_cd | int(11) | 部門コード（主キー） | <input type="checkbox"> |  |

---

## insert_log テーブル（新規追加ログ）

| カラム名 | データ型 | 説明 | 移行済み | 備考 |
|---------|---------|------|---------|------|
| hos_cd | varchar(10) | 医療機関コード | <input type="checkbox"> |  |
| hos_name | varchar(100) | 医療機関名 | <input type="checkbox"> |  |
| log_data | varchar(100) | ログデータ | <input type="checkbox"> |  |
| user_name | varchar(50) | ユーザー名 | <input type="checkbox"> |  |
| user_id | varchar(10) | ユーザーID | <input type="checkbox"> |  |
| ins | varchar(10) | 施設 | <input type="checkbox"> |  |
| bel | varchar(30) | 所属 | <input type="checkbox"> |  |
| adm_user | varchar(2) | 管理者ユーザー | <input type="checkbox"> |  |

---

## intro テーブル（紹介）

| カラム名 | データ型 | 説明 | 移行済み | 備考 |
|---------|---------|------|---------|------|
| hos_cd | varchar(10) | 医療機関コード | <input type="checkbox"> |  |
| ins | int(11) | 施設区分（0:附属 1:総合） | <input type="checkbox"> |  |
| year | year(4) | 年度 | <input type="checkbox"> |  |
| date | date | 診療年月日 | <input type="checkbox"> |  |
| fie_cd | int(11) | 診療科コード | <input type="checkbox"> |  |
| fie_name | varchar(30) | 診療科 | <input type="checkbox"> |  |
| intr | int(11) | 紹介件数 | <input type="checkbox"> |  |

---

## intro_backup テーブル（紹介バックアップ）

| カラム名 | データ型 | 説明 | 移行済み | 備考 |
|---------|---------|------|---------|------|
| hos_cd | varchar(10) | 医療機関コード | <input type="checkbox"> |  |
| ins | int(11) | 施設区分（0:附属 1:総合） | <input type="checkbox"> |  |
| year | year(4) | 年度 | <input type="checkbox"> |  |
| date | date | 診療年月日 | <input type="checkbox"> |  |
| fie_cd | int(11) | 診療科コード | <input type="checkbox"> |  |
| fie_name | varchar(30) | 診療科 | <input type="checkbox"> |  |
| intr | int(11) | 紹介件数 | <input type="checkbox"> |  |

---

## intro_copy テーブル（紹介コピー）

| カラム名 | データ型 | 説明 | 移行済み | 備考 |
|---------|---------|------|---------|------|
| hos_cd | varchar(10) | 医療機関コード | <input type="checkbox"> |  |
| ins | int(11) | 施設区分（0:附属 1:総合） | <input type="checkbox"> |  |
| year | year(4) | 年度 | <input type="checkbox"> |  |
| date | date | 診療年月日 | <input type="checkbox"> |  |
| fie_cd | int(11) | 診療科コード | <input type="checkbox"> |  |
| fie_name | varchar(30) | 診療科 | <input type="checkbox"> |  |
| intr | int(11) | 紹介件数 | <input type="checkbox"> |  |

---

## invers_intro テーブル（逆紹介）

| カラム名 | データ型 | 説明 | 移行済み | 備考 |
|---------|---------|------|---------|------|
| hos_cd | varchar(10) | 医療機関コード | <input type="checkbox"> |  |
| ins | int(11) | 施設区分（0:附属 1:総合） | <input type="checkbox"> |  |
| year | year(4) | 年度 | <input type="checkbox"> |  |
| date | date | 診療年月日 | <input type="checkbox"> |  |
| fie_cd | int(11) | 科コード | <input type="checkbox"> |  |
| fie_name | varchar(30) | 診療科 | <input type="checkbox"> |  |
| invr_intr | int(11) | 逆紹介件数 | <input type="checkbox"> |  |

---

## invers_intro_backup テーブル（逆紹介バックアップ）

| カラム名 | データ型 | 説明 | 移行済み | 備考 |
|---------|---------|------|---------|------|
| hos_cd | varchar(10) | 医療機関コード | <input type="checkbox"> |  |
| ins | int(11) | 施設区分（0:附属 1:総合） | <input type="checkbox"> |  |
| year | year(4) | 年度 | <input type="checkbox"> |  |
| date | date | 診療年月日 | <input type="checkbox"> |  |
| fie_cd | int(11) | 診療科コード | <input type="checkbox"> |  |
| fie_name | varchar(30) | 診療科 | <input type="checkbox"> |  |
| invr_intr | int(11) | 逆紹介件数 | <input type="checkbox"> |  |

---

## invers_intro_copy テーブル（逆紹介コピー）

| カラム名 | データ型 | 説明 | 移行済み | 備考 |
|---------|---------|------|---------|------|
| hos_cd | varchar(10) | 医療機関コード | <input type="checkbox"> |  |
| ins | int(11) | 施設区分（0:附属 1:総合） | <input type="checkbox"> |  |
| year | year(4) | 年度 | <input type="checkbox"> |  |
| date | date | 診療年月日 | <input type="checkbox"> |  |
| fie_cd | int(11) | 診療科コード | <input type="checkbox"> |  |
| fie_name | varchar(30) | 診療科 | <input type="checkbox"> |  |
| invr_intr | int(11) | 逆紹介件数 | <input type="checkbox"> |  |

---

## main テーブル（医療機関基本情報）

| カラム名 | データ型 | 説明 | 移行済み | 備考 |
|---------|---------|------|---------|------|
| op_flg | int(11) | オプションフラグ | <input type="checkbox" checked> |  |
| med_ass | varchar(10) | 医師会 | <input type="checkbox"> |  |
| hos_div | varchar(5) | 病院区分 | <input type="checkbox" checked> |  |
| hos_cd | varchar(10) | 医療機関コード | <input type="checkbox" checked> |  |
| hos_name | varchar(100) | 医療機関名 | <input type="checkbox" checked> |  |
| zipcode | varchar(7) | 郵便番号 | <input type="checkbox" checked> |  |
| ad | varchar(400) | 住所 | <input type="checkbox" checked> |  |
| tel | varchar(20) | 電話番号 | <input type="checkbox" checked> |  |
| fax | varchar(20) | FAX番号 | <input type="checkbox" checked> |  |
| email | varchar(254) | メールアドレス | <input type="checkbox" checked> |  |
| are_cd | int(11) | 地域コード | <input type="checkbox" checked> |  |
| pre | varchar(10) | 都道府県 | <input type="checkbox" checked> |  |
| area | varchar(40) | エリア | <input type="checkbox" checked> |  |
| city | varchar(40) | 市 | <input type="checkbox" checked> |  |
| zone | varchar(40) | 区 | <input type="checkbox" checked> |  |
| town | varchar(40) | 町 | <input type="checkbox" checked> |  |
| str_num | varchar(200) | 番地 | <input type="checkbox" checked> |  |
| note | varchar(1000) | 備考 | <input type="checkbox" checked> |  |
| clo_day | varchar(20) | 休診日 | <input type="checkbox" checked> |  |
| chi_name | varchar(60) | 理事長氏名 | <input type="checkbox" checked> |  |
| chi_spe | varchar(20) | 理事長専門 | <input type="checkbox" checked> |  |
| chi_year | varchar(7) | 理事長卒業年 | <input type="checkbox" checked> |  |
| chi_sch | varchar(50) | 理事長学校 | <input type="checkbox" checked> |  |
| chi_note | varchar(100) | 理事長備考 | <input type="checkbox" checked> |  |
| pre_name | varchar(60) | 院長氏名 | <input type="checkbox" checked> |  |
| pre_spe | varchar(20) | 院長専門 | <input type="checkbox" checked> |  |
| pre_year | varchar(7) | 院長卒業年 | <input type="checkbox" checked> |  |
| pre_sch | varchar(50) | 院長学校 | <input type="checkbox" checked> |  |
| pre_note | varchar(100) | 院長備考 | <input type="checkbox" checked> |  |
| con_hour | varchar(200) | 診療時間 | <input type="checkbox" checked> |  |
| mon_am | varchar(5) | 月曜午前 | <input type="checkbox" checked> |  |
| mon_pm | varchar(5) | 月曜午後 | <input type="checkbox" checked> |  |
| tue_am | varchar(5) | 火曜午前 | <input type="checkbox" checked> |  |
| tue_pm | varchar(5) | 火曜午後 | <input type="checkbox" checked> |  |
| wed_am | varchar(5) | 水曜午前 | <input type="checkbox" checked> |  |
| wed_pm | varchar(5) | 水曜午後 | <input type="checkbox" checked> |  |
| thr_am | varchar(5) | 木曜午前 | <input type="checkbox" checked> |  |
| thr_pm | varchar(5) | 木曜午後 | <input type="checkbox" checked> |  |
| fri_am | varchar(5) | 金曜午前 | <input type="checkbox" checked> |  |
| fri_pm | varchar(5) | 金曜午後 | <input type="checkbox" checked> |  |
| sat_am | varchar(5) | 土曜午前 | <input type="checkbox" checked> |  |
| sat_pm | varchar(5) | 土曜午後 | <input type="checkbox" checked> |  |
| sun_am | varchar(5) | 日曜午前 | <input type="checkbox" checked> |  |
| sun_pm | varchar(5) | 日曜午後 | <input type="checkbox" checked> |  |
| holiday | varchar(5) | 祝日 | <input type="checkbox" checked> |  |
| int_med | varchar(3) | 内科 | <input type="checkbox" checked> |  |
| ped_med | varchar(3) | 小児科 | <input type="checkbox" checked> |  |
| sur_med | varchar(3) | 外科 | <input type="checkbox" checked> |  |
| ort_med | varchar(3) | 整形外科 | <input type="checkbox" checked> |  |
| oph_med | varchar(3) | 眼科 | <input type="checkbox" checked> |  |
| ent_med | varchar(3) | 耳鼻咽喉科 | <input type="checkbox" checked> |  |
| so_med | varchar(3) | 皮膚科 | <input type="checkbox" checked> |  |
| gyn_med | varchar(3) | 産婦人科 | <input type="checkbox" checked> |  |
| psy_med | varchar(3) | 精神科 | <input type="checkbox" checked> |  |
| den_med | varchar(3) | 歯科 | <input type="checkbox" checked> |  |
| etc_med | varchar(3) | その他診療科 | <input type="checkbox" checked> |  |
| int_int | varchar(3) | 内科（内科） | <input type="checkbox" checked> |  |
| int_dig | varchar(3) | 消化器内科 | <input type="checkbox" checked> |  |
| int_uri | varchar(3) | 泌尿器内科 | <input type="checkbox" checked> |  |
| int_tum | varchar(3) | 腫瘍内科 | <input type="checkbox" checked> |  |
| int_res | varchar(3) | 呼吸器内科 | <input type="checkbox" checked> |  |
| int_kid | varchar(3) | 腎臓内科 | <input type="checkbox" checked> |  |
| int_blo | varchar(3) | 血液内科 | <input type="checkbox" checked> |  |
| int_apo | varchar(3) | 神経内科 | <input type="checkbox" checked> |  |
| int_cir | varchar(3) | 循環器内科 | <input type="checkbox" checked> |  |
| int_ner | varchar(3) | 神経内科 | <input type="checkbox" checked> |  |
| int_inf | varchar(3) | 感染症内科 | <input type="checkbox" checked> |  |
| ped_ped | varchar(3) | 小児科（小児科） | <input type="checkbox" checked> |  |
| ped_sur | varchar(3) | 小児外科 | <input type="checkbox" checked> |  |
| ped_neo | varchar(3) | 新生児科 | <input type="checkbox" checked> |  |
| sur_sur | varchar(3) | 外科（外科） | <input type="checkbox" checked> |  |
| sur_lac | varchar(3) | 乳腺外科 | <input type="checkbox" checked> |  |
| sur_ner | varchar(3) | 脳神経外科 | <input type="checkbox" checked> |  |
| sur_nes | varchar(3) | 脳神経外科 | <input type="checkbox" checked> |  |
| sur_dig | varchar(3) | 消化器外科 | <input type="checkbox" checked> |  |
| sur_car | varchar(3) | 心臓血管外科 | <input type="checkbox" checked> |  |
| sur_ven | varchar(3) | 血管外科 | <input type="checkbox" checked> |  |
| ort_rhe | varchar(3) | リウマチ科 | <input type="checkbox" checked> |  |
| ort_cos | varchar(3) | 美容外科 | <input type="checkbox" checked> |  |
| ort_ort | varchar(3) | 整形外科（整形外科） | <input type="checkbox" checked> |  |
| ort_reh | varchar(3) | リハビリテーション科 | <input type="checkbox" checked> |  |
| ort_pla | varchar(3) | 形成外科 | <input type="checkbox" checked> |  |
| oph_oph | varchar(3) | 眼科（眼科） | <input type="checkbox" checked> |  |
| ent_ent | varchar(3) | 耳鼻咽喉科（耳鼻咽喉科） | <input type="checkbox" checked> |  |
| ent_to | varchar(3) | 頭頸部外科 | <input type="checkbox" checked> |  |
| so_sky | varchar(3) | 皮膚科（皮膚科） | <input type="checkbox" checked> |  |
| so_org | varchar(3) | 美容皮膚科 | <input type="checkbox" checked> |  |
| gyn_gyn | varchar(3) | 産婦人科（産婦人科） | <input type="checkbox" checked> |  |
| gyn_obs | varchar(3) | 産科 | <input type="checkbox" checked> |  |
| gyn_gyne | varchar(3) | 婦人科 | <input type="checkbox" checked> |  |
| psy_psy | varchar(3) | 精神科（精神科） | <input type="checkbox" checked> |  |
| psy_psyc | varchar(3) | 心療内科 | <input type="checkbox" checked> |  |
| den_den | varchar(3) | 歯科（歯科） | <input type="checkbox" checked> |  |
| den_cav | varchar(3) | 口腔外科 | <input type="checkbox" checked> |  |
| den_ref | varchar(3) | 矯正歯科 | <input type="checkbox" checked> |  |
| den_ped | varchar(3) | 小児歯科 | <input type="checkbox" checked> |  |
| alle | varchar(3) | アレルギー科 | <input type="checkbox" checked> |  |
| pat | varchar(3) | 病理診断科 | <input type="checkbox" checked> |  |
| checkup | varchar(3) | 健診 | <input type="checkbox" checked> |  |
| rad | varchar(3) | 放射線科 | <input type="checkbox" checked> |  |
| cli | varchar(3) | 臨床検査科 | <input type="checkbox" checked> |  |
| ane | varchar(3) | 麻酔科 | <input type="checkbox" checked> |  |
| eme | varchar(3) | 救急科 | <input type="checkbox" checked> |  |
| bed | int(11) | 病床数 | <input type="checkbox" checked> |  |
| bed_reh | varchar(3) | リハビリ病床 | <input type="checkbox" checked> |  |
| bed_tre | varchar(3) | 療養病床 | <input type="checkbox" checked> |  |
| bed_main | varchar(3) | 一般病床 | <input type="checkbox" checked> |  |
| bed_care | varchar(3) | 介護病床 | <input type="checkbox" checked> |  |
| bed_tra | varchar(3) | 転換病床 | <input type="checkbox" checked> |  |
| pt | varchar(3) | 理学療法士 | <input type="checkbox" checked> |  |
| bed_att | varchar(3) | 精神病床 | <input type="checkbox" checked> |  |
| ot | varchar(3) | 作業療法士 | <input type="checkbox" checked> |  |
| st | varchar(3) | 言語聴覚士 | <input type="checkbox" checked> |  |
| onf | int(11) | オンフラグ | <input type="checkbox" checked> |  |
| dep_note | varchar(1000) | 診療科備考 | <input type="checkbox"> |  |
| drct_note | varchar(1000) | 院長備考 | <input type="checkbox"> |  |
| num_note | varchar(1000) | 病床数備考 | <input type="checkbox"> |  |
| intr_note | varchar(1000) | 紹介備考 | <input type="checkbox"> |  |
| tra_note | varchar(1000) | 研修備考 | <input type="checkbox"> |  |
| coop_note | varchar(1000) | 連携備考 | <input type="checkbox"> |  |
| con_note | varchar(1000) | 連絡先備考 | <input type="checkbox"> |  |
| log_data | varchar(100) | ログデータ | <input type="checkbox"> |  |
| log_name | varchar(50) | ログ名 | <input type="checkbox"> |  |

---

## maintenance テーブル（メンテナンス通知）

| カラム名 | データ型 | 説明 | 移行済み | 備考 |
|---------|---------|------|---------|------|
| id | int(11) | ID（主キー） | <input type="checkbox"> |  |
| title | text | タイトル | <input type="checkbox"> |  |
| upload_date | date | アップロード日 | <input type="checkbox"> |  |
| date | date | 作業日 | <input type="checkbox"> |  |
| start_time | time | 予定作業開始時刻 | <input type="checkbox"> |  |
| end_time | time | 予定作業終了時刻 | <input type="checkbox"> |  |
| comment | text | 実施内容 | <input type="checkbox"> |  |
| view | int(11) | 表示/非表示 | <input type="checkbox"> |  |

---

## maintenance_start テーブル（メンテナンス中通知）

| カラム名 | データ型 | 説明 | 移行済み | 備考 |
|---------|---------|------|---------|------|
| id | int(255) | ID（主キー） | <input type="checkbox"> |  |
| title | text | 通知タイトル | <input type="checkbox"> |  |
| comment | text | 通知タイトル2 | <input type="checkbox"> |  |
| date | date | 作業日 | <input type="checkbox"> |  |
| start_time | time | 作業開始時刻 | <input type="checkbox"> |  |
| end_time | time | 作業終了時刻 | <input type="checkbox"> |  |
| comment2 | text | 実施内容 | <input type="checkbox"> |  |
| view | int(11) | 表示/非表示 | <input type="checkbox"> |  |

---

## main_copy テーブル（メイン情報コピー）

*mainテーブルと同じ構造のため省略*

---

## medcare テーブル（診療内容）

| カラム名 | データ型 | 説明 | 移行済み | 備考 |
|---------|---------|------|---------|------|
| hos_cd | varchar(10) | 医療機関コード | <input type="checkbox" checked> |  |
| med_1 | int(11) | 診療内容1 | <input type="checkbox" checked> |  |
| med_2 | int(11) | 診療内容2 | <input type="checkbox" checked> |  |
| med_3 | int(11) | 診療内容3 | <input type="checkbox" checked> |  |
| med_4 | int(11) | 診療内容4 | <input type="checkbox" checked> |  |
| med_5 | int(11) | 診療内容5 | <input type="checkbox" checked> |  |
| ... | ... | *med_164まで連続* | <input type="checkbox" checked> | *med_6～med_164は省略* |
| med_note | varchar(1000) | 診療内容備考 | <input type="checkbox" checked> |  |
| delete_flg | int(11) | 削除フラグ | <input type="checkbox" checked> |  |

---

## medcare_mst テーブル（診療内容マスタ）

| カラム名 | データ型 | 説明 | 移行済み | 備考 |
|---------|---------|------|---------|------|
| med_code | int(11) | 診療内容コード | <input type="checkbox"> |  |
| med_div | varchar(50) | 診療区分 | <input type="checkbox" checked> |  |
| med_dep | varchar(100) | 診療部門 | <input type="checkbox" checked> |  |
| med_det | varchar(300) | 診療詳細 | <input type="checkbox" checked> |  |

---

## med_ass テーブル（医師会マスタ）

| カラム名 | データ型 | 説明 | 移行済み | 備考 |
|---------|---------|------|---------|------|
| sec_cd | int(11) | セクションコード | <input type="checkbox"> |  |
| are_cd | int(11) | 地域コード | <input type="checkbox"> |  |
| sec_medarea | varchar(10) | セクション医療圏 | <input type="checkbox"> |  |
| med_ass | varchar(10) | 医師会 | <input type="checkbox"> |  |

---

## message テーブル（メッセージ機能）

| カラム名 | データ型 | 説明 | 移行済み | 備考 |
|---------|---------|------|---------|------|
| id | int(11) | ID（主キー） | <input type="checkbox"> |  |
| situation | int(11) | 対応状況 | <input type="checkbox"> |  |
| req_date | date | 依頼日 | <input type="checkbox"> |  |
| res_date | date | 対応日 | <input type="checkbox"> |  |
| comment | text | 内容 | <input type="checkbox"> |  |
| req_fac | text | 依頼者施設 | <input type="checkbox"> |  |
| req_dep | text | 依頼者所属 | <input type="checkbox"> |  |
| view | int(11) | 表示/非表示 | <input type="checkbox"> |  |
| version | varchar(50) | システムバージョン | <input type="checkbox"> |  |

---

## message_old テーブル（メッセージ過去DB）

| カラム名 | データ型 | 説明 | 移行済み | 備考 |
|---------|---------|------|---------|------|
| id | int(11) | ID（主キー） | <input type="checkbox"> |  |
| situation | int(11) | 対応状況 | <input type="checkbox"> |  |
| date | date | 日付 | <input type="checkbox"> |  |
| comment | text | 内容 | <input type="checkbox"> |  |
| req_fac | text | 依頼者施設 | <input type="checkbox"> |  |
| req_dep | text | 依頼者所属 | <input type="checkbox"> |  |
| view | int(11) | 表示/非表示 | <input type="checkbox"> |  |

---

## positions テーブル（役職マスタ）

| カラム名 | データ型 | 説明 | 移行済み | 備考 |
|---------|---------|------|---------|------|
| order | int(11) | 順番 | <input type="checkbox"> |  |
| position | varchar(50) | 役職名 | <input type="checkbox"> |  |

---

## q_a テーブル（お問い合わせ）

| カラム名 | データ型 | 説明 | 移行済み | 備考 |
|---------|---------|------|---------|------|
| que_id | int(11) | 管理番号（主キー） | <input type="checkbox"> |  |
| order_date | date | 依頼日 | <input type="checkbox"> |  |
| r_staff_num | varchar(10) | 依頼者の職員番号 | <input type="checkbox"> |  |
| content | varchar(255) | お問い合わせ内容 | <input type="checkbox"> |  |
| req_image | varchar(255) | 依頼者から送られてくる画像 | <input type="checkbox"> |  |
| advisability | int(11) | 対応可否 | <input type="checkbox"> |  |
| supp_status | int(11) | 対応状況 | <input type="checkbox"> |  |
| answer | varchar(255) | お問い合わせに対する回答 | <input type="checkbox"> |  |
| ans_image | varchar(50) | 回答者からの画像 | <input type="checkbox"> |  |
| ans_date | date | 回答日 | <input type="checkbox"> |  |
| a_staff_num | varchar(10) | 回答者の職員番号 | <input type="checkbox"> |  |
| supp_date | date | 対応日 | <input type="checkbox"> |  |
| emerg | int(2) | 緊急 | <input type="checkbox"> |  |
| trash_flg | int(11) | ゴミ箱フラグ | <input type="checkbox"> |  |

---

## relative テーブル（親族情報）

| カラム名 | データ型 | 説明 | 移行済み | 備考 |
|---------|---------|------|---------|------|
| hos_cd | varchar(10) | 医療機関コード | <input type="checkbox"> |  |
| name | varchar(60) | 氏名 | <input type="checkbox"> |  |
| conn | varchar(15) | 関係 | <input type="checkbox"> |  |
| sch_name | varchar(100) | 学校名 | <input type="checkbox"> |  |
| ent_year | year(4) | 入学年 | <input type="checkbox"> |  |
| gra_year | year(4) | 卒業年 | <input type="checkbox"> |  |
| note | varchar(200) | 備考 | <input type="checkbox"> |  |
| delete_flg | int(11) | 削除フラグ | <input type="checkbox"> |  |
| rel_cd | int(11) | 親族コード（主キー） | <input type="checkbox"> |  |

---

## social_meeting テーブル（医療連携懇話会参加年度）

| カラム名 | データ型 | 説明 | 移行済み | 備考 |
|---------|---------|------|---------|------|
| hos_cd | varchar(10) | 医療機関コード | <input type="checkbox"> |  |
| ins | int(11) | 施設区分（0:附属 1:総合） | <input type="checkbox"> |  |
| year | varchar(4) | 参加年度 | <input type="checkbox"> |  |
| delete_flg | int(11) | 削除フラグ | <input type="checkbox"> |  |

---

## training テーブル（兼業）

| カラム名 | データ型 | 説明 | 移行済み | 備考 |
|---------|---------|------|---------|------|
| hos_cd | varchar(10) | 医療機関コード | <input type="checkbox"> |  |
| year | year(4) | 年度 | <input type="checkbox"> |  |
| ins | int(11) | 施設区分（0:附属 1:総合） | <input type="checkbox"> |  |
| tra_name | varchar(200) | 研修先医療機関名 | <input type="checkbox"> |  |
| dep | varchar(60) | 診療科 | <input type="checkbox"> |  |
| position | varchar(30) | 職名 | <input type="checkbox"> |  |
| name | varchar(60) | 氏名 | <input type="checkbox"> |  |
| start | date | 診療支援開始日 | <input type="checkbox"> |  |
| end | date | 診療支援終了日 | <input type="checkbox"> |  |
| dia_div | varchar(50) | 診療支援区分 | <input type="checkbox"> |  |
| date | varchar(300) | 日付 | <input type="checkbox"> |  |

---

## training_backup テーブル（兼業バックアップ）

*trainingテーブルと同じ構造*

---

## training_old テーブル（院外診療支援・研修）

| カラム名 | データ型 | 説明 | 移行済み | 備考 |
|---------|---------|------|---------|------|
| hos_cd | varchar(10) | 医療機関コード | <input type="checkbox"> |  |
| year | year(4) | 年度 | <input type="checkbox"> |  |
| ins | int(11) | 施設区分（0:附属 1:総合） | <input type="checkbox"> |  |
| tra_name | varchar(200) | 研修先医療機関名 | <input type="checkbox"> |  |
| tra_div | varchar(20) | 区分 | <input type="checkbox"> |  |
| dep | varchar(60) | 診療科 | <input type="checkbox"> |  |
| occ | varchar(30) | 職名 | <input type="checkbox"> |  |
| name | varchar(60) | 氏名 | <input type="checkbox"> |  |
| start | date | 診療支援開始日 | <input type="checkbox"> |  |
| end | date | 診療支援終了日 | <input type="checkbox"> |  |
| date | varchar(300) | 診療支援日 | <input type="checkbox"> |  |
| occ_turn | int(11) | 役職順 | <input type="checkbox"> |  |

---

## user テーブル（ユーザー情報）

| カラム名 | データ型 | 説明 | 移行済み | 備考 |
|---------|---------|------|---------|------|
| user_id | varchar(10) | ユーザーID | <input type="checkbox" checked> |  |
| user_name | varchar(50) | ユーザー名 | <input type="checkbox" checked> |  |
| ins | varchar(10) | 所属施設 | <input type="checkbox" checked> |  |
| bel | varchar(30) | 所属部署 | <input type="checkbox" checked> |  |
| pw | varchar(255) | パスワード | <input type="checkbox" checked> |  |
| adm_user | int(11) | 管理者ユーザー | <input type="checkbox" checked> |  |
| edi_user | int(11) | 編集者ユーザー | <input type="checkbox" checked> |  |
| start | varchar(30) | 開始日 | <input type="checkbox" checked> |  |
| end | varchar(30) | 終了日 | <input type="checkbox" checked> |  |
| onf | int(11) | オンフラグ | <input type="checkbox" checked> |  |
| up_date | varchar(1000) | 更新日 | <input type="checkbox" checked> |  |

---

## チェック項目の説明

- **<input type="checkbox">**: 未確認・未移行
- **☑**: 移行済み・対応済み
- **備考欄**: 移行時の注意点、変更点、廃止予定等を記入

## 移行作業メモ

### 重要なテーブル（優先的に確認が必要）
- [ ] main（医療機関基本情報）
- [ ] contact（コンタクト履歴）
- [ ] intro（紹介）
- [ ] invers_intro（逆紹介）
- [ ] training（兼業）
- [ ] user（ユーザー情報）

### 注意が必要なテーブル
- [ ] medcare（診療内容）- med_1～med_164の大量カラム
- [ ] tmp1（一時保存用）- 削除対象の可能性
- [ ] *_backup、*_copy系テーブル - バックアップ用途

### 確認完了日
- 作業開始日: ______年____月____日
- 作業完了日: ______年____月____日
- 確認者: ________________

---

**最終更新**: 2025年9月25日