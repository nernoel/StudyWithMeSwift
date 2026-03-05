import SwiftUI
import PhotosUI
import Supabase
import Combine

@MainActor
class EditProfileViewModel: ObservableObject {
    private let supabase = SupabaseManager.shared.client
    
    @Published var userName: String?
    @Published var fullName: String?
    @Published var bio: String?
    @Published var major: String?
    @Published var university: String?
    
    @Published var selectedImageData: Data?
    @Published var avatarUrl: String?
    
    func handleImageSelection(_ item: PhotosPickerItem?) async {
        guard let item else { return }
        
        do {
            if let data = try await item.loadTransferable(type: Data.self) {
                selectedImageData = data
                try await uploadAvatar(data: data)
            }
        } catch {
            print("Image error:", error)
        }
    }
    
    private func uploadAvatar(data: Data) async throws {
        let filePath = "\(UUID().uuidString).jpeg"
        
        try await supabase.storage
            .from("avatars")
            .upload(
                path: filePath,
                file: data,
                options: FileOptions(contentType: "image/jpeg")
            )
        
        avatarUrl = filePath
        
        
        try await supabase.database
            .from("profiles")
            .update(["avatar_url": filePath])
            .eq("id", value: supabase.auth.session.user.id)
            .execute()
    }
}


