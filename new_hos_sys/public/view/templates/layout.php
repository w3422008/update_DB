<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    
    <!-- 動的タイトル -->
    <title><?php echo isset($pageTitle) ? $pageTitle . ' - ' : ''; ?>医療機関システム</title>
    
    <!-- 共通メタタグ -->
    <meta name="description" content="<?php echo isset($pageDescription) ? $pageDescription : '医療機関情報管理システム'; ?>">
    <meta name="robots" content="noindex, nofollow">
    
    <!-- 共通CSS -->
    <link rel="stylesheet" href="/new_hos_sys/assets/css/common.css">
    <link rel="stylesheet" href="/new_hos_sys/assets/css/components.css">
    
    <!-- ページ固有CSS -->
    <?php if (isset($additionalCSS)): ?>
        <?php foreach ($additionalCSS as $css): ?>
            <link rel="stylesheet" href="<?php echo $css; ?>">
        <?php endforeach; ?>
    <?php endif; ?>
    
    <!-- フォントやアイコン -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
</head>
<body class="<?php echo isset($bodyClass) ? $bodyClass : 'default-layout'; ?>">
    <!-- ヘッダー -->
    <header id="main-header">
        <?php include_once __DIR__ . '/components/header.php'; ?>
    </header>
    
    <!-- ナビゲーション -->
    <?php if (!isset($hideNavigation) || !$hideNavigation): ?>
    <nav id="main-navigation">
        <?php include_once __DIR__ . '/components/navigation.php'; ?>
    </nav>
    <?php endif; ?>
    
    <!-- メインコンテンツエリア -->
    <main id="main-content" class="<?php echo isset($contentClass) ? $contentClass : 'container'; ?>">
        <!-- ページ固有のコンテンツ -->
        <?php echo $content; ?>
    </main>
    
    <!-- フッター -->
    <footer id="main-footer">
        <?php include_once __DIR__ . '/components/footer.php'; ?>
    </footer>
    
    <!-- 共通JavaScript -->
    <script src="/new_hos_sys/assets/js/common.js"></script>
    <script src="/new_hos_sys/assets/js/components.js"></script>
    
    <!-- ページ固有JavaScript -->
    <?php if (isset($additionalJS)): ?>
        <?php foreach ($additionalJS as $js): ?>
            <script src="<?php echo $js; ?>"></script>
        <?php endforeach; ?>
    <?php endif; ?>
    
    <!-- インラインJavaScript -->
    <?php if (isset($inlineJS)): ?>
        <script>
            <?php echo $inlineJS; ?>
        </script>
    <?php endif; ?>
</body>
</html>