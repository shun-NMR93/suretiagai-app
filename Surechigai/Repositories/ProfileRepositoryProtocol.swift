import Foundation

protocol ProfileRepositoryProtocol {
    func save(_ profile: UserProfile) throws
    func load() throws -> UserProfile?
    func exists(userID: UUID) throws -> Bool
}
