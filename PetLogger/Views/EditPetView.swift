import SwiftUI

struct EditPetView: View {
    @ObservedObject var vm: PetListViewModel
    let pet: Pet
    @Environment(\.dismiss) private var dismiss
    @State private var name: String
    @State private var species: String
    @State private var breed: String
    @State private var weight: String
    @State private var error: String? = nil
    @State private var loading = false

    let speciesOptions = ["dog","cat","bird","rabbit","fish","hamster","reptile","other"]

    init(vm: PetListViewModel, pet: Pet) {
        self.vm = vm
        self.pet = pet
        _name    = State(initialValue: pet.name)
        _species = State(initialValue: pet.species)
        _breed   = State(initialValue: pet.breed)
        _weight  = State(initialValue: pet.weight.map { String($0) } ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Pet Info") {
                    TextField("Name", text: $name)
                    Picker("Species", selection: $species) {
                        ForEach(speciesOptions, id: \.self) { Text($0.capitalized) }
                    }
                    TextField("Breed", text: $breed)
                    HStack {
                        TextField("Weight", text: $weight).keyboardType(.decimalPad)
                        Text("lbs").foregroundColor(.secondary)
                    }
                }
                if let e = error {
                    Section { Text(e).foregroundColor(.red).font(.caption) }
                }
            }
            .navigationTitle("Edit Pet")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }.disabled(name.isEmpty || breed.isEmpty || loading)
                }
            }
        }
    }

    func save() {
        loading = true; error = nil
        Task {
            do {
                try await vm.updatePet(petId: pet.id, name: name, species: species, breed: breed, weight: Double(weight))
                dismiss()
            } catch {
                self.error = error.localizedDescription
            }
            loading = false
        }
    }
}
