import SwiftUI

/// Drop-in offline indicator banner
struct OfflineBanner: View {
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "wifi.slash").foregroundColor(.white)
            Text("Offline — showing cached data").font(.caption).foregroundColor(.white)
            Spacer()
        }
        .padding(.horizontal).padding(.vertical, 6)
        .background(Color.orange)
    }
}
