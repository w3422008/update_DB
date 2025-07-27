<?php
// 主に、「medcare」テーブルについての修正を記述する

// function.php
function detail_medCare($dbh,$hos_cd){
    //$sql="SELECT * FROM medcare WHERE delete_flg=0 AND hos_cd=:hos_cd;";
    $sql="SELECT mc.hos_cd,cat.med_item_name,mc.value,mc.med_note 
    FROM medcare AS mc LEFT JOIN medcare_categories AS cat ON mc.med_item_cd = cat.med_item_cd 
    WHERE mc.delete_flg=0 AND mc.hos_cd=:hos_cd;";
    $stmt = $dbh->prepare($sql);
    $stmt->bindvalue(':hos_cd', $hos_cd, PDO::PARAM_STR);
    $stmt->execute();
    $data = array();
    while($row = $stmt->fetch(PDO::FETCH_ASSOC)){
        $data[] = $row;
    }
return $data;
}

// control/Medical_control.php から診療内容データを取得している（$medCare_data）
// $medCare_data = detail_medCare($dbh,$hos_cd);

// view/Medical_view.php
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
// office_view/office_Medical_view.php

// user_view/user_Medical_view.php




