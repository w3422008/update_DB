<?php
require __DIR__ . '/../lib/bootstrap.php';
require __DIR__ . '/../lib/csrf.php';
require __DIR__ . '/../lib/rate_limit.php';
require __DIR__ . '/../lib/auth_adapter.php';
$err=$_GET['err']??'';
if($_SERVER['REQUEST_METHOD']==='POST'){
  csrf_validate();
  $userId=trim($_POST['user_id']??''); $pw=$_POST['password']??''; $ip=$_SERVER['REMOTE_ADDR']??'unknown';
  $ipKey="ip:$ip"; $uidKey="uid:$userId";
  if(rl_too_many($pdo,$ipKey,20,'15 MINUTE')||rl_too_many($pdo,$uidKey,10,'15 MINUTE')){
    $err='試行回数が多すぎます。しばらくしてからお試しください。';
  }else{
    $ok=check_credentials($userId,$pw);
    if(!$ok){ rl_record($pdo,$ipKey); rl_record($pdo,$uidKey); usleep(250000); $err='IDまたはパスワードが正しくありません。'; }
    else{ session_regenerate_id(true); $_SESSION['user_id']=$userId; after_login($userId); header('Location: ./dashboard.php'); exit; }
  }
}
?><!doctype html><html lang="ja"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>医療機関情報システム - ログイン</title>
<style>
body{font-family:system-ui,-apple-system,Segoe UI,Roboto,Helvetica,Arial,sans-serif;background:#fff;margin:2rem}
h1{color:#2f8b2f;margin:0 0 1.5rem}
label{display:block;margin:.75rem 0 .25rem;color:#2f8b2f;font-weight:600}
input{width:420px;max-width:100%;padding:.7rem;border:1px solid #ddd;border-radius:10px;background:#f2f2f2}
button{margin-top:1rem;padding:.8rem 1.4rem;border:0;border-radius:10px;background:#6b6b6b;color:#fff;font-weight:700;cursor:pointer}
.wrap{max-width:720px;margin:0 auto}
.tabs{display:flex;border:1px solid #cfcfcf;border-bottom:none;margin-top:2rem}
.tab{flex:1;text-align:center;padding:.7rem 0;border-right:1px solid #cfcfcf;background:#eee;cursor:pointer}
.tab:last-child{border-right:none}
.tab.active{background:#4CAF50;color:#fff;font-weight:700}
.panel{border:1px solid #cfcfcf;padding:1rem;min-height:140px}
.err{color:#b00020;margin:.5rem 0}
</style></head><body><div class="wrap">
<h1>医療機関情報システム</h1>
<?php if($err):?><div class="err"><?=h($err)?></div><?php endif;?>
<form method="post" action="./login.php" autocomplete="off">
<?=csrf_field()?>
<label for="uid">ID</label><input id="uid" type="text" name="user_id" required>
<label for="pw">パスワード</label><input id="pw" type="password" name="password" required>
<div><button type="submit">ログイン</button></div>
</form>
<div class="tabs" id="tabs">
  <div class="tab active" data-key="info">お知らせ</div>
  <div class="tab" data-key="recent">最近</div>
  <div class="tab" data-key="maint">メンテナンス</div>
  <div class="tab" data-key="other">その他</div>
</div>
<div class="panel" id="panel">📢 メンテナンスについてのお知らせをここに表示します。</div>
</div>
<script>
const tabs=document.querySelectorAll('#tabs .tab'); const panel=document.getElementById('panel');
const data={info:'📢 メンテナンスについてのお知らせをここに表示します。',recent:'🗂 最近の更新情報をここに表示します。',maint:'🛠 定期メンテナンス情報をここに表示します。',other:'💡 その他のお知らせをここに表示します。'};
tabs.forEach(t=>t.addEventListener('click',()=>{tabs.forEach(x=>x.classList.remove('active')); t.classList.add('active'); panel.textContent=data[t.dataset.key];}));
</script>
</body></html>