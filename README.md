# 静時ねこたんの日記帳🐾 (Swift版)

にゃんこみたいに優しいiOS/iPad OS/macOS日記アプリで、毎日の思い出をかわいく記録できるにゃ～♡  
SwiftUIで作られたキラキラなインターフェースで、あなたのお気持ちをそっと保管するよ～✨

## 国際化だにゃ～🌍

世界中の猫ちゃんと仲良くするために、多言語対応をがんばってるにゃ！  
(ごめんにゃ～、まだ準備中だよ～ 🚧)

<!-- 
- 英語だにゃ: [English](README-en.md)  
- 韓国語ニャン: [한국어](README-ko.md)  
- 中国語(簡体字)にゃん: [简体中文](README-zh.md)  
- 中国語(繁体字)にゃ～: [繁體中文](README-tw.md)
-->

## リソースのおうち🏠

使ってる素材は全部お家で管理してるにゃ：  

### フォントちゃん  
`fonts/` においるにゃ～  
- KleeOne-Regular.ttf - ふにゃふにゃ文字  

### Swiftパッケージ  
`Package.swift` でお昼寝中🐾  
- Swift 6.1以上 - 最新のにゃんこ言語✨  

## にゃんとこ自慢機能✨  

- 💕 触るだけでにゃんこハートがぷるん！直感的操作  
- 📝 カテゴリー分けでお気持ちスッキリ整理にゃん♪  
- 🏷️ タグ付け10個まで！思い出をパッと探せる🔖  
- 🔍 キーワードひとつで魔法みたいに検索～✨  
- 📤 CSV/JSONで思い出のお引っ越し可能にゃ📦  
- 📊 自動バックアップでぐっすり安心睡眠😴💤  
- 📱 iOS/iPad OS/macOS両方で肉球でらくらく操作～🐾  
- 🌙 ダークモード対応でお月様と一緒に✨  

## 必要なもの🍼  

- Xcode 15.0以上 (にゃんこ開発環境だにゃ)  
- iOS 15.0以上 / iPad OS 15.0以上 / macOS 12.0以上  
- Swift 6.1以上 (最新のにゃんこ言語)  

## はじめかた🐾  

まずはお家に迎える準備をしようにゃ！  

```bash
# お家に連れてくるにゃ～
git clone https://github.com/chronie-shizutoki/nekotan.git  
cd nekochan  

# Xcodeで開くにゃん
open NekoTan.xcodeproj
```

## お部屋の飾りつけ✨  

Xcodeでお好み設定にゃ～：  

- iOS Deployment Target: 15.0以上 🍎  
- iPad OS Deployment Target: 15.0以上 🍎  
- macOS Deployment Target: 12.0以上 💻  
- Swift Language Version: 6.1以上 🚀  

## 起動コマンド🐾  

Xcodeでお遊びモード：  
```bash
# シミュレーターで起動
Product > Run (⌘+R)  # わくわく開発モード💫  
```  

実機でお仕事：  
```bash
# デバイスにインストール
Product > Run on Device  # まじめにゃんモード👑  
```  

その他のお世話：  
- `Product > Clean Build Folder`：お掃除タイム🧹  
- `Product > Build`：元気にビルド！🔨  
- `Product > Test`：テストしてみるにゃ～🧪  

## 使いかた💖  

1. アプリを起動してにゃんこ画面をぽんぽん✨  
2. ぷくぷく「新規日記」ボタンをタッチ！  
3. タイトルとお気持ちをにゃんと入力📝  
4. カテゴリーとタグでおしゃれ整理🎀  
5. 「保存」でふわふわハートに保管💕  

## お家の中身🐾  

```
nekochan/
├── .github/                            # GitHubのお手紙箱✉️
│   └── workflows/                      # 自動お仕事マシン⚙️
├── Sources/                            # Swiftの心臓部❤️
│   ├── NekoTanLib/                     # メインライブラリ📚
│   │   ├── iOS/                        # iPhone/iPad用画面📱
│   │   ├── macOS/                      # Mac用画面💻
│   │   ├── Assets.xcassets/            # 絵とアイコン🎨
│   │   ├── NekoTanApp.swift            # アプリの入り口🚪
│   │   ├── NekoTan.entitlements        # 権限設定🔐
│   │   └── Info.plist                  # アプリ情報📋
│   └── main.swift                      # 起動の合図🚀
├── Views/                              # 画面デザイン🎭
├── App/                                # アプリ本体🏠
├── Models/                             # データの形📊
├── Services/                           # お世話係👩‍🍼
├── ViewModels/                         # 画面の頭脳🧠
├── fonts/                              # 文字の遊び場✏️
│   └── KleeOne-Regular.ttf             # ふにゃふにゃ文字🐾
├── NekoTan.xcodeproj/                  # Xcodeプロジェクト📁
├── Package.swift                       # Swiftパッケージ設定📦
├── APPLE_PLATFORMS.md                  # Appleプラットフォーム説明🍎
├── Architecture.md                     # 設計図📐
├── diaries.csv                         # 思い出宝石箱💎
├── LICENSE                             # お約束カード📜
└── .gitignore                          # 見せないリスト🙈
```

## 思い出のお守り💾  

- 毎日自動でバックアップされるにゃ～  
- iCloud同期でデバイス間お引っ越し可能✨  
- 環境設定で期間変更可能にゃん📅  

## 安全対策🔐  

- Appleのセキュリティガイドライン厳守🍎  
- データ暗号化で大切な思い出をガード🔒  
- 怪しい入力はシャットアウト！🚫  

## ライセンスについて📜  

AGPL-3.0 ライセンスだにゃ～  
フォントちゃんは SIL Open Font License 1.1 でお留守番  

## 開発者向け情報👩‍💻  

### アーキテクチャ
- **MVVM**: Model-View-ViewModelパターンで整理整頓✨
- **SwiftUI**: 最新の宣言的UIフレームワーク🎨
- **Combine**: リアクティブプログラミングでスムーズ動作🚀

### プラットフォーム対応
- **iOS**: iPhone/iPad両対応📱
- **macOS**: Mac用デスクトップアプリ💻
- **macCatalyst**: iPadアプリをMacで動かす🎪

### 最後ににゃ～💕  
いつもあなたの大切な思い出を、  
つぶらな瞳で見守ってるにゃん🐾  
素敵な毎日がたくさん記録できますように～✨  
SwiftUIの魔法で、もっと可愛く、もっと使いやすく！🌟  