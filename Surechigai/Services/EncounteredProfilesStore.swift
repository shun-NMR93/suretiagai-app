import Foundation

struct DailyStat: Identifiable {
    let id = UUID()
    let date: Date
    let count: Int

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "M月d日"
        return formatter.string(from: date)
    }

    var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
}

@MainActor
final class EncounteredProfilesStore: ObservableObject {
    @Published private(set) var encounteredProfiles: [EncounteredProfile] = []

    private let repository: EncounteredProfileRepositoryProtocol
    private let maxProfiles = 100

    init(repository: EncounteredProfileRepositoryProtocol = UserDefaultsEncounteredProfileRepository()) {
        self.repository = repository
        load()
    }

    func addProfile(_ profile: UserProfile, peerID: String, remoteUserID: String = "") {
        if let existingIndex = encounteredProfiles.firstIndex(where: { $0.peerID == peerID }) {
            encounteredProfiles[existingIndex].incrementEncounterCount()
            encounteredProfiles[existingIndex].profile = profile
            if !remoteUserID.isEmpty {
                encounteredProfiles[existingIndex].remoteUserID = remoteUserID
            }
            encounteredProfiles.sort { $0.lastEncounteredAt > $1.lastEncounteredAt }
        } else {
            let encountered = EncounteredProfile(profile: profile, peerID: peerID, remoteUserID: remoteUserID)
            encounteredProfiles.insert(encountered, at: 0)
        }

        if encounteredProfiles.count > maxProfiles {
            encounteredProfiles = Array(encounteredProfiles.prefix(maxProfiles))
        }

        save()
    }

    func confirmProfile(at index: Int) {
        guard index < encounteredProfiles.count else { return }
        encounteredProfiles[index].confirm()
        save()
    }

    func removeProfile(at index: Int) {
        guard index < encounteredProfiles.count else { return }
        let id = encounteredProfiles[index].id.uuidString
        encounteredProfiles.remove(at: index)
        try? repository.delete(id: id)
    }

    func removeAll() {
        encounteredProfiles.removeAll()
        try? repository.deleteAll()
    }

    var totalCount: Int {
        encounteredProfiles.count
    }

    var todayCount: Int {
        let today = Calendar.current.startOfDay(for: Date())
        return encounteredProfiles.filter { profile in
            Calendar.current.isDate(profile.lastEncounteredAt, inSameDayAs: today)
        }.count
    }

    var dailyStats: [DailyStat] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: encounteredProfiles) { profile in
            calendar.startOfDay(for: profile.lastEncounteredAt)
        }.map { (date, profiles) in
            DailyStat(date: date, count: profiles.count)
        }
        return grouped.sorted { $0.date > $1.date }
    }

    private func load() {
        encounteredProfiles = (try? repository.loadAll()) ?? []
    }

    private func save() {
        for profile in encounteredProfiles {
            try? repository.save(profile)
        }
    }
}
