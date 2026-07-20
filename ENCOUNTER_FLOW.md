# すれちがいフロー仕様書

## 現在のフロー

### 1. BLE通信フロー
```
BLEManager (CoreBluetooth)
  ↓ データ受信
BLEService.handleReceivedData()
  ↓ 同日チェック
NotificationCenter.post(.didEncounterProfile)
  ↓
HomeView.onReceive()
  ↓
EncounteredProfilesStore.addProfile()
  ↓
SQLiteEncounteredProfileRepository.save()
```

### 2. 通知フロー
```
BLEService.handleReceivedData()
  ↓
sendLocalNotification()
  ↓
UNUserNotificationCenter.add()
```

### 3. UI表示フロー
```
EncounteredListView表示
  ↓
ProfileCardアニメーション
  ↓
カード表示
```

---

## 将来の3Dアバター実装に向けた改善案

### 1. すれちがいイベントの構造化
現在はNotificationCenterで直接通知しているが、以下の構造化を提案：

```swift
// すれちがいイベントモデル
struct EncounterEvent {
    let id: UUID
    let profile: UserProfile
    let encounteredAt: Date
    let encounterType: EncounterType
}

enum EncounterType {
    case firstEncounter
    case repeatEncounter
    case specialEncounter
}

// イベントマネージャー
class EncounterEventManager {
    func onEncounter(_ event: EncounterEvent)
    func triggerAnimation(for event: EncounterEvent)
    func playSound(for event: EncounterEvent)
}
```

### 2. アニメーション演出フック
現在のアニメーションはViewに埋め込まれているが、分離を提案：

```swift
// アニメーションマネージャー
class EncounterAnimationManager {
    func playEncounterAnimation(type: EncounterType)
    func playCardAnimation(type: CardAnimationType)
}

// 3Dアバター表示用プレースホルダー
struct Avatar3DView: View {
    let profile: UserProfile
    var body: some View {
        // 現在: FoxAvatarView
        // 将来: 3Dアバター
        FoxAvatarView(foxAvatar: profile.foxAvatar)
    }
}
```

### 3. すれちがいシーンの分離
将来の3Dアバターすれちがいアニメーション用：

```swift
// すれちがいシーンビュー
struct EncounterSceneView: View {
    let event: EncounterEvent
    
    var body: some View {
        ZStack {
            // 3Dアバターすれちがいアニメーション
            Avatar3DSceneView(profile: event.profile)
            
            // 演出エフェクト
            EncounterEffectsView(type: event.encounterType)
        }
    }
}
```

### 4. データフローの整理
現在のフローをより明確にする：

```
BLE受信
  ↓
EncounterEvent生成
  ↓
EncounterEventManager.onEncounter()
  ├─ 同日チェック
  ├─ データ保存
  ├─ アニメーション演出
  ├─ 音効果
  └─ 通知発行
  ↓
UI更新
```

---

## 実装優先度

### 優先度：高（現在実装可能）
1. EncounterEventモデルの導入
2. EncounterEventManagerの導入
3. アニメーション演出の分離

### 優先度：中（3Dアバター実装時）
1. Avatar3DViewの実装
2. EncounterSceneViewの実装
3. 3Dアバターアニメーションの実装

### 優先度：低（将来）
1. 特殊すれちがいイベント
2. ゲーム要素との連携
3. 実績システム

---

## 現在のアーキテクチャ評価

### 良い点
- Repository Patternによるデータ分離
- SQLiteによる永続化
- 同日チェックの実装
- アニメーションシステムの導入

### 改善点
- すれちがいイベントが構造化されていない
- アニメーションがViewに埋め込まれている
- 3Dアバター用のプレースホルダーがない
- 演出フックが不足している

---

## 次のステップ

1. EncounterEventモデルを作成
2. EncounterEventManagerを実装
3. アニメーション演出を分離
4. Avatar3DViewプレースホルダーを作成
