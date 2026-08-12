import SwiftUI

struct PetDetailView: View {
    let pet: Pet
    @ObservedObject var listVM: PetListViewModel
    @StateObject private var vm = MetricsViewModel()
    @State private var showLogMetric      = false
    @State private var showEdit           = false
    @State private var showPhoto          = false
    @State private var showDeleteConfirm  = false
    @State private var showMedSchedule    = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        List {
            Section("Profile") {
                LabeledContent("Name",    value: pet.name)
                LabeledContent("Species", value: pet.species.capitalized)
                LabeledContent("Breed",   value: pet.breed)
                if let w = pet.weight { LabeledContent("Weight", value: "\(w) lbs") }
            }

            Section("Health Log") {
                if vm.isLoading { ProgressView() }
                else if vm.metrics.isEmpty {
                    Text("No metrics logged yet").foregroundColor(.secondary)
                } else {
                    ForEach(vm.metrics) { metric in MetricRowView(metric: metric) }
                        .onDelete { idx in
                            Task { for i in idx { await vm.deleteMetric(metricId: vm.metrics[i].id) } }
                        }
                }
            }
        }
        .navigationTitle(pet.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button { showMedSchedule = true } label: { Image(systemName: "bell.badge") }
                Button { showPhoto = true } label: { Image(systemName: "camera.fill") }
                Button { showLogMetric = true } label: { Image(systemName: "plus.circle") }
                Menu {
                    Button { showEdit = true } label: { Label("Edit Pet", systemImage: "pencil") }
                    Button(role: .destructive) { showDeleteConfirm = true } label: {
                        Label("Delete Pet", systemImage: "trash")
                    }
                } label: { Image(systemName: "ellipsis.circle") }
            }
        }
        .sheet(isPresented: $showLogMetric)   { LogMetricView(vm: vm, petId: pet.id) }
        .sheet(isPresented: $showEdit)        { EditPetView(vm: listVM, pet: pet) }
        .sheet(isPresented: $showPhoto)       { PhotoUploadView(petId: pet.id) }
        .sheet(isPresented: $showMedSchedule) { MedicationScheduleView(pet: pet) }
        .confirmationDialog("Delete \(pet.name)?", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
            Button("Delete", role: .destructive) { Task { await listVM.deletePet(petId: pet.id); dismiss() } }
            Button("Cancel", role: .cancel) {}
        } message: { Text("This will permanently delete \(pet.name) and all health records.") }
        .task { await vm.loadMetrics(petId: pet.id) }
    }
}

struct MetricRowView: View {
    let metric: HealthMetric
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text(metric.type.displayName).font(.headline)
                Spacer()
                Text("\(metric.value) \(metric.unit)").font(.subheadline).bold()
            }
            Text(metric.timestamp.prefix(10)).font(.caption).foregroundColor(.secondary)
            if !metric.notes.isEmpty { Text(metric.notes).font(.caption).foregroundColor(.secondary) }
        }
        .padding(.vertical, 2)
    }
}
