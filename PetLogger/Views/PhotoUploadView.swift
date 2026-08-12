import SwiftUI
import UIKit

struct PhotoUploadView: View {
    let petId: String
    @Environment(\.dismiss) private var dismiss
    @State private var selectedImage: UIImage? = nil
    @State private var showPicker = false
    @State private var uploading  = false
    @State private var uploaded   = false
    @State private var error: String? = nil

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 300)
                        .cornerRadius(12)
                        .padding()
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray5))
                        .frame(height: 200)
                        .overlay(
                            VStack(spacing: 8) {
                                Image(systemName: "photo.badge.plus")
                                    .font(.system(size: 48))
                                    .foregroundColor(.secondary)
                                Text("Tap to select a photo")
                                    .foregroundColor(.secondary)
                            }
                        )
                        .padding()
                        .onTapGesture { showPicker = true }
                }

                if uploaded {
                    Label("Photo uploaded!", systemImage: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }

                if let e = error {
                    Text(e).foregroundColor(.red).font(.caption).padding(.horizontal)
                }

                HStack(spacing: 16) {
                    Button("Choose Photo") { showPicker = true }
                        .buttonStyle(.bordered)
                    if selectedImage != nil {
                        Button(action: upload) {
                            if uploading { ProgressView() } else { Text("Upload") }
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(uploading)
                    }
                }
                Spacer()
            }
            .navigationTitle("Pet Photo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Done") { dismiss() } }
            }
            .sheet(isPresented: $showPicker) { ImagePicker(image: $selectedImage) }
        }
    }

    func upload() {
        guard let image = selectedImage,
              let imageData = image.jpegData(compressionQuality: 0.8) else { return }
        uploading = true; error = nil
        Task {
            do {
                let info = try await APIService.shared.getPhotoUploadURL()
                guard let url = URL(string: info.uploadUrl) else { throw URLError(.badURL) }
                var req = URLRequest(url: url)
                req.httpMethod = "PUT"
                req.setValue("image/jpeg", forHTTPHeaderField: "Content-Type")
                req.httpBody = imageData
                let (_, resp) = try await URLSession.shared.data(for: req)
                guard (200...299).contains((resp as! HTTPURLResponse).statusCode) else {
                    throw URLError(.badServerResponse)
                }
                uploaded = true
            } catch {
                self.error = error.localizedDescription
            }
            uploading = false
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let p = UIImagePickerController()
        p.delegate = context.coordinator
        p.sourceType = .photoLibrary
        return p
    }
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    func makeCoordinator() -> Coordinator { Coordinator(self) }
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        init(_ p: ImagePicker) { parent = p }
        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let img = info[.originalImage] as? UIImage { parent.image = img }
            picker.dismiss(animated: true)
        }
    }
}
