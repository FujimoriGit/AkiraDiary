#!/bin/zsh

set -e  # エラー発生時に即時終了

# Dangerのスクリプトディレクトリへ移動
cd ./Danger

echo "Danger のセットアップを開始します..."

# npm による danger のインストール
echo "npm で danger をインストール中..."
npm install -g danger

# swift build の実行 (標準出力を抑え、エラーのみ表示)
echo "Swift パッケージをビルド中..."
swift build > /dev/null | tee build_error.log
if [ -s build_error.log ]; then
    echo "ビルドに失敗しました。エラーメッセージを表示します:"
    cat build_error.log
    exit 1
fi
rm build_error.log

# danger-swift の実行 (標準出力を抑え、エラーのみ表示)
echo "Danger-Swift を実行中..."
swift run danger-swift ci --cwd ../ --base BR_develop-1.0 > /dev/null | tee danger_error.log
if [ -s danger_error.log ]; then
    echo "Danger-Swift の実行に失敗しました。エラーメッセージを表示します:"
    cat danger_error.log
    exit 1
fi
rm danger_error.log

echo "Danger の処理が完了しました！"
