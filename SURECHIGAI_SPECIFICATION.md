# Surechigai アプリ仕様書

## 概要

SurechigaiはBLE（Bluetooth Low Energy）を使用して、近くを歩いている人とすれ違い時にプロフィール情報を交換するiOSアプリです。同日に同じユーザーとすれ違っても重複してカウントされない仕様になっています。

---

## データモデル

### UserProfile

ユーザーのプロフィール情報を表す構造体。

```swift
struct UserProfile: Codable, Equatable {
    var userID: UUID              // ユーザー一意識別子（UUID）
    var nickname: String          // ニックネーム
    var greetingMessage: String   // 挨拶メッセージ
    var foxAvatar: FoxAvatarConfig // アバター設定
    var prefecture: String        // 都道府県
}
```

#### プロパティ詳細

| プロパティ | 型 | 説明 |
|-----------|-----|------|
| userID | UUID | ユーザーの一意識別子。プロフィール登録時に一度だけ生成される |
| nickname | String | ユーザーのニックネーム（最大12文字） |
| greetingMessage | String | 挨拶メッセージ（最大32文字） |
| foxAvatar | FoxAvatarConfig | アバターのカスタマイズ設定 |
| prefecture | String | 都道府県情報（デフォルト: "未設定"） |

#### 計算プロパティ

- `trimmedNickname`: ニックネームの空白を除去した文字列
- `isValid`: ニックネームが空でないかどうか

---

### EncounteredProfile

すれちがったユーザーのプロフィール情報を表す構造体。

```swift
struct EncounteredProfile: Codable, Identifiable, Equatable {
    let id: UUID                  // すれちがいレコードの一意識別子
    var profile: UserProfile      // すれちがったユーザーのプロフィール
    let encounteredAt: Date       // 初回遭遇日時
    var encounterCount: Int       // 遭遇回数
    var isConfirmed: Bool         // 確認済みフラグ
    var lastEncounteredAt: Date   // 最終遭遇日時
}
```

#### プロパティ詳細

| プロパティ | 型 | 説明 |
|-----------|-----|------|
| id | UUID | すれちがいレコードの一意識別子 |
| profile | UserProfile | すれちがったユーザーのプロフィール情報 |
| encounteredAt | Date | 初めてすれ違った日時 |
| encounterCount | Int | 累計遭遇回数（同日は1回のみカウント） |
| isConfirmed | Bool | ユーザーがプロフィールを確認したかどうか |
| lastEncounteredAt: Date | 最後にすれ違った日時 |

#### 計算プロパティ

- `formattedDate`: 日時を日本語フォーマットで表示
- `relativeTime`: 相対時間（たった今、〇分前、〇時間前、〇日前）
- `encounterCountText`: 遭遇回数をテキストで表示（"〇回目"）

#### メソッド

- `incrementEncounterCount()`: 遭遇回数を増やし、最終遭遇日時を更新
- `confirm()`: プロフィールを確認済みにする

---

## データベーススキーマ

### user_profile テーブル

ユーザーのプロフィール情報を保存するテーブル。

| カラム名 | データ型 | 説明 |
|---------|---------|------|
| userID | TEXT (UUID) | 主キー。ユーザーの一意識別子 |
| nickname | TEXT | ニックネーム |
| greetingMessage | TEXT | 挨拶メッセージ |
| prefecture | TEXT | 都道府県 |
| foxAvatar | BLOB | アバター設定（JSONエンコードされたData） |

### encountered_profile テーブル

すれちがったユーザーの情報を保存するテーブル。

| カラム名 | データ型 | 説明 |
|---------|---------|------|
| id | TEXT (UUID) | 主キー。すれちがいレコードの一意識別子 |
| encounteredAt | REAL | 初回遭遇日時（Unixタイムスタンプ） |
| lastEncounteredAt | REAL | 最終遭遇日時（Unixタイムスタンプ） |
| encounterCount | INTEGER | 累計遭遇回数 |
| isConfirmed | INTEGER | 確認済みフラグ（0: 未確認, 1: 確認済み） |
| profileJSON | TEXT | ユーザープロフィール（JSONエンコードされた文字列） |

**注意**: peerIDとremoteUserIDは完全に廃止され、userID（UUID）のみで識別を行います。

---

## BLE通信フロー

### 1. アドバタイズ開始

```
HomeView.onAppear
→ bleService.startAdvertising(with: profileStore.profile)
→ BLEService.startAdvertising()
→ currentProfile = profile
→ bleManager.setSendingEnabled(true)
```

### 2. スキャン開始

```
HomeView.onAppear
→ bleService.startScanning()
→ BLEManager.startScanning()
```

### 3. プロフィール送信（Central接続時）

```
BLEManager.onCentralSubscribed
→ BLEService.sendProfile()
→ UserProfileをJSONエンコード
→ bleManager.sendData(jsonString)
```

### 4. プロフィール受信

```
BLEManager.dataReceivedCallback
→ BLEService.handleReceivedData(data)
→ JSONデコードしてUserProfileに変換
```

---

## 通知フロー

### 1. 同日チェック（通知発行前）

```
BLEService.handleReceivedData()
→ encounteredStore.shouldAddProfile(profile)
→ 既存のuserIDで検索
→ 最終遭遇日と今日を比較
→ 同日の場合はreturn（通知なし）
→ 異日の場合のみ続行
```

### 2. NotificationCenter通知発行

```
BLEService.handleReceivedData()
→ NotificationCenter.default.post(
    name: .didEncounterProfile,
    userInfo: ["profile": profile]
)
```

### 3. ローカル通知発行

```
BLEService.handleReceivedData()
→ sendLocalNotification(profile)
→ タイトル: "すれちがった！"
→ 本文: "{nickname}さんとすれ違いました"
→ サウンド: デフォルト
→ カテゴリ: "ENCOUNTER"
```

### 4. HomeViewでの受信

```
HomeView.onReceive(.didEncounterProfile)
→ encounteredStore.addProfile(profile)
```

---

## 同日チェックフロー

### EncounteredProfilesStore.shouldAddProfile()

```swift
func shouldAddProfile(_ profile: UserProfile) -> Bool {
    if let existingProfile = encounteredProfiles.first(where: { 
        $0.profile.userID == profile.userID 
    }) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let lastEncounteredDay = calendar.startOfDay(for: existingProfile.lastEncounteredAt)

        // 同日にすれ違っている場合は追加しない
        return !calendar.isDate(today, inSameDayAs: lastEncounteredDay)
    }
    return true
}
```

### EncounteredProfilesStore.addProfile()

```swift
func addProfile(_ profile: UserProfile) {
    if let existingIndex = encounteredProfiles.firstIndex(where: { 
        $0.profile.userID == profile.userID 
    }) {
        let existingProfile = encounteredProfiles[existingIndex]
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let lastEncounteredDay = calendar.startOfDay(for: existingProfile.lastEncounteredAt)

        // 同日にすれ違っている場合は何もしない
        if calendar.isDate(today, inSameDayAs: lastEncounteredDay) {
            return
        }

        // 異なる日の場合のみカウントを増やす
        encounteredProfiles[existingIndex].incrementEncounterCount()
        encounteredProfiles[existingIndex].profile = profile
        encounteredProfiles.sort { $0.lastEncounteredAt > $1.lastEncounteredAt }
    } else {
        let encountered = EncounteredProfile(profile: profile)
        encounteredProfiles.insert(encountered, at: 0)
    }

    if encounteredProfiles.count > maxProfiles {
        encounteredProfiles = Array(encounteredProfiles.prefix(maxProfiles))
    }

    save()
}
```

---

## 完全なフロー図

```
1. アドバタイズ受信
   ├─ BLEスキャン開始
   ├─ BLEアドバタイズ開始
   ├─ Central接続 → プロフィール送信
   └─ データ受信 → UserProfileデコード

2. 同日チェック（通知発行前）
   ├─ userIDで既存プロフィール検索
   ├─ 最終遭遇日と今日を比較
   ├─ 同日 → return（通知なし、何もしない）
   └─ 異日 → 通知発行へ進む

3. 通知発行
   ├─ NotificationCenter通知発行
   ├─ ローカル通知発行（"すれちがった！"）
   └─ HomeViewで通知受信

4. プロフィール追加
   ├─ EncounteredProfilesStore.addProfile()
   ├─ 既存ユーザーの場合
   │  ├─ 同日チェック（二重チェック）
   │  ├─ 同日 → return
   │  └─ 異日 → カウント増加＆更新
   └─ 新規ユーザーの場合
      └─ リストに追加

5. データ保存
   ├─ SQLiteまたはUserDefaultsに保存
   └─ 最大100件まで保持
```

---

## リポジトリパターン

### ProfileRepositoryProtocol

ユーザープロフィールの永続化を担当するプロトコル。

```swift
protocol ProfileRepositoryProtocol {
    func save(_ profile: UserProfile) throws
    func load() throws -> UserProfile?
    func update(_ profile: UserProfile) throws
    func delete(userID: UUID) throws
    func exists(userID: UUID) throws -> Bool
}
```

### EncounteredProfileRepositoryProtocol

すれちがいプロフィールの永続化を担当するプロトコル。

```swift
protocol EncounteredProfileRepositoryProtocol {
    func save(_ profile: EncounteredProfile) throws
    func loadAll() throws -> [EncounteredProfile]
    func load(byID id: String) throws -> EncounteredProfile?
    func update(_ profile: EncounteredProfile) throws
    func delete(id: String) throws
    func deleteAll() throws
    func count() throws -> Int
}
```

### 実装クラス

#### SQLiteProfileRepository
- ユーザープロフィールをSQLiteに保存
- `ProfileStore`で使用中

#### UserDefaultsProfileRepository
- ユーザープロフィールをUserDefaultsに保存
- 旧実装、マイグレーション用に保持

#### SQLiteEncounteredProfileRepository
- すれちがいプロフィールをSQLiteに保存
- 現在は使用されていない（将来のマイグレーション用）

#### UserDefaultsEncounteredProfileRepository
- すれちがいプロフィールをUserDefaultsに保存
- `EncounteredProfilesStore`で使用中

---

## 主要なサービス

### BLEService

BLE通信を管理するサービス。

#### プロパティ

- `isScanning`: スキャン中かどうか
- `isAdvertising`: アドバタイズ中かどうか
- `isConnected`: 接続中かどうか
- `statusMessage`: ステータスメッセージ
- `receivedData`: 受信したデータ

#### メソッド

- `startScanning()`: スキャン開始
- `stopScanning()`: スキャン停止
- `startAdvertising(with:)`: アドバタイズ開始
- `stopAdvertising()`: アドバタイズ停止
- `setEncounteredStore(_:)`: EncounteredProfilesStoreを設定

### EncounteredProfilesStore

すれちがいプロフィールを管理するストア。

#### プロパティ

- `encounteredProfiles`: すれちがいプロフィールのリスト

#### メソッド

- `shouldAddProfile(_:)`: 同日チェックのみ行う
- `addProfile(_:)`: プロフィールを追加
- `confirmProfile(at:)`: プロフィールを確認済みにする
- `removeProfile(at:)`: プロフィールを削除
- `removeAll()`: 全プロフィールを削除

#### 計算プロパティ

- `totalCount`: 総すれちがい人数
- `todayCount`: 今日のすれちがい人数
- `dailyStats`: 日別統計情報

### ProfileStore

ユーザープロフィールを管理するストア。

#### プロパティ

- `profile`: 現在のユーザープロフィール

#### メソッド

- `save(_:)`: プロフィールを保存
- `hasProfile`: プロフィールが存在するかどうか

---

## 重要な仕様

### 同日チェックの二重実装

1. **BLEService.handleReceivedData()**: 通知発行前のチェック
   - 同日の場合は通知を発行しない
   - ユーザー体験を向上させるため

2. **EncounteredProfilesStore.addProfile()**: データ追加時のチェック
   - 同日の場合はデータを追加しない
   - データ整合性を保つため

### peerIDの完全廃止

- 以前はpeerID（String）で識別していたが、現在はuserID（UUID）のみを使用
- データベース、モデル、リポジトリ、BLE通信からpeerIDを完全に削除
- 既存のpeerIDベースのデータはアプリ起動時にクリアされる

### 最大保持数

- すれちがいプロフィールは最大100件まで保持
- 超過した場合は古いものから削除される

### UUIDの生成タイミング

- ユーザーID（UUID）はプロフィール登録時に一度だけ生成される
- その後は変更されない

---

## ファイル構成

```
Surechigai/
├── Models/
│   ├── UserProfile.swift           # ユーザープロフィールモデル
│   ├── EncounteredProfile.swift     # すれちがいプロフィールモデル
│   └── FoxAvatarConfig.swift        # アバター設定モデル
├── Services/
│   ├── BLEService.swift             # BLE通信サービス
│   ├── EncounteredProfilesStore.swift # すれちがいプロフィールストアア
│   └── ProfileStore.swift           # ユーザープロフィールストア
├── Repositories/
│   ├── ProfileRepositoryProtocol.swift      # プロフィールリポジトリプロトコル
│   ├── EncounteredProfileRepositoryProtocol.swift # すれちがいリポジトリプロトコル
│   ├── SQLiteProfileRepository.swift      # SQLiteプロフィールリポジトリ
│   ├── UserDefaultsProfileRepository.swift # UserDefaultsプロフィールリポジトリ
│   ├── SQLiteEncounteredProfileRepository.swift # SQLiteすれちがいリポジトリ
│   └── UserDefaultsEncounteredProfileRepository.swift # UserDefaultsすれちがいリポジトリ
├── Database/
│   └── DatabaseManager.swift       # データベース管理
└── Views/
    ├── HomeView.swift              # ホーム画面
    └── ProfileRegistrationView.swift # プロフィール登録画面
```

---

## 技術スタック

- **言語**: Swift
- **フレームワーク**: SwiftUI
- **BLE**: CoreBluetooth
- **データベース**: SQLite3
- **通知**: UserNotifications
- **アーキテクチャ**: MVVM + Repository Pattern

---

## 変更履歴

### 2026-07-10
- peerIDを完全に廃止し、userID（UUID）のみで識別するように変更
- 同日チェックを通知発行前に移動
- EncounteredProfilesStoreにshouldAddProfile()メソッドを追加
- BLEServiceにEncounteredProfilesStoreの参照を追加
- 既存のpeerIDベースのデータをアプリ起動時にクリアするように変更

### 以前の変更
- Repository Patternの導入
- SQLiteによるデータ永続化の実装
- BLE通信の実装
