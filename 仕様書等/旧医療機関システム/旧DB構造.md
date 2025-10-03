## area

| カラム名   | コメント   |
|:-----------|:-----------|
| are_cd     |            |
| area_name  |            |
| sec_cd     |            |
| area1      |            |
| area2      |            |
| city       |            |
| zone       |            |
| town       |            |


## c_path

| カラム名   | コメント             |
|:-----------|:---------------------|
| hos_cd     |                      |
| ins        | 0(附)or1(総)         |
| cp0        | 入退院支援連携先病院 |
| cp1        | 脳卒中パス           |
| cp2        | 大腿骨パス           |
| cp3        | 心筋梗塞・心不全パス |
| cp4        | 胃がんパス           |
| cp5        | 大腸がんパス         |
| cp6        | 乳がんパス           |
| cp7        | 肺がんパス           |
| cp8        | 肝がんパス           |
| delete_flg | 削除フラグ           |


## carna_connect

| カラム名   | コメント   |
|:-----------|:-----------|
| hos_cd     |            |
| delete_flg |            |


## contact

| カラム名    | コメント               |
|:------------|:-----------------------|
| con_cd      | con_cd★主キー          |
| hos_cd      | 医療機関CD             |
| hos_name    | 医療機関名             |
| year        | 年度                   |
| ins         | 施設区分               |
| date        | 日付                   |
| method      | 方法                   |
| ex_dept     | 連携機関対応者部署     |
| ex_position | 連携機関対応者役職     |
| ex_name     | 連携機関対応者氏名     |
| ex_subnames | 連携機関対応人数・氏名 |
| in_dept     | 当院対応者所属         |
| in_name     | 当院対応者氏名         |
| in_subnames | 当院対応人数・氏名     |
| detail      | 内容                   |
| con_note    | 備考                   |
| data_dept   | データ作成部署         |


## contact_backup

| カラム名    | コメント               |
|:------------|:-----------------------|
| con_cd      | con_cd★主キー          |
| hos_cd      | 医療機関CD             |
| hos_name    | 医療機関名             |
| year        | 年度                   |
| ins         | 施設区分               |
| date        | 日付                   |
| method      | 方法                   |
| ex_dept     | 連携機関対応者部署     |
| ex_position | 連携機関対応者役職     |
| ex_name     | 連携機関対応者氏名     |
| ex_subnames | 連携機関対応人数・氏名 |
| in_dept     | 当院対応者所属         |
| in_name     | 当院対応者氏名         |
| in_subnames | 当院対応人数・氏名     |
| detail      | 内容                   |
| con_note    | 備考                   |
| data_dept   | データ作成部署         |


## delete_log

| カラム名   | コメント   |
|:-----------|:-----------|
| hos_cd     |            |
| hos_name   |            |
| log_data   |            |
| user_name  |            |
| user_id    |            |
| ins        |            |
| bel        |            |
| adm_user   |            |


## department

| カラム名   | コメント   |
|:-----------|:-----------|
| sec_cd     |            |
| sec_name   |            |
| dep_cd     |            |
| dep_name   |            |


## field_junction

| カラム名   | コメント   |
|:-----------|:-----------|
| hos_cd     |            |
| hos_name   |            |
| fie_div    |            |
| fie_name   |            |
| tel        |            |
| fax        |            |
| note       |            |
| delete_flg |            |
| fie_cd     |            |
| hos_cd     |            |
| fie_div    |            |


## insert_log

| カラム名   | コメント   |
|:-----------|:-----------|
| hos_cd     |            |
| hos_name   |            |
| log_data   |            |
| user_name  |            |
| user_id    |            |
| ins        |            |
| bel        |            |
| adm_user   |            |


## intro

| カラム名   | コメント     |
|:-----------|:-------------|
| hos_cd     | 医療機関CD   |
| ins        | 0(附)or1(総) |
| year       | 年度         |
| fie_cd     | 診療科コード |
| fie_name   | 診療科       |
| intr       | 紹介件数     |


## intro_backup

| カラム名   | コメント     |
|:-----------|:-------------|
| hos_cd     | 医療機関CD   |
| ins        | 0(附)or1(総) |
| year       | 年度         |
| fie_cd     | 診療科コード |
| fie_name   | 診療科       |
| intr       | 紹介件数     |


## invers_intro

| カラム名   | コメント     |
|:-----------|:-------------|
| hos_cd     | 医療機関CD   |
| ins        | 0(附)or1(総) |
| year       | 年度         |
| fie_cd     | 診療科コード |
| fie_name   | 診療科       |
| invr_intr  | 逆紹介件数   |


## invers_intro_backup

| カラム名   | コメント     |
|:-----------|:-------------|
| hos_cd     | 医療機関CD   |
| ins        | 0(附)or1(総) |
| year       | 年度         |
| fie_cd     | 診療科コード |
| fie_name   | 診療科       |
| invr_intr  | 逆紹介件数   |


## main

| カラム名   | コメント   |
|:-----------|:-----------|
| op_flg     |            |
| med_ass    |            |
| hos_div    |            |
| hos_cd     |            |
| hos_name   |            |
| zipcode    |            |
| ad         |            |
| tel        |            |
| fax        |            |
| email      |            |
| are_cd     |            |
| pre        |            |
| area       |            |
| city       |            |
| zone       |            |
| town       |            |
| str_num    |            |
| note       |            |
| clo_day    |            |
| chi_name   |            |
| chi_spe    |            |
| chi_year   |            |
| chi_sch    |            |
| chi_note   |            |
| pre_name   |            |
| pre_spe    |            |
| pre_year   |            |
| pre_sch    |            |
| pre_note   |            |
| con_hour   |            |
| mon_am     |            |
| mon_pm     |            |
| tue_am     |            |
| tue_pm     |            |
| wed_am     |            |
| wed_pm     |            |
| thr_am     |            |
| thr_pm     |            |
| fri_am     |            |
| fri_pm     |            |
| sat_am     |            |
| sat_pm     |            |
| sun_am     |            |
| sun_pm     |            |
| holiday    |            |
| int_med    |            |
| ped_med    |            |
| sur_med    |            |
| ort_med    |            |
| oph_med    |            |
| ent_med    |            |
| so_med     |            |
| gyn_med    |            |
| psy_med    |            |
| den_med    |            |
| etc_med    |            |
| int_int    |            |
| int_dig    |            |
| int_uri    |            |
| int_tum    |            |
| int_res    |            |
| int_kid    |            |
| int_blo    |            |
| int_apo    |            |
| int_cir    |            |
| int_ner    |            |
| int_inf    |            |
| ped_ped    |            |
| ped_sur    |            |
| ped_neo    |            |
| sur_sur    |            |
| sur_lac    |            |
| sur_ner    |            |
| sur_nes    |            |
| sur_dig    |            |
| sur_car    |            |
| sur_ven    |            |
| ort_rhe    |            |
| ort_cos    |            |
| ort_ort    |            |
| ort_reh    |            |
| ort_pla    |            |
| oph_oph    |            |
| ent_ent    |            |
| ent_to     |            |
| so_sky     |            |
| so_org     |            |
| gyn_gyn    |            |
| gyn_obs    |            |
| gyn_gyne   |            |
| psy_psy    |            |
| psy_psyc   |            |
| den_den    |            |
| den_cav    |            |
| den_ref    |            |
| den_ped    |            |
| alle       |            |
| pat        |            |
| checkup    |            |
| rad        |            |
| cli        |            |
| ane        |            |
| eme        |            |
| bed        |            |
| bed_reh    |            |
| bed_tre    |            |
| bed_main   |            |
| bed_care   |            |
| bed_tra    |            |
| pt         |            |
| bed_att    |            |
| ot         |            |
| st         |            |
| onf        |            |
| dep_note   |            |
| drct_note  |            |
| num_note   |            |
| intr_note  |            |
| tra_note   |            |
| coop_note  |            |
| con_note   |            |
| log_data   |            |
| log_name   |            |
| ad         |            |
| area       |            |
| city       |            |
| zone       |            |
| town       |            |
| hos_name   |            |


## maintenance

| カラム名    | コメント         |
|:------------|:-----------------|
| id          |                  |
| title       | タイトル         |
| upload_date | アップロード日   |
| date        | 作業日           |
| start_time  | 予定作業開始時刻 |
| end_time    | 予定作業終了時刻 |
| comment     | 実施内容         |
| view        | 表示/非表示      |


## maintenance_start

| カラム名   | コメント      |
|:-----------|:--------------|
| id         |               |
| title      | 通知タイトル  |
| comment    | 通知タイトル2 |
| date       | 作業日        |
| start_time | 作業開始時刻  |
| end_time   | 作業終了時刻  |
| comment2   | 実施内容      |
| view       | 表示/非表示   |


## med_ass

| カラム名    | コメント   |
|:------------|:-----------|
| sec_cd      |            |
| are_cd      |            |
| sec_medarea |            |
| med_ass     |            |


## medcare

| カラム名   | コメント   |
|:-----------|:-----------|
| hos_cd     |            |
| med_1      |            |
| med_2      |            |
| med_3      |            |
| med_5      |            |
| med_4      |            |
| med_6      |            |
| med_7      |            |
| med_8      |            |
| med_9      |            |
| med_10     |            |
| med_11     |            |
| med_12     |            |
| med_13     |            |
| med_14     |            |
| med_15     |            |
| med_16     |            |
| med_17     |            |
| med_18     |            |
| med_19     |            |
| med_20     |            |
| med_21     |            |
| med_22     |            |
| med_23     |            |
| med_24     |            |
| med_25     |            |
| med_26     |            |
| med_27     |            |
| med_28     |            |
| med_29     |            |
| med_30     |            |
| med_31     |            |
| med_32     |            |
| med_33     |            |
| med_34     |            |
| med_35     |            |
| med_36     |            |
| med_37     |            |
| med_38     |            |
| med_39     |            |
| med_40     |            |
| med_41     |            |
| med_42     |            |
| med_43     |            |
| med_44     |            |
| med_45     |            |
| med_46     |            |
| med_47     |            |
| med_48     |            |
| med_49     |            |
| med_50     |            |
| med_51     |            |
| med_52     |            |
| med_53     |            |
| med_54     |            |
| med_55     |            |
| med_56     |            |
| med_57     |            |
| med_58     |            |
| med_59     |            |
| med_60     |            |
| med_61     |            |
| med_62     |            |
| med_63     |            |
| med_64     |            |
| med_65     |            |
| med_66     |            |
| med_67     |            |
| med_68     |            |
| med_69     |            |
| med_70     |            |
| med_71     |            |
| med_72     |            |
| med_73     |            |
| med_74     |            |
| med_75     |            |
| med_76     |            |
| med_77     |            |
| med_78     |            |
| med_79     |            |
| med_80     |            |
| med_81     |            |
| med_82     |            |
| med_83     |            |
| med_84     |            |
| med_85     |            |
| med_86     |            |
| med_87     |            |
| med_88     |            |
| med_89     |            |
| med_90     |            |
| med_91     |            |
| med_92     |            |
| med_93     |            |
| med_94     |            |
| med_95     |            |
| med_96     |            |
| med_97     |            |
| med_98     |            |
| med_99     |            |
| med_100    |            |
| med_101    |            |
| med_102    |            |
| med_103    |            |
| med_104    |            |
| med_105    |            |
| med_106    |            |
| med_107    |            |
| med_108    |            |
| med_109    |            |
| med_110    |            |
| med_111    |            |
| med_112    |            |
| med_113    |            |
| med_114    |            |
| med_115    |            |
| med_116    |            |
| med_117    |            |
| med_118    |            |
| med_119    |            |
| med_120    |            |
| med_121    |            |
| med_122    |            |
| med_123    |            |
| med_124    |            |
| med_125    |            |
| med_126    |            |
| med_127    |            |
| med_128    |            |
| med_129    |            |
| med_130    |            |
| med_131    |            |
| med_132    |            |
| med_133    |            |
| med_134    |            |
| med_135    |            |
| med_136    |            |
| med_137    |            |
| med_138    |            |
| med_139    |            |
| med_140    |            |
| med_141    |            |
| med_142    |            |
| med_143    |            |
| med_144    |            |
| med_145    |            |
| med_146    |            |
| med_147    |            |
| med_148    |            |
| med_149    |            |
| med_150    |            |
| med_151    |            |
| med_152    |            |
| med_153    |            |
| med_154    |            |
| med_155    |            |
| med_156    |            |
| med_157    |            |
| med_158    |            |
| med_159    |            |
| med_160    |            |
| med_161    |            |
| med_162    |            |
| med_163    |            |
| med_164    |            |
| med_note   |            |
| delete_flg |            |


## medcare_mst

| カラム名   | コメント   |
|:-----------|:-----------|
| med_code   |            |
| med_div    |            |
| med_dep    |            |
| med_det    |            |


## message

| カラム名   | コメント                     |
|:-----------|:-----------------------------|
| id         | 主キー                       |
| situation  | 対応状況                     |
| req_date   | 依頼日                       |
| res_date   | 対応日                       |
| comment    | 内容                         |
| req_fac    | 依頼者施設                   |
| req_dep    | 依頼者所属                   |
| view       | 表示/非表示                  |
| version    | 医療機関システムのバージョン |


## message_old

| カラム名   | コメント   |
|:-----------|:-----------|
| id         |            |
| situation  |            |
| date       |            |
| comment    |            |
| req_fac    |            |
| req_dep    |            |
| view       |            |


## q_a

| カラム名     | コメント                   |
|:-------------|:---------------------------|
| que_id       | 管理番号                   |
| order_date   | 依頼日                     |
| r_staff_num  | 依頼者の職員番号           |
| content      | お問い合わせ内容           |
| req_image    | 依頼者から送られてくる画像 |
| advisability | 対応可否                   |
| supp_status  | 対応状況                   |
| answer       | お問い合わせに対する回答   |
| ans_image    | 回答者からの画像           |
| ans_date     | 回答日                     |
| a_staff_num  | 回答者の職員番号           |
| supp_date    | 対応日                     |
| emerg        | 緊急                       |
| trash_flg    |                            |


## relative

| カラム名   | コメント   |
|:-----------|:-----------|
| hos_cd     |            |
| name       |            |
| conn       |            |
| sch_name   |            |
| ent_year   |            |
| gra_year   |            |
| note       |            |
| delete_flg |            |
| rel_cd     |            |
| hos_cd     |            |


## social_meeting

| カラム名   | コメント     |
|:-----------|:-------------|
| hos_cd     | 医療機関CD   |
| ins        | 0(附)or1(総) |
| year       | 参加年度     |
| delete_flg | 削除フラグ   |


## test_intro

| カラム名   | コメント     |
|:-----------|:-------------|
| hos_cd     | 医療機関CD   |
| ins        | 0(附)or1(総) |
| fie_name   | 診療科       |
| year       | 年度         |
| intr       | 紹介件数     |


## test_invers_intro

| カラム名   | コメント     |
|:-----------|:-------------|
| hos_cd     | 医療機関CD   |
| ins        | 0(附)or1(総) |
| fie_name   | 診療科       |
| year       | 年度         |
| invr_intr  | 逆紹介件数   |


## tmp1

| カラム名   | コメント   |
|:-----------|:-----------|
| op_flg     |            |
| med_ass    |            |
| hos_div    |            |
| hos_cd     |            |
| hos_name   |            |
| zipcode    |            |
| ad         |            |
| tel        |            |
| fax        |            |
| email      |            |
| are_cd     |            |
| pre        |            |
| area       |            |
| city       |            |
| zone       |            |
| town       |            |
| str_num    |            |
| note       |            |
| clo_day    |            |
| chi_name   |            |
| chi_spe    |            |
| chi_year   |            |
| chi_sch    |            |
| chi_note   |            |
| pre_name   |            |
| pre_spe    |            |
| pre_year   |            |
| pre_sch    |            |
| pre_note   |            |
| con_hour   |            |
| mon_am     |            |
| mon_pm     |            |
| tue_am     |            |
| tue_pm     |            |
| wed_am     |            |
| wed_pm     |            |
| thr_am     |            |
| thr_pm     |            |
| fri_am     |            |
| fri_pm     |            |
| sat_am     |            |
| sat_pm     |            |
| sun_am     |            |
| sun_pm     |            |
| holiday    |            |
| int_med    |            |
| ped_med    |            |
| sur_med    |            |
| ort_med    |            |
| oph_med    |            |
| ent_med    |            |
| so_med     |            |
| gyn_med    |            |
| psy_med    |            |
| den_med    |            |
| etc_med    |            |
| int_int    |            |
| int_dig    |            |
| int_uri    |            |
| int_tum    |            |
| int_res    |            |
| int_kid    |            |
| int_blo    |            |
| int_apo    |            |
| int_cir    |            |
| int_ner    |            |
| int_inf    |            |
| ped_ped    |            |
| ped_sur    |            |
| ped_neo    |            |
| sur_sur    |            |
| sur_lac    |            |
| sur_ner    |            |
| sur_nes    |            |
| sur_dig    |            |
| sur_car    |            |
| sur_ven    |            |
| ort_rhe    |            |
| ort_cos    |            |
| ort_ort    |            |
| ort_reh    |            |
| ort_pla    |            |
| oph_oph    |            |
| ent_ent    |            |
| ent_to     |            |
| so_sky     |            |
| so_org     |            |
| gyn_gyn    |            |
| gyn_obs    |            |
| gyn_gyne   |            |
| psy_psy    |            |
| psy_psyc   |            |
| den_den    |            |
| den_cav    |            |
| den_ref    |            |
| den_ped    |            |
| alle       |            |
| pat        |            |
| checkup    |            |
| rad        |            |
| cli        |            |
| ane        |            |
| eme        |            |
| bed        |            |
| bed_reh    |            |
| bed_tre    |            |
| bed_main   |            |
| bed_care   |            |
| bed_tra    |            |
| bed_att    |            |
| pt         |            |
| ot         |            |
| st         |            |
| onf        |            |
| dep_note   |            |
| drct_note  |            |
| num_note   |            |
| intr_note  |            |
| tra_note   |            |
| coop_note  |            |
| con_note   |            |
| log_data   |            |
| log_name   |            |
| intr       |            |
| invr_intr  |            |
| intr       |            |
| invr_intr  |            |


## training

| カラム名   | コメント             |
|:-----------|:---------------------|
| hos_cd     | 医療機関CD           |
| year       | 年度                 |
| ins        | 0(附)or1(総)         |
| tra_name   | 研修先医療機関名     |
| tra_div    | 区分(20240408非表示) |
| dep        | 診療科               |
| occ        | 職名                 |
| name       | 氏名                 |
| start      | 診療支援開始日       |
| end        | 診療支援終了日       |
| dia_div    | 診療支援区分         |
| date       | 日付                 |
| occ_turn   | 役職順               |


## training_backup

| カラム名   | コメント             |
|:-----------|:---------------------|
| hos_cd     | 医療機関CD           |
| year       | 年度                 |
| ins        | 0(附)or1(総)         |
| tra_name   | 研修先医療機関名     |
| tra_div    | 区分(20240408非表示) |
| dep        | 診療科               |
| occ        | 職名                 |
| name       | 氏名                 |
| start      | 診療支援開始日       |
| end        | 診療支援終了日       |
| dia_div    | 診療支援区分         |
| date       | 日付                 |
| occ_turn   | 役職順               |


## training_old

| カラム名   | コメント         |
|:-----------|:-----------------|
| hos_cd     | 医療機関CD       |
| year       | 年度             |
| ins        | 0(附)or1(総)     |
| tra_name   | 研修先医療機関名 |
| tra_div    | 区分             |
| dep        | 診療科           |
| occ        | 職名             |
| name       | 氏名             |
| start      | 診療支援開始日   |
| end        | 診療支援終了日   |
| date       | 診療支援日       |
| occ_turn   | 役職順           |


## user

| カラム名   | コメント   |
|:-----------|:-----------|
| user_id    |            |
| user_name  |            |
| ins        |            |
| bel        |            |
| pw         |            |
| adm_user   |            |
| edi_user   |            |
| start      |            |
| end        |            |
| onf        |            |
| up_date    |            |

