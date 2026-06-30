import Foundation

final class UserDefaultsProfileRepository: ProfileRepositoryProtocol {
    private let storageKey = "surechigai.userProfile"
    
    func save(_ profile: UserProfile) throws {
        let data = try JSONEncoder().encode(profile)
        UserDefaults.standard.set(data, forKey: storageKey)
    }
    
    func load() throws -> UserProfile? {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else {
            return nil
        }
        return try JSONDecoder().decode(UserProfile.self, from: data)
    }
    
    func update(_ profile: UserProfile) throws {
        try save(profile)
    }
    
    func delete(userID: String) throws {
        UserDefaults.standard.removeObject(forKey: storageKey)
    }
    
    func exists(userID: String) throws -> Bool {
        UserDefaults.standard.data(forKey: storageKey) != nil
    }
}

enum RepositoryError: Error {
    case encodingFailed
    case decodingFailed
}
