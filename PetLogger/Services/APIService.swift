import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case noToken
    case requestFailed(Int, String)
    case decodingFailed(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:              return "Invalid URL"
        case .noToken:                 return "Not authenticated"
        case .requestFailed(let c, let m): return "Request failed (\(c)): \(m)"
        case .decodingFailed(let m):   return "Decoding failed: \(m)"
        }
    }
}

class APIService {
    static let shared = APIService()
    private let baseURL = Config.apiEndpoint
    private var authToken: String? = nil

    func setToken(_ token: String) {
        self.authToken = token
    }

    private func request<T: Decodable>(
        path: String,
        method: String = "GET",
        body: Encodable? = nil
    ) async throws -> T {
        guard let url = URL(string: "\(baseURL)\(path)") else {
            throw APIError.invalidURL
        }

        var req = URLRequest(url: url)
        req.httpMethod = method
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = authToken {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        if let body = body {
            req.httpBody = try JSONEncoder().encode(body)
        }

        let (data, response) = try await URLSession.shared.data(for: req)
        let http = response as! HTTPURLResponse

        guard (200...299).contains(http.statusCode) else {
            let msg = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw APIError.requestFailed(http.statusCode, msg)
        }

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw APIError.decodingFailed(error.localizedDescription)
        }
    }

    // MARK: - Pets
    func getPets() async throws -> [Pet] {
        struct Response: Decodable { let pets: [Pet] }
        let res: Response = try await request(path: "/pets")
        return res.pets
    }

    func createPet(_ req: CreatePetRequest) async throws -> Pet {
        struct Response: Decodable { let pet: Pet }
        let res: Response = try await request(path: "/pets", method: "POST", body: req)
        return res.pet
    }

    // MARK: - Metrics
    func getMetrics(petId: String) async throws -> [HealthMetric] {
        struct Response: Decodable { let metrics: [HealthMetric] }
        let encoded = petId.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? petId
        let res: Response = try await request(path: "/metrics/\(encoded)")
        return res.metrics
    }

    func logMetric(_ req: LogMetricRequest) async throws -> HealthMetric {
        struct Response: Decodable { let metric: HealthMetric }
        let res: Response = try await request(path: "/metrics", method: "POST", body: req)
        return res.metric
    }

    // MARK: - Export
    func exportHistory(petId: String) async throws -> URL {
        struct Response: Decodable { let downloadUrl: String }
        let encoded = petId.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? petId
        let res: Response = try await request(path: "/export/\(encoded)")
        guard let url = URL(string: res.downloadUrl) else { throw APIError.invalidURL }
        return url
    }
}
