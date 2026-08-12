import SwiftUI

struct PetDetailView: View {
    let pet: Pet
    @StateObject private var vm = MetricsViewModel()
    @State private var showLogMetric = false
    @State private var exportURL: URL? = nil

    var body: some View {
        List {
            Section("Profile") {
                LabeledContent("Name", value: pet.name)
                LabeledContent("Species", value: pet.species.capitalized)
                LabeledContent("Breed", value: pet.breed)
                if let weight = pet.weight {
                    LabeledContent("Weight", value: "\(weight) lbs")
                }
            }

            Section("Health Log") {
                if vm.isLoading {
                    ProgressView()
                } else if vm.metrics.isEmpty {
                    Text("No metrics logged yet")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(vm.metrics) { metric in
                        MetricRowView(metric: metric)
                    }
                }
            }
        }
        .navigationTitle(pet.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button(action: { showLogMetric = true }) {
                    Image(systemName: "plus.circle")
                }
                Button(action: exportHistory) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
        .sheet(isPresented: $showLogMetric) {
            LogMetricView(vm: vm, petId: pet.id)
        }
        .task {
            await vm.loadMetrics(petId: pet.id)
        }
    }

    func exportHistory() {
        Task {
            exportURL = await vm.exportHistory(petId: pet.id)
        }
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
            if !metric.notes.isEmpty {
                Text(metric.notes).font(.caption).foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
}
