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
    
    func executeSQL(_ sql: String, bindings: [Any]) throws {
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) != SQLITE_OK {
            let errorMessage = String(cString: sqlite3_errmsg(db))
            throw DatabaseError.prepareFailed(errorMessage)
        }
        
        for (index, value) in bindings.enumerated() {
            let index = Int32(index + 1)
            
            switch value {
            case let text as String:
                sqlite3_bind_text(statement, index, (text as NSString).utf8String, -1, nil)
            case let integer as Int:
                sqlite3_bind_int64(statement, index, Int64(integer))
            case let real as Double:
                sqlite3_bind_double(statement, index, real)
            case let data as Data:
                data.withUnsafeBytes { (bytes: UnsafeRawBufferPointer) in
                    sqlite3_bind_blob(statement, index, bytes.baseAddress, Int32(data.count), nil)
                }
            default:
                sqlite3_bind_null(statement, index)
            }
        }
        
        if sqlite3_step(statement) != SQLITE_DONE {
            let errorMessage = String(cString: sqlite3_errmsg(db))
            sqlite3_finalize(statement)
            throw DatabaseError.executionFailed(errorMessage)
        }
        
        sqlite3_finalize(statement)
    }
    
    func query(_ sql: String, bindings: [Any], rowHandler: (OpaquePointer) throws -> Void) throws {
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) != SQLITE_OK {
            let errorMessage = String(cString: sqlite3_errmsg(db))
            throw DatabaseError.prepareFailed(errorMessage)
        }
        
        guard let statement = statement else {
            throw DatabaseError.prepareFailed("Failed to prepare statement")
        }
        
        for (index, value) in bindings.enumerated() {
            let index = Int32(index + 1)
            
            switch value {
            case let text as String:
                sqlite3_bind_text(statement, index, (text as NSString).utf8String, -1, nil)
            case let integer as Int:
                sqlite3_bind_int64(statement, index, Int64(integer))
            case let real as Double:
                sqlite3_bind_double(statement, index, real)
            case let data as Data:
                _ = data.withUnsafeBytes { (bytes: UnsafeRawBufferPointer) in
                    sqlite3_bind_blob(statement, index, bytes.baseAddress, Int32(data.count), nil)
                }
            default:
                sqlite3_bind_null(statement, index)
            }
        }
        
        while sqlite3_step(statement) == SQLITE_ROW {
            try rowHandler(statement)
        }
        
        sqlite3_finalize(statement)
    }
    
    deinit {
        sqlite3_close(db)
    }
}

enum DatabaseError: Error {
    case prepareFailed(String)
    case executionFailed(String)
}
