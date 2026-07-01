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
        INSERT OR REPLACE INTO encountered_profile (id, remoteUserID, peerID, encounteredAt, lastEncounteredAt, encounterCount, isConfirmed, profileJSON)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?);
        """
        
        try databaseManager.executeSQL(sql, bindings: [
            profile.id.uuidString,
            profile.remoteUserID,
            profile.peerID,
            profile.encounteredAt.timeIntervalSince1970,
            profile.lastEncounteredAt.timeIntervalSince1970,
            profile.encounterCount,
            profile.isConfirmed ? 1 : 0,
            profileJSONString
        ])
    }
    
    func loadAll() throws -> [EncounteredProfile] {
        // TODO: Implement SQLite loadAll operation
        fatalError("Not implemented")
    }
    
    func load(byID id: String) throws -> EncounteredProfile? {
        let sql = """
        SELECT id, remoteUserID, peerID, encounteredAt, lastEncounteredAt, encounterCount, isConfirmed, profileJSON
        FROM encountered_profile
        WHERE id = ?;
        """
        
        var result: EncounteredProfile?
        
        try databaseManager.query(sql, bindings: [id]) { statement in
            let idString = String(cString: sqlite3_column_text(statement, 0))
            let remoteUserID = String(cString: sqlite3_column_text(statement, 1))
            let peerID = String(cString: sqlite3_column_text(statement, 2))
            let encounteredAt = Date(timeIntervalSince1970: sqlite3_column_double(statement, 3))
            let lastEncounteredAt = Date(timeIntervalSince1970: sqlite3_column_double(statement, 4))
            let encounterCount = Int(sqlite3_column_int64(statement, 5))
            let isConfirmed = sqlite3_column_int(statement, 6) != 0
            
            if let profileJSONText = sqlite3_column_text(statement, 7) {
                let profileJSONString = String(cString: profileJSONText)
                if let profileJSONData = profileJSONString.data(using: .utf8) {
                    let profile = try JSONDecoder().decode(UserProfile.self, from: profileJSONData)
                    
                    let encounteredProfile = EncounteredProfile(
                        id: UUID(uuidString: idString) ?? UUID(),
                        profile: profile,
                        encounteredAt: encounteredAt,
                        peerID: peerID,
                        remoteUserID: remoteUserID,
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
    
    func load(byPeerID peerID: String) throws -> EncounteredProfile? {
        // TODO: Implement SQLite load by peerID operation
        fatalError("Not implemented")
    }
    
    func update(_ profile: EncounteredProfile) throws {
        // TODO: Implement SQLite update operation
        fatalError("Not implemented")
    }
    
    func delete(id: String) throws {
        // TODO: Implement SQLite delete operation
        fatalError("Not implemented")
    }
    
    func deleteAll() throws {
        // TODO: Implement SQLite deleteAll operation
        fatalError("Not implemented")
    }
    
    func count() throws -> Int {
        // TODO: Implement SQLite count operation
        fatalError("Not implemented")
    }
}
