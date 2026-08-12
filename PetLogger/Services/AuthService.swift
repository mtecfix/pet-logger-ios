import Foundation

class AuthService: ObservableObject {
    static let shared = AuthService()

    @Published var isAuthenticated = false
    @Published var currentUserId: String? = nil

    private let poolId   = Config.cognitoPoolId
    private let clientId = Config.cognitoClient
    private let region   = Config.awsRegion

    var authEndpoint: String {
        "https://cognito-idp.\(region).amazonaws.com/"
    }

    func signIn(email: String, password: String) async throws {
        let body: [String: Any] = [
            "AuthFlow": "USER_PASSWORD_AUTH",
            "ClientId": clientId,
            "AuthParameters": ["USERNAME": email, "PASSWORD": password]
        ]

        guard let url = URL(string: authEndpoint) else { throw APIError.invalidURL }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/x-amz-json-1.1", forHTTPHeaderField: "Content-Type")
        req.setValue("AWSCognitoIdentityProviderService.InitiateAuth", forHTTPHeaderField: "X-Amz-Target")
        req.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, _) = try await URLSession.shared.data(for: req)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        let result = json?["AuthenticationResult"] as? [String: Any]
        let token  = result?["IdToken"] as? String ?? ""
        let access = result?["AccessToken"] as? String ?? ""

        // Parse userId from JWT payload
        let parts = token.components(separatedBy: ".")
        if parts.count > 1, let payloadData = Data(base64Encoded: parts[1] + String(repeating: "=", count: (4 - parts[1].count % 4) % 4)) {
            let payload = try? JSONSerialization.jsonObject(with: payloadData) as? [String: Any]
            await MainActor.run {
                self.currentUserId = payload?["sub"] as? String
                self.isAuthenticated = true
            }
        }

        APIService.shared.setToken(token)
    }

    func signOut() {
        isAuthenticated = false
        currentUserId = nil
        APIService.shared.setToken("")
    }
}
