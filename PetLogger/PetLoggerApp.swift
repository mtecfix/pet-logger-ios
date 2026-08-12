import SwiftUI

@main
struct PetLoggerApp: App {
    @StateObject private var notif = NotificationManager.shared
    @State private var showLaunch = true

    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView()
                if showLaunch {
                    LaunchScreenView()
                        .transition(.opacity)
                        .zIndex(1)
                }
            }
            .onAppear {
                Task { await notif.requestPermission() }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                    withAnimation(.easeOut(duration: 0.5)) { showLaunch = false }
                }
            }
        }
    }
}
