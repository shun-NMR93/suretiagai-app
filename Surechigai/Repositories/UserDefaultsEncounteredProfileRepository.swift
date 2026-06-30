import Foundation

final class UserDefaultsEncounteredProfileRepository: EncounteredProfileRepositoryProtocol {
    private let storageKey = "surechigai.encounteredProfiles"
    
    func save(_ profile: EncounteredProfile) throws {
        var allProfiles = try loadAll()
        
        if let existingIndex = allProfiles.firstIndex(where: { $0.peerID == profile.peerID }) {
            allProfiles[existingIndex] = profile
        } else {
            allProfiles.insert(profile, at: 0)
        }
        
        let data = try JSONEncoder().encode(allProfiles)
        UserDefaults.standard.set(data, forKey: storageKey)
    }
    
    func loadAll() throws -> [EncounteredProfile] {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else {
            return []
        }
        return try JSONDecoder().decode([EncounteredProfile].self, from: data)
    }
    
    func load(byID id: String) throws -> EncounteredProfile? {
        let allProfiles = try loadAll()
        return allProfiles.first { $0.id.uuidString == id }
    }
    
    func load(byPeerID peerID: String) throws -> EncounteredProfile? {
        let allProfiles = try loadAll()
        return allProfiles.first { $0.peerID == peerID }
    }
    
    func update(_ profile: EncounteredProfile) throws {
        try save(profile)
    }
    
    func delete(id: String) throws {
        var allProfiles = try loadAll()
        allProfiles.removeAll { $0.id.uuidString == id }
        
        let data = try JSONEncoder().encode(allProfiles)
        UserDefaults.standard.set(data, forKey: storageKey)
    }
    
    func deleteAll() throws {
        UserDefaults.standard.removeObject(forKey: storageKey)
    }
    
    func count() throws -> Int {
        return try loadAll().count
    }
}
