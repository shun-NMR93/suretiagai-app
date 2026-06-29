import Foundation
import CoreBluetooth
import UserNotifications

@MainActor
final class BLEService: NSObject, ObservableObject {
    @Published private(set) var isScanning = false
    @Published private(set) var isAdvertising = false
    @Published private(set) var isConnected = false
    @Published private(set) var statusMessage: String = "初期化中..."
    @Published private(set) var receivedData: String = ""
    
    private let bleManager = BLEManager()
    private var currentProfile: UserProfile?
    
    override init() {
        super.init()
        
        // 通知の許可をリクエスト
        requestNotificationAuthorization()
        
        // BLEマネージャーのコールバックを設定
        bleManager.statusUpdateCallback = { [weak self] status in
            Task { @MainActor in
                self?.statusMessage = status
                self?.updateConnectionStatus(status)
            }
        }
        
        bleManager.dataReceivedCallback = { [weak self] data in
            Task { @MainActor in
                self?.receivedData = data
                self?.handleReceivedData(data)
            }
        }
        
        bleManager.onCentralSubscribed = { [weak self] in
            Task { @MainActor in
                self?.sendProfile()
            }
        }
    }
    
    private func requestNotificationAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("通知許可リクエストエラー: \(error.localizedDescription)")
            }
        }
        
        // 通知カテゴリを設定（バイブレーション有効）
        let encounterCategory = UNNotificationCategory(
            identifier: "ENCOUNTER",
            actions: [],
            intentIdentifiers: [],
            options: []
        )
        UNUserNotificationCenter.current().setNotificationCategories([encounterCategory])
    }
    
    func startScanning() {
        bleManager.startScanning()
        isScanning = true
    }
    
    func stopScanning() {
        bleManager.stopScanning()
        isScanning = false
    }
    
    func startAdvertising(with profile: UserProfile) {
        currentProfile = profile
        bleManager.setSendingEnabled(true)
        isAdvertising = true
    }
    
    func stopAdvertising() {
        bleManager.setSendingEnabled(false)
        isAdvertising = false
    }
    
    func sendData(_ dataString: String) {
        bleManager.sendData(dataString)
    }
    
    private func sendProfile() {
        guard let profile = currentProfile else { return }
        
        // プロフィールをJSONエンコード
        if let data = try? JSONEncoder().encode(profile),
           let jsonString = String(data: data, encoding: .utf8) {
            bleManager.sendData(jsonString)
        }
    }
    
    private func handleReceivedData(_ data: String) {
        // 受信したデータをプロフィール情報として解析
        if let data = data.data(using: .utf8),
           let profile = try? JSONDecoder().decode(UserProfile.self, from: data) {
            // 通知を送信
            NotificationCenter.default.post(
                name: .didEncounterProfile,
                object: nil,
                userInfo: ["profile": profile, "peerID": "BLE", "remoteUserID": profile.userID]
            )

            // ローカル通知を発行
            sendLocalNotification(profile: profile)
        }
    }
    
    private func sendLocalNotification(profile: UserProfile) {
        let content = UNMutableNotificationContent()
        content.title = "すれちがった！"
        content.body = "\(profile.trimmedNickname)さんとすれ違いました"
        content.sound = .default
        content.categoryIdentifier = "ENCOUNTER"
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("通知発行エラー: \(error.localizedDescription)")
            }
        }
    }
    
    private func updateConnectionStatus(_ status: String) {
        if status.contains("接続成功") {
            isConnected = true
        } else if status.contains("切断") {
            isConnected = false
        }
    }
}

extension Notification.Name {
    static let didEncounterProfile = Notification.Name("didEncounterProfile")
}
