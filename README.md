# Surechigai（すれちがい）

任天堂のすれ違い通信をイメージした iOS アプリです。

## 現在の実装

- **ホーム画面** (`HomeView`)
  - 画面上部に「今日の歩数」を Core Motion で計測・表示
  - 1,000 歩ごとの進捗バー（将来のアイテム報酬用）
- **プロフィール**
  - ニックネーム・ひとこと・二足歩行デフォルメ狐アイコン（毛色・顔パーツ・アクセサリー）の編集
  - 端末に保存（すれ違い通信で共有する土台）
  - 中央にレーダー＋波紋アニメーションの「すれ違い通信中…」UI
  - ストリートパス風のカラフルなグラデーション背景

## 開発環境

- Xcode 16.4+
- iOS 18.0+
- SwiftUI

## 開き方

1. `Surechigai.xcodeproj` を Xcode で開く
2. ターゲット **Surechigai** を選択
3. 実機またはシミュレータで Run（⌘R）

## プロジェクト構成

```
Surechigai/
├── SurechigaiApp.swift
├── Views/
│   └── HomeView.swift
├── Components/
│   ├── PassingRadarView.swift
│   └── StepCounterHeaderView.swift
└── Theme/
    └── NintendoTheme.swift
```

## 今後の予定

- すれ違い通信（Bluetooth / Multipeer 等）でのプロフィール交換
- 1,000 歩達成時のアイテム付与（ゲーム機能）
