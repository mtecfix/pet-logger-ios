import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL, noToken, requestFailed(Int, String), decodingFailed(String)
    var errorDescription: String? {
        switch self {
        case .invalidURL:                   return "Invalid URL"
        case .noToken:                      return "Not authenticated"
        case .requestFailed(let c, let m):  return "Request failed (\(c)): \(m)"
        case .decodingFailed(let m):        return "Decoding failed: \(m)"
        }
    }
}

class APIService {
    static let shared = APIService()
    private let baseURL = Config.apiEndpoint
    private var authToken: String? = nil

    func setToken(_ token: String) { self.authToken = token }

    private func request<T: Decodable>(_ path: String, method: String = "GET", body: Encodable? = nil) async throws -> T {
        guard let url = URL(string: "\(baseURL)\(path)") else { throw APIError.invalidURL }
        var req = URLRequest(url: url)
        req.httpMethod = method
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = authToken { req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization") }
        if let body = body { req.httpBody = try JSONEncoder().encode(body) }
        let (data, response) = try await URLSession.shared.data(for: req)
        let http = response as! HTTPURLResponse
        guard (200...299).contains(http.statusCode) else {
            throw APIError.requestFailed(http.statusCode, String(data: data, encoding: .utf8) ?? "")
        }
        do { return try JSONDecoder().decode(T.self, from: data) }
        catch { throw APIError.decodingFailed(error.localizedDescription) }
    }

    // MARK: - Pets
    func getPets() async throws -> [Pet] {
        struct R: Decodable { let pets: [Pet] }
        return try await (request("/pets") as R).pets
    }

    func createPet(_ r: CreatePetRequest) async throws -> Pet {
        struct R: Decodable { let pet: Pet }
        return try await (request("/pets", method: "POST", body: r) as R).pet
    }

    func updatePet(petId: String, name: String, species: String, breed: String, weight: Double?) async throws {
        struct Body: Encodable { let name: String; let species: String; let breed: String; let weight: Double? }
        struct R: Decodable { let updated: Bool }
        let encoded = petId.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? petId
        let _: R = try await request("/pets/\(encoded)", method: "PUT", body: Body(name: name, species: species, breed: breed, weight: weight))
    }

    func deletePet(petId: String) async throws {
        struct R: Decodable { let deleted: Bool }
        let encoded = petId.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? petId
        let _: R = try await request("/pets/\(encoded)", method: "DELETE")
    }

    // MARK: - Metrics
    func getMetrics(petId: String) async throws -> [HealthMetric] {
        struct R: Decodable { let metrics: [HealthMetric] }
        let encoded = petId.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? petId
        return try await (request("/metrics/\(encoded)") as R).metrics
    }

    func logMetric(_ r: LogMetricRequest) async throws -> HealthMetric {
        struct R: Decodable { let metric: HealthMetric }
        return try await (request("/metrics", method: "POST", body: r) as R).metric
    }

    func deleteMetric(metricId: String) async throws {
        struct R: Decodable { let deleted: Bool }
        let encoded = metricId.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? metricId
        let _: R = try await request("/metrics/\(encoded)", method: "DELETE")
    }

    // MARK: - Export
    func exportHistory(petId: String) async throws -> URL {
        struct R: Decodable { let downloadUrl: String }
        let encoded = petId.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? petId
        let r: R = try await request("/export/\(encoded)")
        guard let url = URL(string: r.downloadUrl) else { throw APIError.invalidURL }
        return url
    }

    // MARK: - Photo Upload
    func getPhotoUploadURL() async throws -> (uploadUrl: String, key: String) {
        struct R: Decodable { let uploadUrl: String; let key: String }
        let r: R = try await request("/photo-upload")
        return (r.uploadUrl, r.key)
    }
}
