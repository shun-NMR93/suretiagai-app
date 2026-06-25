import Foundation

/// 1,000歩ごとの報酬用マイルストーン（ゲーム機能で利用予定）
enum StepMilestone {
    static let interval = 1_000

    /// 今日の歩数で達成した 1,000 歩ブロックの回数（例: 2,500歩 → 2）
    static func completedCount(for steps: Int) -> Int {
        max(steps / interval, 0)
    }

    /// 現在の 1,000 歩ブロック内の歩数（1〜1,000。ちょうど区切りのときは 1,000）
    static func stepsInCurrentBlock(for steps: Int) -> Int {
        let remainder = steps % interval
        if remainder == 0, steps > 0 {
            return interval
        }
        return remainder
    }

    /// 次の 1,000 歩まであと何歩か
    static func stepsUntilNext(for steps: Int) -> Int {
        let remainder = steps % interval
        if remainder == 0 {
            return interval
        }
        return interval - remainder
    }

    /// 現在ブロックの進捗（0.0〜1.0）
    static func progressInCurrentBlock(for steps: Int) -> Double {
        if steps == 0 {
            return 0
        }
        return Double(stepsInCurrentBlock(for: steps)) / Double(interval)
    }
}
