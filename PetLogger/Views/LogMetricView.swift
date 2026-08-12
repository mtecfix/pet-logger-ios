import SwiftUI

struct LogMetricView: View {
    @ObservedObject var vm: MetricsViewModel
    let petId: String
    @Environment(\.dismiss) private var dismiss
    @State private var selectedType = MetricType.weight
    @State private var value = ""
    @State private var notes = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Metric") {
                    Picker("Type", selection: $selectedType) {
                        ForEach(MetricType.allCases, id: \.self) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                    HStack {
                        TextField("Value", text: $value)
                            .keyboardType(.decimalPad)
                        Text(selectedType.unit)
                            .foregroundColor(.secondary)
                    }
                }
                Section("Notes (optional)") {
                    TextEditor(text: $notes)
                        .frame(height: 80)
                }
            }
            .navigationTitle("Log Metric")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Log") {
                        Task {
                            await vm.logMetric(petId: petId, type: selectedType, value: value, notes: notes)
                            dismiss()
                        }
                    }
                    .disabled(value.isEmpty)
                }
            }
        }
    }
}
