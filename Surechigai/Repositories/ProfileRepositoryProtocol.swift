import Foundation

protocol ProfileRepositoryProtocol {
    func save(_ profile: UserProfile) throws
    func load() throws -> UserProfile?
    func update(_ profile: UserProfile) throws
    func delete(userID: String) throws
    func exists(userID: String) throws -> Bool
}
