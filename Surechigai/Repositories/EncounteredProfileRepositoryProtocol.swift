import Foundation

protocol EncounteredProfileRepositoryProtocol {
    func save(_ profile: EncounteredProfile) throws
    func loadAll() throws -> [EncounteredProfile]
    func load(byID id: String) throws -> EncounteredProfile?
    func load(byPeerID peerID: String) throws -> EncounteredProfile?
    func update(_ profile: EncounteredProfile) throws
    func delete(id: String) throws
    func deleteAll() throws
    func count() throws -> Int
}
