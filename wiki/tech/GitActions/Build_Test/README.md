### ビルドとテストの自動化方法

Akira Diaryでは[checkBuild_Test_Swift.yml](.github/workflows/checkBuild_Test_Swift.yml)でビルドとテストのチェックをPushまたはPull Requestを作成したときに実行されるようにしている。

## ymlファイルの解説

```
# ジョブの名前を設定している
name: CheckBuild_Test_Swift

# 起動のトリガーを定義する
on:

  # `BR_develop`もしくは`BR_topic`が含まれるブランチがPushされた時に起動する
  # ただし`paths-ignore`で指定したファイルのみの更新時は起動しない
  push:
    branches: 
      - 'BR_develop**'
      - 'BR_topic/**'
    paths-ignore:
      - 'doc/*'
      - 'wiki/**'
      - README.md

  # `BR_develop`もしくは`BR_topic`が含まれるブランチがPull Request作成された時に起動する 
  # ただし`paths-ignore`で指定したファイルのみの更新時は起動しない     
  pull_request:
    branches: 
      - 'BR_develop**'
      - 'BR_topic/**'
    paths-ignore:
      - 'doc/*'
      - 'wiki/**'
      - README.md

# 後続のジョブで行うビルドで使用するXcodeを指定する
# GitHubが提供するmacos環境にはデフォルトでさまざまなバージョンのXcodeが存在するので
# プロジェクトで使用しているバージョンのXcodeを指定すると良い
env:
# チェックアウト
  DEVELOPER_DIR: /Applications/Xcode_15.0.app

# 実行するジョブを小要素に書く(複数書ける)
jobs:

　# 任意のジョブの名前を指定する
  build:

     # 実行環境はmacosに設定
    runs-on: macos-13

    # stepsの小要素に順次事項するアクションを書いていく
    steps:

    # チェックアウト(リポジトリからソースコードを取得)
    - uses: actions/checkout@v3

    # Xcodeの一覧出力
    - name: Show Xcode list
      run: ls /Applications | grep 'Xcode'

    # Xcodeのバージョン出力
    - name: Show Xcode version
      run: xcodebuild -version

    # Rudy製ライブラリのキャッシュ
    - name: Cache Gems
      uses: actions/cache@v2
      with:
        path: vendor/bundle
        key: ${{ runner.os }}-gems-${{ hashFiles('**/Gemfile.lock') }}
        restore-keys: |
          ${{ runner.os }}-gems-

    # Rudy製ライブラリのインストール
    - name: Install Bundled Gems
      run: |
        bundle config path vendor/bundle
        bundle install --jobs 4 --retry 3

    # ビルド
    - name: Xcode build
      working-directory: ./Macho
      run: set -o pipefail &&
        xcodebuild
        -sdk iphonesimulator
        -configuration Debug
        build |
        bundle exec xcpretty
    
    # 単体テストの実行
    - name: Xcode test
      working-directory: ./Macho
      run: set -o pipefail &&
        xcodebuild
        -sdk iphonesimulator
        -configuration Debug
        -destination id=838DD7EC-B8E9-43D5-A866-75BA36207564
        -scheme Macho
        -skip-testing MachoUITests
        clean test |
        bundle exec xcpretty

```

詳しくは[こちら](https://qiita.com/uhooi/items/29664ecf0254eb637951)の記事を参照する