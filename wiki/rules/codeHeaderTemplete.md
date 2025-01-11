# ソースファイルのヘッダーテンプレートについて

### テンプレート

ソースファイルのヘッダーは下記の通り

```
//
//  <プロダクト名>
//
//  <ファイル名>.swift
//
//  Created by <実装者名> on 2024/11/23
//  Copyright © Macho All rights reserved.
//
```

### テンプレート定義ファイル

上記テンプレートは下記テンプレートファイルを読み込ませて実現している

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>FILEHEADER</key>
	<string>
//  ___PRODUCTNAME___
//
//  ___FILENAME___
//
//  Created by ___USER___ on ___DATE___
//  Copyright © Macho All rights reserved.
//</string>
</dict>
</plist>
```

ファイルの置き場所

> Macho/Macho.xcworkspace/xcshareddata/IDETemplateMacros.plist

`___FILENAME___`など`___`で挟まれた値はテンプレート定義内で使用できるマクロであり、さまざまな種類がある。

詳しくは下記公式のドキュメント参照
https://help.apple.com/xcode/mac/9.0/index.html?localePath=en.lproj#/dev7fe737ce0

### 開発者が必要な作業

上記テンプレートの内`___USER___`はカスタム変数であり、別途開発者が定義する必要がある。

下記ファイルを作成し、`[開発者の名前]`の部分を任意の名前に変更することで、上記テンプレートの`___USER___`の部分が設定した名前で表示することができる。

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>USER</key>
	<string>[開発者の名前]</string>
</dict>
</plist>
```

> Macho/Macho.xcworkspace/xcuserdata/<開発者のユーザ名>.xcuserdatad/IDETemplateMacros.plist

## 参考

- https://dev.classmethod.jp/articles/create_custom_xcode_header_comment_template_for_ios/
- https://ulog.sugiy.com/xcode-header-macro-setting/
