import SwiftUI

struct PetListView: View {
    @StateObject private var vm = PetListViewModel()
    @State private var showAddPet = false

    var body: some View {
        NavigationStack {
            Group {
                if vm.isLoading {
                    ProgressView("Loading pets...")
                } else if vm.pets.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "pawprint").font(.system(size: 48)).foregroundColor(.secondary)
                        Text("No pets yet").font(.headline)
                        Text("Tap + to add your first pet").font(.caption).foregroundColor(.secondary)
                    }
                } else {
                    List(vm.pets) { pet in
                        NavigationLink(destination: PetDetailView(pet: pet, listVM: vm)) {
                            PetRowView(pet: pet)
                        }
                    }
                }
            }
            .navigationTitle("My Pets")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAddPet = true }) { Image(systemName: "plus") }
                }
            }
            .sheet(isPresented: $showAddPet) { AddPetView(vm: vm) }
            .task { await vm.loadPets() }
        }
    }
}

struct PetRowView: View {
    let pet: Pet
    var body: some View {
        HStack {
            Image(systemName: pet.species == "dog" ? "dog.fill" : "cat.fill")
                .foregroundColor(.blue).frame(width: 36, height: 36)
            VStack(alignment: .leading) {
                Text(pet.name).font(.headline)
                Text("\(pet.species.capitalized) · \(pet.breed)").font(.caption).foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
