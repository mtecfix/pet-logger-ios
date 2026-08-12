import SwiftUI

struct AddPetView: View {
    @ObservedObject var vm: PetListViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var name    = ""
    @State private var species = "dog"
    @State private var breed   = ""

    let species_options = ["dog", "cat", "bird", "rabbit", "fish", "hamster", "reptile", "other"]

    var body: some View {
        NavigationStack {
            Form {
                Section("Pet Info") {
                    TextField("Name", text: $name)
                    Picker("Species", selection: $species) {
                        ForEach(species_options, id: \.self) { Text($0.capitalized) }
                    }
                    TextField("Breed", text: $breed)
                }
            }
            .navigationTitle("Add Pet")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            await vm.addPet(name: name, species: species, breed: breed)
                            dismiss()
                        }
                    }
                    .disabled(name.isEmpty || breed.isEmpty)
                }
            }
        }
    }
}
