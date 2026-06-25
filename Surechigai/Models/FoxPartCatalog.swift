import SwiftUI

struct FoxFurPalette {
    let main: Color
    let belly: Color
    let innerEar: Color
    let label: String
}

enum FoxPartCatalog {
    static let furColorCount = 8
    static let faceShapes = 4
    static let earShapes = 4
    static let bodyShapes = 3
    static let eyeStyles = 5
    static let mouthStyles = 5
    static let cheekStyles = 3

    static let furColorLabels = ["オレンジ", "レッド", "シルバー", "クリーム", "チョコ", "スノー", "ミッドナイト", "サクラ"]
    static let faceShapeLabels = ["丸顔", "面長", "四角顔", "卵型"]
    static let earShapeLabels = ["三角", "丸み", "垂れ耳", "立ち耳"]
    static let bodyShapeLabels = ["標準", "ぽっちゃり", "スリム"]
    static let eyeStyleLabels = ["ぱっちり", "にっこり", "くりくり", "きらきら", "ウィンク"]
    static let mouthStyleLabels = ["にっこり", "たべてる", "ぺろっ", "きゅん", "む"]
    static let cheekStyleLabels = ["なし", "ほんのり", "りんご"]

    static let furPalettes: [FoxFurPalette] = [
        FoxFurPalette(main: Color(red: 0.95, green: 0.52, blue: 0.2), belly: Color(red: 1, green: 0.9, blue: 0.78), innerEar: Color(red: 1, green: 0.75, blue: 0.72), label: "オレンジ"),
        FoxFurPalette(main: Color(red: 0.88, green: 0.32, blue: 0.18), belly: Color(red: 1, green: 0.86, blue: 0.74), innerEar: Color(red: 1, green: 0.7, blue: 0.68), label: "レッド"),
        FoxFurPalette(main: Color(red: 0.72, green: 0.74, blue: 0.78), belly: Color(red: 0.92, green: 0.93, blue: 0.95), innerEar: Color(red: 0.95, green: 0.82, blue: 0.84), label: "シルバー"),
        FoxFurPalette(main: Color(red: 0.96, green: 0.82, blue: 0.58), belly: Color(red: 1, green: 0.96, blue: 0.88), innerEar: Color(red: 1, green: 0.86, blue: 0.8), label: "クリーム"),
        FoxFurPalette(main: Color(red: 0.52, green: 0.34, blue: 0.22), belly: Color(red: 0.82, green: 0.68, blue: 0.52), innerEar: Color(red: 0.92, green: 0.72, blue: 0.68), label: "チョコ"),
        FoxFurPalette(main: Color(red: 0.94, green: 0.94, blue: 0.96), belly: Color(red: 1, green: 1, blue: 1), innerEar: Color(red: 1, green: 0.86, blue: 0.88), label: "スノー"),
        FoxFurPalette(main: Color(red: 0.22, green: 0.2, blue: 0.28), belly: Color(red: 0.42, green: 0.4, blue: 0.48), innerEar: Color(red: 0.55, green: 0.42, blue: 0.48), label: "ミッドナイト"),
        FoxFurPalette(main: Color(red: 0.98, green: 0.62, blue: 0.72), belly: Color(red: 1, green: 0.88, blue: 0.92), innerEar: Color(red: 1, green: 0.78, blue: 0.82), label: "サクラ")
    ]

    static func furPalette(index: Int) -> FoxFurPalette {
        furPalettes[index.clamped(to: furColorCount)]
    }
}

private extension Int {
    func clamped(to count: Int) -> Int {
        guard count > 0 else { return 0 }
        return Swift.min(Swift.max(self, 0), count - 1)
    }
}
