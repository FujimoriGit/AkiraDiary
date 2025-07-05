# E2E テスト

Maestro を使って E2E テストを実装します。
https://qiita.com/stotic-dev/items/90dc99e440a7378cdf2d

## Maestro の導入方法

### 前提

- Xcode14 以上
- macos
- homebrew をインストールしていること

以下コマンドをリポジトリのルートディレクトリで実行して、maestro をインストールします。

```console
bash scripts/create_e2e_env.sh
```

## E2E テストの実行方法

`E2E/`に移動して以下コマンドで、E2E テストを実行できます。

```console
maestro test main.yml
```
