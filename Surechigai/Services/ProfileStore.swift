import Foundation

@MainActor
final class ProfileStore: ObservableObject {
    @Published private(set) var profile: UserProfile

    private static let storageKey = "surechigai.userProfile"

    init() {
        var loaded = Self.load() ?? .default
        loaded.foxAvatar = loaded.foxAvatar.clamped()
        profile = loaded
    }

    func save(_ updated: UserProfile) {
        let normalized = UserProfile(
            nickname: String(updated.trimmedNickname.prefix(12)),
            greetingMessage: String(updated.greetingMessage.prefix(32)),
            foxAvatar: updated.foxAvatar.clamped(),
            prefecture: updated.prefecture.isEmpty ? profile.prefecture : updated.prefecture
        )
        profile = normalized
        persist(profile)
    }

    private static func load() -> UserProfile? {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else {
            return nil
        }
        return try? JSONDecoder().decode(UserProfile.self, from: data)
    }

    private func persist(_ profile: UserProfile) {
        guard let data = try? JSONEncoder().encode(profile) else { return }
        UserDefaults.standard.set(data, forKey: Self.storageKey)
    }
}
