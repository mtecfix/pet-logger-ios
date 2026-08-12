import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            PetListView()
                .tabItem {
                    Label("Pets", systemImage: "pawprint.fill")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}
