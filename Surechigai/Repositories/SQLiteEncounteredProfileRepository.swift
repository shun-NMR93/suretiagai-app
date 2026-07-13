import Foundation
import SQLite3

final class SQLiteEncounteredProfileRepository: EncounteredProfileRepositoryProtocol {
    private let databaseManager: DatabaseManager
    
    init(databaseManager: DatabaseManager = .shared) {
        self.databaseManager = databaseManager
    }
    
    func save(_ profile: EncounteredProfile) throws {
        let profileJSON = try JSONEncoder().encode(profile.profile)
        let profileJSONString = String(data: profileJSON, encoding: .utf8) ?? ""
        
        let sql = """
        INSERT OR REPLACE INTO encountered_profile (id, encounteredAt, lastEncounteredAt, encounterCount, isConfirmed, profileJSON)
        VALUES (?, ?, ?, ?, ?, ?);
        """
        
        try databaseManager.executeSQL(sql, bindings: [
            profile.id.uuidString,
            profile.encounteredAt.timeIntervalSince1970,
            profile.lastEncounteredAt.timeIntervalSince1970,
            profile.encounterCount,
            profile.isConfirmed ? 1 : 0,
            profileJSONString
        ])
    }
    
    func loadAll() throws -> [EncounteredProfile] {
        let sql = """
        SELECT id, encounteredAt, lastEncounteredAt, encounterCount, isConfirmed, profileJSON
        FROM encountered_profile
        ORDER BY lastEncounteredAt DESC;
        """

        var results: [EncounteredProfile] = []

        try databaseManager.query(sql, bindings: []) { statement in
            let idString = String(cString: sqlite3_column_text(statement, 0))
            let encounteredAt = Date(timeIntervalSince1970: sqlite3_column_double(statement, 1))
            let lastEncounteredAt = Date(timeIntervalSince1970: sqlite3_column_double(statement, 2))
            let encounterCount = Int(sqlite3_column_int64(statement, 3))
            let isConfirmed = sqlite3_column_int(statement, 4) != 0

            if let profileJSONText = sqlite3_column_text(statement, 5) {
                let profileJSONString = String(cString: profileJSONText)
                if let profileJSONData = profileJSONString.data(using: .utf8) {
                    let profile = try JSONDecoder().decode(UserProfile.self, from: profileJSONData)

                    let encounteredProfile = EncounteredProfile(
                        id: UUID(uuidString: idString) ?? UUID(),
                        profile: profile,
                        encounteredAt: encounteredAt,
                        encounterCount: encounterCount,
                        isConfirmed: isConfirmed,
                        lastEncounteredAt: lastEncounteredAt
                    )

                    results.append(encounteredProfile)
                }
            }
        }

        return results
    }
    
    func load(byID id: String) throws -> EncounteredProfile? {
        let sql = """
        SELECT id, encounteredAt, lastEncounteredAt, encounterCount, isConfirmed, profileJSON
        FROM encountered_profile
        WHERE id = ?;
        """
        
        var result: EncounteredProfile?
        
        try databaseManager.query(sql, bindings: [id]) { statement in
            let idString = String(cString: sqlite3_column_text(statement, 0))
            let encounteredAt = Date(timeIntervalSince1970: sqlite3_column_double(statement, 1))
            let lastEncounteredAt = Date(timeIntervalSince1970: sqlite3_column_double(statement, 2))
            let encounterCount = Int(sqlite3_column_int64(statement, 3))
            let isConfirmed = sqlite3_column_int(statement, 4) != 0
            
            if let profileJSONText = sqlite3_column_text(statement, 5) {
                let profileJSONString = String(cString: profileJSONText)
                if let profileJSONData = profileJSONString.data(using: .utf8) {
                    let profile = try JSONDecoder().decode(UserProfile.self, from: profileJSONData)
                    
                    let encounteredProfile = EncounteredProfile(
                        id: UUID(uuidString: idString) ?? UUID(),
                        profile: profile,
                        encounteredAt: encounteredAt,
                        encounterCount: encounterCount,
                        isConfirmed: isConfirmed,
                        lastEncounteredAt: lastEncounteredAt
                    )
                    
                    result = encounteredProfile
                }
            }
        }
        
        return result
    }
    
    func update(_ profile: EncounteredProfile) throws {
        try save(profile)
    }

    func delete(id: String) throws {
        let sql = "DELETE FROM encountered_profile WHERE id = ?;"
        try databaseManager.executeSQL(sql, bindings: [id])
    }

    func deleteAll() throws {
        let sql = "DELETE FROM encountered_profile;"
        try databaseManager.executeSQL(sql, bindings: [])
    }

    func count() throws -> Int {
        let sql = "SELECT COUNT(*) FROM encountered_profile;"

        var count = 0

        try databaseManager.query(sql, bindings: []) { statement in
            count = Int(sqlite3_column_int64(statement, 0))
        }

        return count
    }
}
