<?php
// functions.php

/**
 * 検索実行（条件のみ保存）
 */
function execute_search($dbh, $user_id, $conditions) {
    // セッションに条件のみ保存
    $_SESSION['search_conditions'] = $conditions;
    $_SESSION['search_user_id'] = $user_id;
    
    // 件数取得
    $count_sql = build_count_query($conditions);
    $count = $dbh->query($count_sql)->fetch()[0];
    
    $_SESSION['search_count'] = $count;
    $_SESSION['search_page'] = 1;
    
    return [
        'success' => true,
        'count' => $count,
        'message' => "{$count}件の結果"
    ];
}

/**
 * 結果取得（ページネーション対応）
 */
function fetch_search_results($dbh, $page = 1) {
    $conditions = $_SESSION['search_conditions'] ?? [];
    $limit = 50;
    $offset = ($page - 1) * $limit;
    
    $sql = build_query($conditions) . " LIMIT :limit OFFSET :offset";
    $stmt = $dbh->prepare($sql);
    $stmt->bindValue(':limit', $limit, PDO::PARAM_INT);
    $stmt->bindValue(':offset', $offset, PDO::PARAM_INT);
    $stmt->execute(prepare_params($conditions));
    
    $_SESSION['search_page'] = $page;
    
    return $stmt->fetchAll(PDO::FETCH_ASSOC);
}

/**
 * ページネーション情報
 */
function get_pagination($page = 1) {
    $total = $_SESSION['search_count'] ?? 0;
    $per_page = 50;
    $total_pages = ceil($total / $per_page);
    
    return [
        'current_page' => $page,
        'total_pages' => $total_pages,
        'total_records' => $total,
        'has_prev' => $page > 1,
        'has_next' => $page < $total_pages
    ];
}

// HTML 側
?>
<p>検索結果: <?php echo $_SESSION['search_count']; ?> 件</p>

<table>
    <?php foreach (fetch_search_results($dbh, $_GET['page'] ?? 1) as $row): ?>
    <tr>
        <td><?php echo htmlspecialchars($row['hos_cd']); ?></td>
        <td><?php echo htmlspecialchars($row['hos_name']); ?></td>
    </tr>
    <?php endforeach; ?>
</table>

<?php
$pagination = get_pagination($_GET['page'] ?? 1);
if ($pagination['has_prev']): ?>
    <a href="?page=<?php echo $pagination['current_page'] - 1; ?>">前へ</a>
<?php endif; ?>

ページ <?php echo $pagination['current_page']; ?>/<?php echo $pagination['total_pages']; ?>

<?php if ($pagination['has_next']): ?>
    <a href="?page=<?php echo $pagination['current_page'] + 1; ?>">次へ</a>
<?php endif; ?>