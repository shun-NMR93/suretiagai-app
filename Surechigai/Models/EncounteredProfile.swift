import Foundation

struct EncounteredProfile: Codable, Identifiable, Equatable {
    let id: UUID
    var profile: UserProfile
    let encounteredAt: Date
    let peerID: String
    var encounterCount: Int
    var isConfirmed: Bool
    var lastEncounteredAt: Date

    init(profile: UserProfile, peerID: String) {
        self.id = UUID()
        self.profile = profile
        self.encounteredAt = Date()
        self.peerID = peerID
        self.encounterCount = 1
        self.isConfirmed = false
        self.lastEncounteredAt = Date()
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: lastEncounteredAt)
    }

    var relativeTime: String {
        let now = Date()
        let interval = now.timeIntervalSince(lastEncounteredAt)

        if interval < 60 {
            return "たった今"
        } else if interval < 3600 {
            let minutes = Int(interval / 60)
            return "\(minutes)分前"
        } else if interval < 86400 {
            let hours = Int(interval / 3600)
            return "\(hours)時間前"
        } else if interval < 604800 {
            let days = Int(interval / 86400)
            return "\(days)日前"
        } else {
            return formattedDate
        }
    }

    var encounterCountText: String {
        return "\(encounterCount)回目"
    }

    mutating func incrementEncounterCount() {
        encounterCount += 1
        lastEncounteredAt = Date()
    }

    mutating func confirm() {
        isConfirmed = true
    }
}
