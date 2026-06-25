import Foundation

/// 二足歩行デフォルメ狐アバターの設定
struct FoxAvatarConfig: Codable, Equatable {
    var furColorIndex: Int
    var eyeStyle: Int
    var mouthStyle: Int
    var cheekStyle: Int
    var accessory: Int

    static let `default` = FoxAvatarConfig(
        furColorIndex: 0,
        eyeStyle: 1,
        mouthStyle: 0,
        cheekStyle: 1,
        accessory: 0
    )

    func clamped() -> FoxAvatarConfig {
        FoxAvatarConfig(
            furColorIndex: furColorIndex.clamped(to: FoxPartCatalog.furColorCount),
            eyeStyle: eyeStyle.clamped(to: FoxPartCatalog.eyeStyles),
            mouthStyle: mouthStyle.clamped(to: FoxPartCatalog.mouthStyles),
            cheekStyle: cheekStyle.clamped(to: FoxPartCatalog.cheekStyles),
            accessory: accessory.clamped(to: FoxPartCatalog.accessories)
        )
    }
}

private extension Int {
    func clamped(to count: Int) -> Int {
        guard count > 0 else { return 0 }
        return Swift.min(Swift.max(self, 0), count - 1)
    }
}
