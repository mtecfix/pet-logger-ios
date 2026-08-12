import Foundation

@MainActor
class MetricsViewModel: ObservableObject {
    @Published var metrics: [HealthMetric] = []
    @Published var isLoading = false
    @Published var error: String? = nil

    func loadMetrics(petId: String) async {
        isLoading = true; error = nil
        do { metrics = try await APIService.shared.getMetrics(petId: petId) }
        catch { self.error = error.localizedDescription }
        isLoading = false
    }

    func logMetric(petId: String, type: MetricType, value: String, notes: String = "") async {
        let req = LogMetricRequest(petId: petId, type: type, value: value, unit: type.unit, notes: notes)
        do { let m = try await APIService.shared.logMetric(req); metrics.insert(m, at: 0) }
        catch { self.error = error.localizedDescription }
    }

    func deleteMetric(metricId: String) async {
        do {
            try await APIService.shared.deleteMetric(metricId: metricId)
            metrics.removeAll { $0.id == metricId }
        } catch {
            self.error = error.localizedDescription
        }
    }

    func exportHistory(petId: String) async -> URL? {
        do { return try await APIService.shared.exportHistory(petId: petId) }
        catch { self.error = error.localizedDescription; return nil }
    }
}
