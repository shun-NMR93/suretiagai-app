import Foundation
import SQLite3

final class SQLiteProfileRepository: ProfileRepositoryProtocol {
    private let databaseManager: DatabaseManager
    
    init(databaseManager: DatabaseManager = .shared) {
        self.databaseManager = databaseManager
    }
    
    func save(_ profile: UserProfile) throws {
        let foxAvatarData = try JSONEncoder().encode(profile.foxAvatar)
        
        let sql = """
        INSERT OR REPLACE INTO user_profile (userID, nickname, greetingMessage, prefecture, foxAvatar)
        VALUES (?, ?, ?, ?, ?);
        """
        
        try databaseManager.executeSQL(sql, bindings: [
            profile.userID,
            profile.nickname,
            profile.greetingMessage,
            profile.prefecture,
            foxAvatarData
        ])
    }
    
    func load() throws -> UserProfile? {
        let sql = "SELECT userID, nickname, greetingMessage, prefecture, foxAvatar FROM user_profile LIMIT 1;"
        
        var result: UserProfile?
        
        try databaseManager.query(sql, bindings: []) { statement in
            let userID = String(cString: sqlite3_column_text(statement, 0))
            let nickname = String(cString: sqlite3_column_text(statement, 1))
            let greetingMessage = String(cString: sqlite3_column_text(statement, 2))
            let prefecture = String(cString: sqlite3_column_text(statement, 3))
            
            if let foxAvatarBlob = sqlite3_column_blob(statement, 4) {
                let foxAvatarData = Data(bytes: foxAvatarBlob, count: Int(sqlite3_column_bytes(statement, 4)))
                let foxAvatar = try JSONDecoder().decode(FoxAvatarConfig.self, from: foxAvatarData)
                
                result = UserProfile(
                    userID: userID,
                    nickname: nickname,
                    greetingMessage: greetingMessage,
                    foxAvatar: foxAvatar,
                    prefecture: prefecture
                )
            }
        }
        
        return result
    }
    
    func update(_ profile: UserProfile) throws {
        // TODO: Implement SQLite update operation
        fatalError("Not implemented")
    }
    
    func delete(userID: String) throws {
        // TODO: Implement SQLite delete operation
        fatalError("Not implemented")
    }
    
    func exists(userID: String) throws -> Bool {
        let sql = "SELECT COUNT(*) FROM user_profile WHERE userID = ?;"
        
        var count = 0
        
        try databaseManager.query(sql, bindings: [userID]) { statement in
            count = Int(sqlite3_column_int64(statement, 0))
        }
        
        return count > 0
    }
}
