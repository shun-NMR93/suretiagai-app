import Foundation
import SQLite3

final class SQLiteProfileRepository: ProfileRepositoryProtocol {
    private let databaseManager: DatabaseManager
    
    init(databaseManager: DatabaseManager = .shared) {
        self.databaseManager = databaseManager
    }
    
    func save(_ profile: UserProfile) throws {
        let foxAvatarData = try JSONEncoder().encode(profile.foxAvatar)
        let hobbyTagsData = try JSONEncoder().encode(profile.hobbyTags)
        let hobbyTagsString = String(data: hobbyTagsData, encoding: .utf8) ?? "[]"

        let sql = """
        INSERT OR REPLACE INTO user_profile (userID, nickname, greetingMessage, prefecture, foxAvatar, hobbyTags)
        VALUES (?, ?, ?, ?, ?, ?);
        """

        try databaseManager.executeSQL(sql, bindings: [
            profile.userID.uuidString,
            profile.nickname,
            profile.greetingMessage,
            profile.prefecture,
            foxAvatarData,
            hobbyTagsString
        ])
    }
    
    func load() throws -> UserProfile? {
        let sql = "SELECT userID, nickname, greetingMessage, prefecture, foxAvatar, hobbyTags FROM user_profile LIMIT 1;"

        var result: UserProfile?

        try databaseManager.query(sql, bindings: []) { statement in
            let userIDString = String(cString: sqlite3_column_text(statement, 0))
            let nickname = String(cString: sqlite3_column_text(statement, 1))
            let greetingMessage = String(cString: sqlite3_column_text(statement, 2))
            let prefecture = String(cString: sqlite3_column_text(statement, 3))

            if let foxAvatarBlob = sqlite3_column_blob(statement, 4) {
                let foxAvatarData = Data(bytes: foxAvatarBlob, count: Int(sqlite3_column_bytes(statement, 4)))
                let foxAvatar = try JSONDecoder().decode(FoxAvatarConfig.self, from: foxAvatarData)

                var hobbyTags: [String] = []
                if let hobbyTagsText = sqlite3_column_text(statement, 5) {
                    let hobbyTagsString = String(cString: hobbyTagsText)
                    if let hobbyTagsData = hobbyTagsString.data(using: .utf8) {
                        hobbyTags = try JSONDecoder().decode([String].self, from: hobbyTagsData)
                    }
                }

                result = UserProfile(
                    userID: UUID(uuidString: userIDString) ?? UUID(),
                    nickname: nickname,
                    greetingMessage: greetingMessage,
                    foxAvatar: foxAvatar,
                    prefecture: prefecture,
                    hobbyTags: hobbyTags
                )
            }
        }

        return result
    }

    func exists(userID: UUID) throws -> Bool {
        let sql = "SELECT COUNT(*) FROM user_profile WHERE userID = ?;"
        
        var count = 0
        
        try databaseManager.query(sql, bindings: [userID.uuidString]) { statement in
            count = Int(sqlite3_column_int64(statement, 0))
        }
        
        return count > 0
    }
}
