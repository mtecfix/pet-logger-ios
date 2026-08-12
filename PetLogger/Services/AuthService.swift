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

    // MARK: - Sign In
    func signIn(email: String, password: String) async throws {
        let body: [String: Any] = [
            "AuthFlow": "USER_PASSWORD_AUTH",
            "ClientId": clientId,
            "AuthParameters": ["USERNAME": email, "PASSWORD": password]
        ]
        let data = try await cognitoRequest(target: "AWSCognitoIdentityProviderService.InitiateAuth", body: body)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let result = json?["AuthenticationResult"] as? [String: Any],
              let token = result["IdToken"] as? String else {
            let msg = (json?["message"] as? String) ?? "Sign in failed"
            throw AuthError.cognitoError(msg)
        }
        parseAndSetUser(token: token)
        APIService.shared.setToken(token)
    }

    // MARK: - Sign Up
    func signUp(name: String, email: String, password: String) async throws {
        let body: [String: Any] = [
            "ClientId": clientId,
            "Username": email,
            "Password": password,
            "UserAttributes": [
                ["Name": "email", "Value": email],
                ["Name": "name", "Value": name]
            ]
        ]
        let data = try await cognitoRequest(target: "AWSCognitoIdentityProviderService.SignUp", body: body)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        if let err = json?["__type"] as? String {
            throw AuthError.cognitoError(json?["message"] as? String ?? err)
        }
    }

    // MARK: - Confirm Sign Up
    func confirmSignUp(email: String, code: String) async throws {
        let body: [String: Any] = [
            "ClientId": clientId,
            "Username": email,
            "ConfirmationCode": code
        ]
        let data = try await cognitoRequest(target: "AWSCognitoIdentityProviderService.ConfirmSignUp", body: body)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        if let err = json?["__type"] as? String {
            throw AuthError.cognitoError(json?["message"] as? String ?? err)
        }
    }

    // MARK: - Resend Confirmation Code
    func resendConfirmationCode(email: String) async throws {
        let body: [String: Any] = [
            "ClientId": clientId,
            "Username": email
        ]
        let data = try await cognitoRequest(target: "AWSCognitoIdentityProviderService.ResendConfirmationCode", body: body)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        if let err = json?["__type"] as? String {
            throw AuthError.cognitoError(json?["message"] as? String ?? err)
        }
    }

    // MARK: - Forgot Password
    func forgotPassword(email: String) async throws {
        let body: [String: Any] = [
            "ClientId": clientId,
            "Username": email
        ]
        let data = try await cognitoRequest(target: "AWSCognitoIdentityProviderService.ForgotPassword", body: body)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        if let err = json?["__type"] as? String {
            throw AuthError.cognitoError(json?["message"] as? String ?? err)
        }
    }

    // MARK: - Confirm Forgot Password
    func confirmForgotPassword(email: String, code: String, newPassword: String) async throws {
        let body: [String: Any] = [
            "ClientId": clientId,
            "Username": email,
            "ConfirmationCode": code,
            "Password": newPassword
        ]
        let data = try await cognitoRequest(target: "AWSCognitoIdentityProviderService.ConfirmForgotPassword", body: body)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        if let err = json?["__type"] as? String {
            throw AuthError.cognitoError(json?["message"] as? String ?? err)
        }
    }

    // MARK: - Sign Out
    func signOut() {
        isAuthenticated = false
        currentUserId = nil
        APIService.shared.setToken("")
    }

    // MARK: - Helpers
    private func cognitoRequest(target: String, body: [String: Any]) async throws -> Data {
        guard let url = URL(string: authEndpoint) else { throw AuthError.invalidURL }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/x-amz-json-1.1", forHTTPHeaderField: "Content-Type")
        req.setValue(target, forHTTPHeaderField: "X-Amz-Target")
        req.httpBody = try JSONSerialization.data(withJSONObject: body)
        let (data, _) = try await URLSession.shared.data(for: req)
        return data
    }

    private func parseAndSetUser(token: String) {
        let parts = token.components(separatedBy: ".")
        guard parts.count > 1 else { return }
        var base64 = parts[1]
        let remainder = base64.count % 4
        if remainder > 0 { base64 += String(repeating: "=", count: 4 - remainder) }
        guard let payloadData = Data(base64Encoded: base64),
              let payload = try? JSONSerialization.jsonObject(with: payloadData) as? [String: Any] else { return }
        DispatchQueue.main.async {
            self.currentUserId = payload["sub"] as? String
            self.isAuthenticated = true
        }
    }
}

enum AuthError: Error, LocalizedError {
    case invalidURL
    case cognitoError(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .cognitoError(let msg): return msg
        }
    }
}

