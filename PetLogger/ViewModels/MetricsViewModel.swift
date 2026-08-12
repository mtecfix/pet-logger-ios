import Foundation

@MainActor
class MetricsViewModel: ObservableObject {
    @Published var metrics: [HealthMetric] = []
    @Published var isLoading = false
    @Published var error: String? = nil
    @Published var isOffline = false

    func loadMetrics(petId: String) async {
        let key = "cached_metrics_\(petId)"
        if let cached = LocalCache.shared.load(HealthMetric.self, key: key) {
            metrics = cached
        }
        isLoading = true; error = nil
        do {
            metrics = try await APIService.shared.getMetrics(petId: petId)
            LocalCache.shared.save(metrics, key: key)
            isOffline = false
        } catch {
            if metrics.isEmpty { self.error = error.localizedDescription }
            isOffline = true
        }
        isLoading = false
    }

    func logMetric(petId: String, type: MetricType, value: String, notes: String = "") async {
        let req = LogMetricRequest(petId: petId, type: type, value: value, unit: type.unit, notes: notes)
        do {
            let m = try await APIService.shared.logMetric(req)
            metrics.insert(m, at: 0)
            let key = "cached_metrics_\(petId)"
            LocalCache.shared.save(metrics, key: key)
        } catch { self.error = error.localizedDescription }
    }

    func deleteMetric(metricId: String) async {
        do {
            try await APIService.shared.deleteMetric(metricId: metricId)
            metrics.removeAll { $0.id == metricId }
        } catch { self.error = error.localizedDescription }
    }

    func exportHistory(petId: String) async -> URL? {
        do { return try await APIService.shared.exportHistory(petId: petId) }
        catch { self.error = error.localizedDescription; return nil }
    }
}
