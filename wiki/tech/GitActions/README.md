### GitHub Actions

## GitHub Actionsとは
定義したジョブを任意で設定した起動契機で順次実行してくれるCI/CDツール。
実行環境はGitHubが提供してくれるクラウドになり、その中でもOSなどは自分で設定できる。
詳しくは[こちら](https://www.kagoya.jp/howto/it-glossary/develop/githubactions/)を参照

## GitActionsの導入方法
以下ディレクトリに実行するジョブを実行するymlファイルを配置する
- `.github/workflows/`

## ジョブ実行を定義するymlファイルの記述方法
ざっくりと以下構成で記述する

- `name`: ジョブの名前
- `on`: ジョブ起動のトリガーを指定する
    - `push`: プッシュを検知したらジョブを起動する
    - `pull_request`: プルリクエストを検知したらジョブを起動する
    ※ブランチのフィルターを行うことも可能
- `env`: ジョブ単位で使用する環境変数の定義
- `jobs`: ジョブの実行内容を定義する
    - `job-name(任意の名前)`: ジョブの単位毎に定義する
        - `runs-on`: ジョブを実行する環境を指定する(macosは[こちら](https://github.com/actions/runner-images/tree/main/images/macos))
        - [`steps`](https://docs.github.com/ja/actions/using-workflows/workflow-syntax-for-github-actions#jobsjob_idsteps): ジョブの一連のタスク
            - [`uses`](https://docs.github.com/ja/actions/using-workflows/workflow-syntax-for-github-actions#jobsjob_idstepsuses): 公開されているアクションを指定して実行することができる。(再利用可能な関数のようなイメージ) 
            - `name`: 一覧のジョブで表示されるステップの名前。1タスクのラベル的な
            - [`run`](https://docs.github.com/ja/actions/using-workflows/workflow-syntax-for-github-actions#jobsjob_idstepsrun): コマンドを実行できる


## 定義ジョブ一覧
 - [ビルド、テストジョブ](https://github.com/FujimoriGit/AkiraDiary/tree/BR_topic/1.0/%2314_ci_cd_create/wiki/tech/GitActions/Build_Test)


