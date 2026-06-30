import Foundation
import SQLite3

final class DatabaseManager {
    static let shared = DatabaseManager()
    
    private var db: OpaquePointer?
    private let dbFileName = "surechigai.sqlite"
    
    private init() {
        openDatabase()
        createTables()
    }
    
    private func getDatabasePath() -> String {
        let fileManager = FileManager.default
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            fatalError("Documents directory not found")
        }
        return documentsDirectory.appendingPathComponent(dbFileName).path
    }
    
    private func openDatabase() {
        let dbPath = getDatabasePath()
        
        if sqlite3_open(dbPath, &db) != SQLITE_OK {
            let errorMessage = String(cString: sqlite3_errmsg(db))
            fatalError("Cannot open database: \(errorMessage)")
        }
        
        print("Database opened at: \(dbPath)")
    }
    
    private func createTables() {
        createUserProfileTable()
        createEncounteredProfileTable()
    }
    
    private func createUserProfileTable() {
        let createTableSQL = """
        CREATE TABLE IF NOT EXISTS user_profile (
            userID TEXT PRIMARY KEY,
            nickname TEXT,
            greetingMessage TEXT,
            prefecture TEXT,
            foxAvatar BLOB
        );
        """
        
        if sqlite3_exec(db, createTableSQL, nil, nil, nil) != SQLITE_OK {
            let errorMessage = String(cString: sqlite3_errmsg(db))
            fatalError("Cannot create user_profile table: \(errorMessage)")
        }
        
        print("user_profile table created or already exists")
    }
    
    private func createEncounteredProfileTable() {
        let createTableSQL = """
        CREATE TABLE IF NOT EXISTS encountered_profile (
            id TEXT PRIMARY KEY,
            remoteUserID TEXT,
            peerID TEXT,
            encounteredAt REAL,
            lastEncounteredAt REAL,
            encounterCount INTEGER,
            isConfirmed INTEGER,
            profileJSON TEXT
        );
        """
        
        if sqlite3_exec(db, createTableSQL, nil, nil, nil) != SQLITE_OK {
            let errorMessage = String(cString: sqlite3_errmsg(db))
            fatalError("Cannot create encountered_profile table: \(errorMessage)")
        }
        
        print("encountered_profile table created or already exists")
    }
    
    deinit {
        sqlite3_close(db)
    }
}
