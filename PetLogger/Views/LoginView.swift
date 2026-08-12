import SwiftUI

struct LoginView: View {
    @StateObject private var auth = AuthService.shared
    @State private var email    = ""
    @State private var password = ""
    @State private var error: String? = nil
    @State private var loading  = false
    @State private var showSignUp       = false
    @State private var showForgotPass   = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                Image(systemName: "pawprint.fill")
                    .font(.system(size: 64))
                    .foregroundColor(.blue)

                Text("Pet Logger")
                    .font(.largeTitle.bold())

                Text("Track your pet's health in one place")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

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
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                Button(action: signIn) {
                    if loading {
                        ProgressView().frame(maxWidth: .infinity)
                    } else {
                        Text("Sign In").frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(email.isEmpty || password.isEmpty || loading)
                .padding(.horizontal)

                Button("Forgot Password?") { showForgotPass = true }
                    .font(.caption)
                    .foregroundColor(.blue)

                Divider().padding(.horizontal)

                HStack {
                    Text("Don't have an account?")
                        .foregroundColor(.secondary)
                    Button("Sign Up") { showSignUp = true }
                        .fontWeight(.semibold)
                }
                .font(.subheadline)

                Spacer()
            }
            .sheet(isPresented: $showSignUp) { SignUpView() }
            .sheet(isPresented: $showForgotPass) { ForgotPasswordView() }
        }
    }

    func signIn() {
        loading = true; error = nil
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

