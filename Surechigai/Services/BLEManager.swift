import Foundation
import CoreBluetooth

// BLE通信を管理するクラス
// Central（セントラル）とPeripheral（ペリフェラル）の両方の役割を果たす
class BLEManager: NSObject, CBCentralManagerDelegate, CBPeripheralManagerDelegate, CBPeripheralDelegate {
    
    // MARK: - プロパティ
    
    // Central Manager（BLEデバイスをスキャン・接続する側）
    private var centralManager: CBCentralManager?
    
    // Peripheral Manager（BLEデバイスとしてアドバタイズする側）
    private var peripheralManager: CBPeripheralManager?
    
    // 接続中のペリフェラル
    private var connectedPeripheral: CBPeripheral?
    
    // 発見したペリフェラルのリスト（参照を保持するため）
    private var discoveredPeripherals: [String: CBPeripheral] = [:]
    
    // 送信機能が有効かどうか（フォアグラウンドのみtrue）
    private var isSendingEnabled: Bool = false
    
    // UUIDの定義（独自のUUIDを使用して競合を回避）
    private let serviceUUID = CBUUID(string: "E621E1F8-C36C-495A-93FC-0C247A3E6E5F")
    private let characteristicUUID = CBUUID(string: "F821E1F8-C36C-495A-93FC-0C247A3E6E5F")
    
    // キャラクタリスティック（送信データ用）
    private var transferCharacteristic: CBMutableCharacteristic?
    
    // ステータス更新用のコールバック
    var statusUpdateCallback: ((String) -> Void)?
    
    // 受信データ用のコールバック
    var dataReceivedCallback: ((String) -> Void)?
    
    // セントラルがサブスクライブした時のコールバック
    var onCentralSubscribed: (() -> Void)?
    
    // MARK: - 初期化
    
    override init() {
        super.init()
        
        // Central Managerの初期化（受信機能用）
        // State Preservation and Restorationを有効にする
        let centralOptions: [String: Any] = [:]
        centralManager = CBCentralManager(delegate: self, queue: nil, options: centralOptions)
        
        // Peripheral Managerの初期化（送信機能用）
        // State Preservation and Restorationを有効にする
        let peripheralOptions: [String: Any] = [:]
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: peripheralOptions)
    }
    
    // MARK: - スキャン開始（受信機能）
    
    // BLEデバイスのスキャンを開始する
    func startScanning() {
        guard let centralManager = centralManager else {
            updateStatus("Central Managerが初期化されていません")
            return
        }
        
        // Bluetoothが有効か確認
        if centralManager.state == .poweredOn {
            // ターゲットのサービスUUIDを持つデバイスをスキャン
            centralManager.scanForPeripherals(withServices: [serviceUUID],
                options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
            updateStatus("スキャンを開始しました")
        } else {
            updateStatus("Bluetoothが有効ではありません")
        }
    }
    
    // スキャンを停止する
    func stopScanning() {
        centralManager?.stopScan()
        updateStatus("スキャンを停止しました")
    }
    
    // MARK: - 送信機能の制御
    
    // 送信機能の有効/無効を設定（フォアグラウンド/バックグラウンド切り替え用）
    func setSendingEnabled(_ enabled: Bool) {
        isSendingEnabled = enabled
        
        if enabled {
            startAdvertising()
        }
        // バックグラウンドでもアドバタイズ・接続を継続するため stopAdvertising() を呼ばない
    }
    
    // アドバタイズを開始する（送信機能用）
    private func startAdvertising() {
        guard let peripheralManager = peripheralManager else {
            updateStatus("Peripheral Managerが初期化されていません")
            return
        }
        
        // Bluetoothが有効か確認
        if peripheralManager.state == .poweredOn {
            // サービスがまだ追加されていない場合のみ追加
            if !isServiceAdded {
                // サービスとキャラクタリスティックを作成
                let service = createService()
                
                // サービスを追加
                peripheralManager.add(service)
                isServiceAdded = true
            }
            
            // アドバタイズデータを作成
            let advertisementData: [String: Any] = [
                CBAdvertisementDataServiceUUIDsKey: [serviceUUID]
            ]
            
            // アドバタイズを開始
            peripheralManager.startAdvertising(advertisementData)
            updateStatus("アドバタイズを開始しました")
        } else {
            updateStatus("Bluetoothが有効ではありません")
        }
    }
    
    // サービスが既に追加されているか確認するフラグ
    private var isServiceAdded: Bool = false
    
    // アドバタイズを停止する
    private func stopAdvertising() {
        peripheralManager?.stopAdvertising()
        isServiceAdded = false  // サービス追加フラグをリセット
        updateStatus("アドバタイズを停止しました")
    }
    
    // MARK: - サービスとキャラクタリスティックの作成
    
    // BLEサービスを作成する
    private func createService() -> CBMutableService {
        // キャラクタリスティックを作成（読み取り・書き込み可能）
        transferCharacteristic = CBMutableCharacteristic(
            type: characteristicUUID,
            properties: [.read, .write, .notify],
            value: nil,
            permissions: [.readable, .writeable]
        )
        
        // サービスを作成
        let service = CBMutableService(type: serviceUUID, primary: true)
        
        // キャラクタリスティックをサービスに追加
        service.characteristics = [transferCharacteristic!]
        
        return service
    }
    
    // MARK: - データ送信
    
    // 指定された文字列を送信する
    func sendData(_ dataString: String) {
        
        guard let peripheralManager = peripheralManager else {
            updateStatus("Peripheral Managerが初期化されていません")
            return
        }
        
        // 文字列をDataに変換
        guard let data = dataString.data(using: .utf8) else {
            updateStatus("データの変換に失敗しました")
            return
        }
        
        // 接続中のセントラルに通知を送信
        let success = peripheralManager.updateValue(
            data,
            for: transferCharacteristic!,
            onSubscribedCentrals: nil
        )
        
        if success {
            updateStatus("データを送信しました: \(dataString)")
        } else {
            updateStatus("データの送信に失敗しました（バッファがいっぱいです）")
        }
    }
    
    // MARK: - ステータス更新
    
    // ステータスを更新してコールバックを呼ぶ
    private func updateStatus(_ message: String) {
        print("[BLEManager] \(message)")
        statusUpdateCallback?(message)
    }
    
    // MARK: - CBCentralManagerDelegate
    
    // Central Managerの状態が変化した時に呼ばれる
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            updateStatus("Central Manager: Bluetoothが有効になりました")
            startScanning()
        case .poweredOff:
            updateStatus("Central Manager: Bluetoothが無効です")
        case .unauthorized:
            updateStatus("Central Manager: Bluetoothの使用が許可されていません")
        case .unknown:
            updateStatus("Central Manager: Bluetoothの状態が不明です")
        case .resetting:
            updateStatus("Central Manager: Bluetoothがリセット中です")
        case .unsupported:
            updateStatus("Central Manager: Bluetoothがサポートされていません")
        @unknown default:
            updateStatus("Central Manager: 未知の状態です")
        }
    }
    
    // システムがCentral Managerの状態を復元する時に呼ばれる
    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
        updateStatus("Central Manager: 状態復元を試みます")
        
        // 復元されたペリフェラルを確認
        if let restoredPeripherals = dict[CBCentralManagerRestoredStatePeripheralsKey] as? [CBPeripheral] {
            for peripheral in restoredPeripherals {
                updateStatus("復元されたペリフェラル: \(peripheral.name ?? "不明")")
                // ペリフェラルへの参照を保持
                discoveredPeripherals[peripheral.identifier.uuidString] = peripheral
                peripheral.delegate = self
                
                // 接続中のペリフェラルとして設定
                if let services = peripheral.services, !services.isEmpty {
                    connectedPeripheral = peripheral
                    // サービスとキャラクタリスティックを再探索
                    peripheral.discoverServices([serviceUUID])
                }
            }
        }
        startScanning()
    }
    
    // ペリフェラルを発見した時に呼ばれる
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        updateStatus("ペリフェラルを発見: \(peripheral.name ?? "不明")")
        
        // ペリフェラルへの参照を保持
        discoveredPeripherals[peripheral.identifier.uuidString] = peripheral
        
        // アドバタイズデータからサービスUUIDを確認
        if let serviceUUIDs = advertisementData[CBAdvertisementDataServiceUUIDsKey] as? [CBUUID] {
            if serviceUUIDs.contains(serviceUUID) {
                updateStatus("ターゲットのサービスUUIDを発見、接続を試みます")
                // 接続を試みる
                central.connect(peripheral, options: nil)
            } else {
                updateStatus("ターゲットのサービスUUIDではありません")
            }
        } else if let hashedUUIDs = advertisementData["kCBAdvDataHashedServiceUUIDs"] as? [CBUUID] {
            // バックグラウンド時はUUIDがハッシュ化される場合がある
            if hashedUUIDs.contains(serviceUUID) {
                print("成功！！！！")
                updateStatus("ハッシュ化されたサービスUUIDを発見、接続を試みます")
                central.connect(peripheral, options: nil)
            } else {
                updateStatus("ハッシュ化UUIDにターゲットは含まれていません")
            }
        } else {
            updateStatus("サービスUUIDが含まれていません")
        }
    }
    
    // ペリフェラルへの接続が成功した時に呼ばれる
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        updateStatus("ペリフェラルに接続成功: \(peripheral.name ?? "不明")")
        
        // 接続中のペリフェラルを保持
        connectedPeripheral = peripheral
        peripheral.delegate = self
        
        // ターゲットのサービスを探索
        peripheral.discoverServices([serviceUUID])
    }
    
    // ペリフェラルへの接続が失敗した時に呼ばれる
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        updateStatus("ペリフェラルへの接続に失敗: \(error?.localizedDescription ?? "不明なエラー")")
    }
    
    // ペリフェラルとの接続が切断された時に呼ばれる
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        updateStatus("ペリフェラルとの接続が切断されました")
        connectedPeripheral = nil
        
        // 再スキャンを開始（受信機能は常時有効）
        startScanning()
    }
    
    // MARK: - CBPeripheralDelegate
    
    // サービスを発見した時に呼ばれる
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        
        updateStatus("サービスを発見: \(services.count)個")
        
        for service in services {
            if service.uuid == serviceUUID {
                updateStatus("ターゲットのサービスを発見、キャラクタリスティックを探索します")
                // キャラクタリスティックを探索
                peripheral.discoverCharacteristics([characteristicUUID], for: service)
            }
        }
    }
    
    // キャラクタリスティックを発見した時に呼ばれる
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        
        updateStatus("キャラクタリスティックを発見: \(characteristics.count)個")
        
        for characteristic in characteristics {
            updateStatus("キャラクタリスティックUUID: \(characteristic.uuid)")
            if characteristic.uuid == characteristicUUID {
                updateStatus("ターゲットのキャラクタリスティックを発見、通知を有効にします")
                // 通知を有効にする（受信機能）
                peripheral.setNotifyValue(true, for: characteristic)
                
                // 値を読み取る
                peripheral.readValue(for: characteristic)
            } else if characteristic.properties.contains(.notify) {
                // 通知可能なキャラクタリスティックであれば通知を有効にする（デバッグ用）
                updateStatus("通知可能なキャラクタリスティックを発見、通知を有効にします")
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
    }
    
    // キャラクタリスティックの値が更新された時に呼ばれる（受信）
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard let data = characteristic.value else { return }
        
        // 受信したデータを文字列に変換
        if let receivedString = String(data: data, encoding: .utf8) {
            updateStatus("データを受信しました: \(receivedString)")
            dataReceivedCallback?(receivedString)
        }
    }
    
    // MARK: - CBPeripheralManagerDelegate
    
    // Peripheral Managerの状態が変化した時に呼ばれる
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        switch peripheral.state {
        case .poweredOn:
            updateStatus("Peripheral Manager: Bluetoothが有効になりました")
            startAdvertising()
        case .poweredOff:
            updateStatus("Peripheral Manager: Bluetoothが無効です")
        case .unauthorized:
            updateStatus("Peripheral Manager: Bluetoothの使用が許可されていません")
        case .unknown:
            updateStatus("Peripheral Manager: Bluetoothの状態が不明です")
        case .resetting:
            updateStatus("Peripheral Manager: Bluetoothがリセット中です")
        case .unsupported:
            updateStatus("Peripheral Manager: Bluetoothがサポートされていません")
        @unknown default:
            updateStatus("Peripheral Manager: 未知の状態です")
        }
    }
    
    // システムがPeripheral Managerの状態を復元する時に呼ばれる
    func peripheralManager(_ peripheral: CBPeripheralManager, willRestoreState dict: [String : Any]) {
        updateStatus("Peripheral Manager: 状態復元を試みます")
        
        // 復元されたアドバタイズデータを確認
        if dict[CBPeripheralManagerRestoredStateAdvertisementDataKey] != nil {
            updateStatus("復元されたアドバタイズデータを検出")
            // アドバタイズを再開
            if isSendingEnabled {
                startAdvertising()
            }
        }
    }
    
    // サービスが追加された時に呼ばれる
    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        if let error = error {
            updateStatus("サービスの追加に失敗: \(error.localizedDescription)")
        } else {
            updateStatus("サービスを追加しました")
        }
    }
    
    // アドバタイズが開始された時に呼ばれる
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        if let error = error {
            updateStatus("アドバタイズの開始に失敗: \(error.localizedDescription)")
        } else {
            updateStatus("アドバタイズを開始しました")
        }
    }
    
    // セントラルから書き込みリクエストを受け取った時に呼ばれる
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        for request in requests {
            // 受信したデータを処理
            if let data = request.value, let receivedString = String(data: data, encoding: .utf8) {
                updateStatus("書き込みリクエストを受信: \(receivedString)")
                dataReceivedCallback?(receivedString)
                
                // レスポンスを送信
                peripheral.respond(to: request, withResult: .success)
            }
        }
    }
    
    // セントラルがサブスクライブした時に呼ばれる
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        updateStatus("セントラルがサブスクライブしました")
        // プロフィールを自動送信
        onCentralSubscribed?()
    }
    
    // セントラルがサブスクライブ解除した時に呼ばれる
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic) {
        updateStatus("セントラルがサブスクライブ解除しました")
    }
    
    // 通知の準備ができた時に呼ばれる
    func peripheralManagerIsReady(toUpdateSubscribers peripheral: CBPeripheralManager) {
        updateStatus("通知の準備ができました")
    }
}
