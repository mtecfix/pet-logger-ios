import SwiftUI

struct LaunchScreenView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.18, green: 0.45, blue: 0.98),
                         Color(red: 0.12, green: 0.30, blue: 0.72)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.15))
                        .frame(width: 130, height: 130)
                    Image(systemName: "pawprint.fill")
                        .font(.system(size: 64, weight: .semibold))
                        .foregroundColor(.white)
                }

                VStack(spacing: 6) {
                    Text("Pet Logger")
                        .font(.system(size: 38, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Text("Health tracking for your pets")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.80))
                }
            }
        }
    }
}
