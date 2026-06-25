import Foundation

/// 二足歩行デフォルメ狐アバターの設定
struct FoxAvatarConfig: Codable, Equatable {
    var furColorIndex: Int
    var faceShape: Int
    var earShape: Int
    var bodyShape: Int
    var eyeStyle: Int
    var mouthStyle: Int
    var cheekStyle: Int

    static let `default` = FoxAvatarConfig(
        furColorIndex: 0,
        faceShape: 0,
        earShape: 0,
        bodyShape: 0,
        eyeStyle: 1,
        mouthStyle: 0,
        cheekStyle: 1
    )

    func clamped() -> FoxAvatarConfig {
        FoxAvatarConfig(
            furColorIndex: furColorIndex.clamped(to: FoxPartCatalog.furColorCount),
            faceShape: faceShape.clamped(to: FoxPartCatalog.faceShapes),
            earShape: earShape.clamped(to: FoxPartCatalog.earShapes),
            bodyShape: bodyShape.clamped(to: FoxPartCatalog.bodyShapes),
            eyeStyle: eyeStyle.clamped(to: FoxPartCatalog.eyeStyles),
            mouthStyle: mouthStyle.clamped(to: FoxPartCatalog.mouthStyles),
            cheekStyle: cheekStyle.clamped(to: FoxPartCatalog.cheekStyles)
        )
    }
}

private extension Int {
    func clamped(to count: Int) -> Int {
        guard count > 0 else { return 0 }
        return Swift.min(Swift.max(self, 0), count - 1)
    }
}
