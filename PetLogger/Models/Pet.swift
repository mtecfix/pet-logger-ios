import Foundation

struct Pet: Codable, Identifiable {
    let id: String         // PetId from DynamoDB
    let userId: String
    var name: String
    var species: String    // dog, cat, bird, etc.
    var breed: String
    var birthDate: String? // ISO8601
    var weight: Double?
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id = "PetId"
        case userId = "UserId"
        case name, species, breed, birthDate, weight, createdAt
    }
}

struct CreatePetRequest: Codable {
    let name: String
    let species: String
    let breed: String
    let birthDate: String?
    let weight: Double?
}
