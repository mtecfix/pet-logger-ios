import SwiftUI

struct SettingsView: View {
    @StateObject private var auth = AuthService.shared

    var body: some View {
        NavigationStack {
            Form {
                Section("Account") {
                    if let userId = auth.currentUserId {
                        LabeledContent("User ID", value: String(userId.prefix(8)) + "...")
                    }
                    Button("Sign Out", role: .destructive) {
                        auth.signOut()
                    }
                }
                Section("App") {
                    LabeledContent("Version", value: "1.0.0")
                    LabeledContent("Environment", value: "Development")
                }
            }
            .navigationTitle("Settings")
        }
    }
}
