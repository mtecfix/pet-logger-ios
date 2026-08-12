import SwiftUI

struct LoginView: View {
    @StateObject private var auth = AuthService.shared
    @State private var email    = ""
    @State private var password = ""
    @State private var error: String? = nil
    @State private var loading = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "pawprint.fill")
                    .font(.system(size: 64))
                    .foregroundColor(.blue)

                Text("Pet Logger")
                    .font(.largeTitle.bold())

                VStack(spacing: 12) {
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .textFieldStyle(.roundedBorder)

                    SecureField("Password", text: $password)
                        .textFieldStyle(.roundedBorder)
                }
                .padding(.horizontal)

                if let error = error {
                    Text(error).foregroundColor(.red).font(.caption)
                }

                Button(action: signIn) {
                    if loading {
                        ProgressView()
                    } else {
                        Text("Sign In").frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.borderedProminent)
                .padding(.horizontal)
                .disabled(loading)
            }
            .padding()
            .navigationTitle("Welcome")
        }
    }

    func signIn() {
        loading = true
        error = nil
        Task {
            do {
                try await auth.signIn(email: email, password: password)
            } catch {
                self.error = error.localizedDescription
            }
            loading = false
        }
    }
}
