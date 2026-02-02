/*

login_auth.js
ログイン画面のJS処理

- フォーム送信をJSでハンドリング
- API（lib/login.php）にPOSTし認証
- 結果に応じて画面遷移・エラー表示

*/

// リンクURL管理用モジュールをインポート
import { LOGIN_API_URL } from "../links/links.js";

// DOM読み込み完了後に処理開始
document.addEventListener("DOMContentLoaded", function () {
  // ログインフォーム取得
  const form = document.querySelector('form[action="./login.php"]');
  // エラー表示領域取得
  const errDiv = document.querySelector(".err");

  if (form) {
    // ユーザー名・パスワード送信時の処理
    form.addEventListener("submit", async function (e) {
      e.preventDefault();

      // エラー変数クリア
      if (errDiv) errDiv.textContent = "";

      // フォームよりデータ取得
      const userId = form.user_id.value.trim();
      const password = form.password.value;

      //   入力チェック
      // APIへPOSTリクエスト送信
      try {
        /*
         * fetchでAPIにPOST
         * 絶対パスを使用することで、ブラウザのURL変化に影響されない
         */
        const res = await fetch(LOGIN_API_URL, {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({ user_id: userId, password: password }),
        });
        const rawText = await res.text();
        console.log("APIレスポンス:", rawText);
        let data;
        try {
          data = JSON.parse(rawText);
        } catch (e) {
          if (errDiv)
            errDiv.textContent = "APIレスポンスが不正です: " + rawText;
          return;
        }
        if (data.success) {
          // ログイン後のページへ遷移
          window.location.href = "router.php/home";
        } else {
          if (errDiv)
            errDiv.textContent = data.message || "ログインに失敗しました。";
        }
      } catch (err) {
        if (errDiv) errDiv.textContent = "通信エラーが発生しました。";
      }
    });
  }
});
