import Foundation
import Combine

@MainActor
class PetListViewModel: ObservableObject {
    @Published var pets: [Pet] = []
    @Published var isLoading = false
    @Published var error: String? = nil
    @Published var isOffline = false

    private let cacheKey = "cached_pets"

    func loadPets() async {
        // Show cached data immediately
        if let cached = LocalCache.shared.load(Pet.self, key: cacheKey) {
            pets = cached
        }
        isLoading = true; error = nil
        do {
            pets = try await APIService.shared.getPets()
            LocalCache.shared.save(pets, key: cacheKey)
            isOffline = false
        } catch {
            if pets.isEmpty { self.error = error.localizedDescription }
            isOffline = true
        }
        isLoading = false
    }

    func addPet(name: String, species: String, breed: String) async {
        let req = CreatePetRequest(name: name, species: species, breed: breed, birthDate: nil, weight: nil)
        do {
            let pet = try await APIService.shared.createPet(req)
            pets.insert(pet, at: 0)
            LocalCache.shared.save(pets, key: cacheKey)
        } catch { self.error = error.localizedDescription }
    }

    func updatePet(petId: String, name: String, species: String, breed: String, weight: Double?) async throws {
        try await APIService.shared.updatePet(petId: petId, name: name, species: species, breed: breed, weight: weight)
        if let idx = pets.firstIndex(where: { $0.id == petId }) {
            pets[idx].name = name; pets[idx].species = species
            pets[idx].breed = breed; pets[idx].weight = weight
            LocalCache.shared.save(pets, key: cacheKey)
        }
    }

    func deletePet(petId: String) async {
        do {
            try await APIService.shared.deletePet(petId: petId)
            pets.removeAll { $0.id == petId }
            LocalCache.shared.save(pets, key: cacheKey)
        } catch { self.error = error.localizedDescription }
    }
}
