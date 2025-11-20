# 環境に合わせて変更が必要な点

### 1. `public/router.php`
``` php
// ベースパスを定義
$basePath = '/{ }/hospital_system/public';
```

※｛ ｝内へ、あてはまるパスを入れることで動作するようになる
→ hospital_systemフォルダが「rebuild/edit」の中に入っている場合は以下のように記述する
``` php
// ベースパスを定義
$basePath = '/rebuild/edit/hospital_system/public';
```
---
### 2. 



