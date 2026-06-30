import Foundation

final class SQLiteEncounteredProfileRepository: EncounteredProfileRepositoryProtocol {
    private let databaseManager: DatabaseManager
    
    init(databaseManager: DatabaseManager = .shared) {
        self.databaseManager = databaseManager
    }
    
    func save(_ profile: EncounteredProfile) throws {
        // TODO: Implement SQLite save operation
        fatalError("Not implemented")
    }
    
    func loadAll() throws -> [EncounteredProfile] {
        // TODO: Implement SQLite loadAll operation
        fatalError("Not implemented")
    }
    
    func load(byID id: String) throws -> EncounteredProfile? {
        // TODO: Implement SQLite load by ID operation
        fatalError("Not implemented")
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
