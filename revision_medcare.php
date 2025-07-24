<?php
// 主に、「medcare」テーブルについての修正を記述する

// function.php
function detail_medCare($dbh,$hos_cd){
    //$sql="SELECT * FROM medcare WHERE delete_flg=0 AND hos_cd=:hos_cd;";
    $sql="SELECT mc.hos_cd,cat.med_item_name,mc.value,mc.med_note
    FROM medcare AS mc LEFT JOIN medcare_categories AS cat ON mc.med_item_cd = cat.med_item_cd WHERE mc.delete_flg=0 AND mc.hos_cd=:hos_cd;";
    $stmt = $dbh->prepare($sql);
    $stmt->bindvalue(':hos_cd', $hos_cd, PDO::PARAM_STR);
    $stmt->execute();
    $data = array();
    while($row = $stmt->fetch(PDO::FETCH_ASSOC)){
        $data[] = $row;
    }
return $data;
}

// こんにちは

