<?php
/***

    修正すべきファイル一覧
    - functions.php
    - Medical_control.php
    - Medical_view.php
    - office_Medical_view.php
    - user_Medical_view.php

***/

// functions.php -------------------------------------------------------
function detail_medCare($dbh,$hos_cd){
// 
    $sql = "SELECT hos_cd,value,med_note,delete_flg FROM medcare WHERE delete_flg=0 AND hos_cd=:hos_cd;";
    $stmt = $dbh->prepare($sql);
    $stmt->bindvalue(':hos_cd', $hos_cd, PDO::PARAM_STR);
    $stmt->execute();
    $data = array();
    while($row = $stmt->fetch(PDO::FETCH_ASSOC)){
        $data[] = $row;
    }
    return $data;
}

// ↓ Medical_control.phpについて ↓ -----------------------------------------------
// 診療科マスタから動的にデータを取得する関数（GROUP BY使用版）
function getMedicalDepartments($dbh) {
    $med_depts = array();
    
    // GROUP_CONCATを使用してSQLレベルでグループ化
    $master_depts = getMedicalDeptFromMasterGrouped($dbh);
    
    // SQLで既にグループ化されているので、カンマ区切り文字列を配列に変換
    foreach ($master_depts as $dept) {
        $division = $dept['med_div'];
        $departments_str = $dept['departments'];
        
        // カンマ区切りの診療科を配列に変換し、前後の空白を削除
        if (!empty($departments_str)) {
            $departments = array_map('trim', explode(',', $departments_str));
            // 空の要素を除去
            $departments = array_filter($departments, function($item) {
                return !empty($item);
            });
            $med_depts[$division] = $departments;
        } else {
            $med_depts[$division] = array();
        }
    }
    
    // マスタにデータがない場合のフォールバック（既存のべた書きデータ）
    if (empty($med_depts)) {
        $med_depts = getFallbackMedicalDepartments();
    }
    
    return $med_depts;
}

// medcare_mstテーブルから診療科データをGROUP BYで取得
function getMedicalDeptFromMasterGrouped($dbh) {
    try {
        $sql = "SELECT 
                    med_div, 
                    GROUP_CONCAT(DISTINCT med_dep ORDER BY med_dep SEPARATOR ',') as departments
                FROM medcare_mst 
                GROUP BY med_div 
                ORDER BY 
                    CASE med_div 
                        WHEN '全般' THEN 1 
                        WHEN '内科系' THEN 2 
                        WHEN '外科系' THEN 3 
                        ELSE 4 
                    END";
        $stmt = $dbh->prepare($sql);
        $stmt->execute();
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    } catch (PDOException $e) {
        // エラーログを出力（本番環境では適切なログ処理を行う）
        error_log("medcare_mst GROUP BY取得エラー: " . $e->getMessage());
        return array();
    }
}

// フォールバック用の既存データ（マスタテーブルにデータがない場合）
// 注意: マスタテーブル medcare_mst に164件のデータが登録済みなので、
// 通常この関数は使用されません。マスタテーブルのバックアップとして保持。
function getFallbackMedicalDepartments() {
    return array(
        '全般' => array('各種治療','在宅診療内容','各種検査'),
        '内科系' => array(
            '消化器内科', '呼吸器内科', '精神科・神経科・診療内科', 
            '内分泌・糖尿病（代謝内科）', '（脳）神経内科・脳卒中内科', '腎臓内科', 
            '小児科', '循環器内科'
        ),
        '外科系' => array(
            '外科', '呼吸器外科', '腎臓移植外科', 
            '乳腺外科', '泌尿器科', '耳鼻咽喉科', 
            '歯科・口腔外科', '整形外科・リハビリ・リウマチ科', 
            '脳神経外科', '形成外科', '産婦人科', 
            '皮膚科', '眼科'
        )
    );
}
// ↑ Medical_control.phpについて ↑ -----------------------------------------------



// control/Medical_control.php ----------------------------------------

// <?php
//ユーザー定義関数ファイルfunctions.phpの読み込み
require_once('../functions.php');
   $hos_cd= $_GET['cd'];

$dbh = get_db_connect();

/* 高橋20230224 診療内容データ */
$medCare_data = detail_medCare($dbh,$hos_cd);

// 動的に診療科データを取得
$med_depts = getMedicalDepartments($dbh);

$medCare_all = medCare($dbh,'全般');
$medCare_naika = medCare($dbh,'内科系');
$medCare_geka = medCare($dbh,'外科系');


// view/Medical_view.php -----------------------------------------------

// control/Medical_control.php から診療内容データを取得している（$medCare_data）
// $medCare_data = detail_medCare($dbh,$hos_cd);
?>

<?php 
if(!empty($medCare_data)){ //もしデータがあれば 
    foreach ($medCare_data as $key =>$var):?>
            <div class="uk-margin"><!--全般-->
            <h5 class="meddiv">全般</h5>
            <?php foreach($med_depts['全般'] as $Div=>$Dep){ ?>
            <table class="uk-table table-h-green" style="display:inline;">
            <tr><th>【<b><?php echo $Dep; ?></b>】</th></tr>
                    <?php 
                    foreach($medCare_all as $Det){ 
                            if($Dep===$Det['med_dep']){ ?>
                    <tr><td><label><input type="checkbox" class="uk-checkbox" name="med_care[<?php echo $Det['med_code']; ?>]" value="1" <?php if(!empty($medCare_data) && $var['med_'.$Det['med_code']]==='1'){ echo 'checked'; } ?>><?php echo ($Det['med_det']);?></label><br></td></tr>
                    <?php   } 
                    }?>
            </table>
            <?php } ?>
            </div>

            <div class="uk-margin"><!--内科系-->
            <h5 class="meddiv">内科系</h5>
            <?php foreach($med_depts['内科系'] as $Div=>$Dep){ ?>
            <table class="uk-table table-h-green" style="display:inline;">
            <tr><th>【<b><?php echo $Dep; ?></b>】</th></tr>
                    <?php 
                    foreach($medCare_naika as $Det){ 
                            if($Dep===$Det['med_dep']){ ?>
                    <tr><td><label><input type="checkbox" class="uk-checkbox" name="med_care[<?php echo $Det['med_code']; ?>]" value="1" <?php if(!empty($medCare_data) && $var['med_'.$Det['med_code']]==='1'){ echo 'checked'; } ?>><?php echo ($Det['med_det']);?></label><br></td></tr>
                    <?php   } 
                    }?>
            </table>
            <?php } ?>
            </div>

            <div class="uk-margin"><!--外科系-->
            <h5 class="meddiv">外科系</h5>
            <?php foreach($med_depts['外科系'] as $Div=>$Dep){ ?>
            <table class="uk-table table-h-green" style="display:inline;">
            <tr><th>【<b><?php echo $Dep; ?></b>】</th></tr>
                    <?php 
                    foreach($medCare_geka as $Det){ 
                            if($Dep===$Det['med_dep']){ ?>
                    <tr><td><label><input type="checkbox" class="uk-checkbox" name="med_care[<?php echo $Det['med_code']; ?>]" value="1" <?php if(!empty($medCare_data) && $var['med_'.$Det['med_code']]==='1'){ echo 'checked'; } ?>><?php echo ($Det['med_det']);?></label><br></td></tr>
                    <?php   } 
                    }?>
            </table>
            <?php } ?>
            </div>

    <?php 
    endforeach;
}
?>

<div class="detail-section" id="to-note9"><!-- 備考 -->
<h4>備考
<label class="uk-form-label">（自由入力、1000文字以内）</label></h4>
        <div class="uk-form-controls">
        <textarea class="uk-textarea size-textarea-Notes" name="mcare_note" rows="7" maxlength="1000"><?php foreach ($medCare_data as $key =>$var){ echo html_escape(trim($var['med_note'])); } ?></textarea>
        </div>
</div>

<?php
// office_view/office_Medical_view.php ---------------------------------

// user_view/user_Medical_view.php -------------------------------------




