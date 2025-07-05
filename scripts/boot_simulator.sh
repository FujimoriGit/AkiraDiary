#!/bin/bash

# 使用例: ./boot_simulator.sh "iPhone 15 Pro" "iOS 17.5"
DEVICE_NAME="$1"
IOS_VERSION="$2"

if [ -z "$DEVICE_NAME" ] || [ -z "$IOS_VERSION" ]; then
  echo "Usage: $0 \"<Device Name>\" \"<iOS Version>\""
  exit 1
fi

# フラグ用変数
FOUND_SECTION=0
UDID=""

# 1行ずつ読み取り
while IFS= read -r line; do
  # セクション（-- iOS XX --）の検出
  if echo "$line" | grep -q -- "-- $IOS_VERSION --"; then
    FOUND_SECTION=1
    continue
  fi

  # 他のバージョンのセクションに入ったら終了
  if echo "$line" | grep -q -- "^-- iOS " && ! echo "$line" | grep -q -- "$IOS_VERSION"; then
    if [ "$FOUND_SECTION" -eq 1 ]; then
      break
    fi
  fi

  # セクション内でデバイス名を探す
  if [ "$FOUND_SECTION" -eq 1 ]; then
    if echo "$line" | grep -q "$DEVICE_NAME"; then
      UDID=$(echo "$line" | grep -oE '[A-F0-9\-]{36}')
      break
    fi
  fi
done < <(xcrun simctl list devices available)

# UDIDが見つかったかチェック
if [ -z "$UDID" ]; then
  echo "No matching device found for \"$DEVICE_NAME\" on $IOS_VERSION"
  exit 1
fi

echo "Found UDID: $UDID"

# 起動
xcrun simctl boot "$UDID"

echo "Simulator booted successfully."
