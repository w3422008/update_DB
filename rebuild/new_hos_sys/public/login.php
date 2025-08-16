<!doctype html>
<html lang="ja">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>医療機関情報システム - ログイン</title>
  <link rel="stylesheet" href="../CSS/AppCore.css">
  <link rel="stylesheet" href="../CSS/login.css">
  <script src="../js/login/login_auth.js"></script>
</head>
<body>
  <div class="wrap">
    <h1 class="site-title">医療機関情報システム</h1>
    <!-- ログインフォーム（JSでsubmitをAPIにPOST） -->
    <form method="post" action="./login.php" autocomplete="off">
      <div class="err"></div>
      <label for="uid">ID</label>
      <input id="uid" type="text" name="user_id" required>
      <label for="pw">パスワード</label>
      <input id="pw" type="password" name="password" required>
      <div><button type="submit">ログイン</button></div>
    </form>
    <!-- タブ切り替えで各種お知らせ表示 -->
    <div class="tabs" id="tabs">
      <div class="tab active" data-key="info">
        <span class="tab-icon">
          <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 640" width="18" height="18"><path d="M320 64C306.7 64 296 74.7 296 88L296 97.7C214.6 109.3 152 179.4 152 264L152 278.5C152 316.2 142 353.2 123 385.8L101.1 423.2C97.8 429 96 435.5 96 442.2C96 463.1 112.9 480 133.8 480L506.2 480C527.1 480 544 463.1 544 442.2C544 435.5 542.2 428.9 538.9 423.2L517 385.7C498 353.1 488 316.1 488 278.4L488 263.9C488 179.3 425.4 109.2 344 97.6L344 87.9C344 74.6 333.3 63.9 320 63.9zM488.4 432L151.5 432L164.4 409.9C187.7 370 200 324.6 200 278.5L200 264C200 197.7 253.7 144 320 144C386.3 144 440 197.7 440 264L440 278.5C440 324.7 452.3 370 475.5 409.9L488.4 432zM252.1 528C262 556 288.7 576 320 576C351.3 576 378 556 387.9 528L252.1 528z"/></svg>
        </span>
        お知らせ
      </div>
      <div class="tab" data-key="recent">
        <span class="tab-icon">
          <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 640" width="18" height="18"><!--!Font Awesome Free v7.0.0 by @fontawesome - https://fontawesome.com License - https://fontawesome.com/license/free Copyright 2025 Fonticons, Inc.--><path d="M320 128C426 128 512 214 512 320C512 426 426 512 320 512C254.8 512 197.1 479.5 162.4 429.7C152.3 415.2 132.3 411.7 117.8 421.8C103.3 431.9 99.8 451.9 109.9 466.4C156.1 532.6 233 576 320 576C461.4 576 576 461.4 576 320C576 178.6 461.4 64 320 64C234.3 64 158.5 106.1 112 170.7L112 144C112 126.3 97.7 112 80 112C62.3 112 48 126.3 48 144L48 256C48 273.7 62.3 288 80 288L104.6 288C105.1 288 105.6 288 106.1 288L192.1 288C209.8 288 224.1 273.7 224.1 256C224.1 238.3 209.8 224 192.1 224L153.8 224C186.9 166.6 249 128 320 128zM344 216C344 202.7 333.3 192 320 192C306.7 192 296 202.7 296 216L296 320C296 326.4 298.5 332.5 303 337L375 409C384.4 418.4 399.6 418.4 408.9 409C418.2 399.6 418.3 384.4 408.9 375.1L343.9 310.1L343.9 216z"/></svg>
        </span>
        最近
      </div>
      <div class="tab" data-key="maint">
        <span class="tab-icon">
          <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 640" width="18" height="18"><!--!Font Awesome Free v7.0.0 by @fontawesome - https://fontawesome.com License - https://fontawesome.com/license/free Copyright 2025 Fonticons, Inc.--><path d="M256.1 161.1L256.1 210.7L256.6 211.2C263.1 128.8 332 64 416.1 64C436.2 64 455.5 67.7 473.2 74.5C483.2 78.3 485 91 477.5 98.6L388.8 187.3C385.8 190.3 384.1 194.4 384.1 198.6L384.1 240C384.1 248.8 391.3 256 400.1 256L441.5 256C445.7 256 449.8 254.3 452.8 251.3L541.5 162.6C549.1 155 561.8 156.9 565.6 166.9C572.4 184.6 576.1 203.9 576.1 224C576.1 284.6 542.4 337.4 492.6 364.5L574.1 446C592.8 464.7 592.8 495.1 574.1 513.9L514 574C495.3 592.7 464.9 592.7 446.1 574L320.1 448C292.7 420.6 286.5 380.1 301.6 346.7L210.9 256L161.3 256C150.6 256 140.6 250.7 134.7 241.8L55.4 122.9C51.2 116.6 52 108.1 57.4 102.7L102.8 57.3C108.2 51.9 116.6 51.1 123 55.3L241.9 134.5C250.8 140.4 256.1 150.4 256.1 161.1zM247.6 360.6C241.3 397.6 250 436.7 274 468L179 562.9C150.9 591 105.3 591 77.2 562.9C49.1 534.8 49.1 489.2 77.2 461.1L212.6 325.7L247.6 360.7z"/></svg>
        </span>
        メンテナンス
      </div>
      <div class="tab" data-key="other">
        <span class="tab-icon">
          <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 640" width="18" height="18"><!--!Font Awesome Free v7.0.0 by @fontawesome - https://fontawesome.com License - https://fontawesome.com/license/free Copyright 2025 Fonticons, Inc.--><path d="M304 112L192 112C183.2 112 176 119.2 176 128L176 512C176 520.8 183.2 528 192 528L448 528C456.8 528 464 520.8 464 512L464 272L376 272C336.2 272 304 239.8 304 200L304 112zM444.1 224L352 131.9L352 200C352 213.3 362.7 224 376 224L444.1 224zM128 128C128 92.7 156.7 64 192 64L325.5 64C342.5 64 358.8 70.7 370.8 82.7L493.3 205.3C505.3 217.3 512 233.6 512 250.6L512 512C512 547.3 483.3 576 448 576L192 576C156.7 576 128 547.3 128 512L128 128z"/></svg>
        </span>
        その他
      </div>
    </div>
    <div class="panel" id="panel">近日行われる予定はありません。</div>
  </div>
  <script>
    // タブ切り替え用JS
    const tabs = document.querySelectorAll('#tabs .tab');
    const panel = document.getElementById('panel');
    const data = {
      info: '近日行われる予定はありません。',
      recent: '最近の更新情報をここへ表示します。',
      maint: '🛠 定期メンテナンス情報をここに表示します。',
      other: '💡 その他のお知らせをここに表示します。'
    };
    tabs.forEach(t => t.addEventListener('click', () => {
      tabs.forEach(x => x.classList.remove('active'));
      t.classList.add('active');
      panel.textContent = data[t.dataset.key];
    }));
  </script>
</body>
</html>