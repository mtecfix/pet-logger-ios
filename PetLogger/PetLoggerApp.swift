import SwiftUI

@main
struct PetLoggerApp: App {
    @StateObject private var notif = NotificationManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    Task { await notif.requestPermission() }
                }
        }
    }
}
