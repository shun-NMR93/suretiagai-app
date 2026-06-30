import Foundation

@MainActor
final class ProfileStore: ObservableObject {
    @Published private(set) var profile: UserProfile

    private let repository: ProfileRepositoryProtocol

    init(repository: ProfileRepositoryProtocol = UserDefaultsProfileRepository()) {
        self.repository = repository
        var loaded = (try? repository.load()) ?? .default
        loaded.foxAvatar = loaded.foxAvatar.clamped()
        profile = loaded
    }

    func save(_ updated: UserProfile) {
        let normalized = UserProfile(
            userID: updated.userID,
            nickname: String(updated.trimmedNickname.prefix(12)),
            greetingMessage: String(updated.greetingMessage.prefix(32)),
            foxAvatar: updated.foxAvatar.clamped(),
            prefecture: updated.prefecture.isEmpty ? profile.prefecture : updated.prefecture
        )
        profile = normalized
        try? repository.save(profile)
    }

    var hasProfile: Bool {
        (try? repository.exists(userID: profile.userID)) ?? false
    }
}
