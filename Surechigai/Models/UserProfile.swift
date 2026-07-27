import Foundation

struct UserProfile: Codable, Equatable {
    var userID: UUID
    var nickname: String
    var greetingMessage: String
    var foxAvatar: FoxAvatarConfig
    var prefecture: String
    var hobbyTags: [String]

    static let `default` = UserProfile(
        userID: UUID(),
        nickname: "name",
        greetingMessage: "Hello!World!",
        foxAvatar: .default,
        prefecture: "未設定",
        hobbyTags: []
    )

    var trimmedNickname: String {
        nickname.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var isValid: Bool {
        !trimmedNickname.isEmpty
    }

    enum CodingKeys: String, CodingKey {
        case userID
        case nickname
        case greetingMessage
        case foxAvatar
        case prefecture
        case hobbyTags
        case miiAvatar
        case avatarSymbol // 旧バージョン互換（読み捨て）
    }

    init(userID: UUID, nickname: String, greetingMessage: String, foxAvatar: FoxAvatarConfig, prefecture: String = "未設定", hobbyTags: [String] = []) {
        self.userID = userID
        self.nickname = nickname
        self.greetingMessage = greetingMessage
        self.foxAvatar = foxAvatar
        self.prefecture = prefecture
        self.hobbyTags = hobbyTags
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        userID = try container.decodeIfPresent(UUID.self, forKey: .userID) ?? UUID()
        nickname = try container.decode(String.self, forKey: .nickname)
        greetingMessage = try container.decode(String.self, forKey: .greetingMessage)
        prefecture = try container.decodeIfPresent(String.self, forKey: .prefecture) ?? "未設定"
        hobbyTags = try container.decodeIfPresent([String].self, forKey: .hobbyTags) ?? []
        if let foxAvatar = try container.decodeIfPresent(FoxAvatarConfig.self, forKey: .foxAvatar) {
            self.foxAvatar = foxAvatar.clamped()
        } else {
            self.foxAvatar = .default
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(userID, forKey: .userID)
        try container.encode(nickname, forKey: .nickname)
        try container.encode(greetingMessage, forKey: .greetingMessage)
        try container.encode(foxAvatar.clamped(), forKey: .foxAvatar)
        try container.encode(prefecture, forKey: .prefecture)
        try container.encode(hobbyTags, forKey: .hobbyTags)
    }

    func commonHobbyTags(with other: UserProfile) -> [String] {
        hobbyTags.filter { other.hobbyTags.contains($0) }
    }
}
