import Foundation
import Combine

@MainActor
class PetListViewModel: ObservableObject {
    @Published var pets: [Pet] = []
    @Published var isLoading = false
    @Published var error: String? = nil

    func loadPets() async {
        isLoading = true
        error = nil
        do {
            pets = try await APIService.shared.getPets()
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }

    func addPet(name: String, species: String, breed: String) async {
        let req = CreatePetRequest(name: name, species: species, breed: breed, birthDate: nil, weight: nil)
        do {
            let pet = try await APIService.shared.createPet(req)
            pets.insert(pet, at: 0)
        } catch {
            self.error = error.localizedDescription
        }
    }
}
