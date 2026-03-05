import SwiftUI
import Supabase

struct ProfileDetailView: View {
    
    let userId: UUID
    
    nonisolated
    struct UserProfile: Decodable, Identifiable {
        let id: UUID?
        let username: String?
        let fullName: String?
        let bio: String?
        let major: String?
        let university: String?
        let avatarUrl: String?
        
        enum CodingKeys: String, CodingKey {
            case id
            case username
            case fullName = "full_name"
            case bio
            case major
            case university
            case avatarUrl = "avatar_url"
        }
    }
    
    @State private var profile: UserProfile?
    @State private var signedAvatarUrl: URL? = nil  
    private let supabase = SupabaseClient(
        supabaseURL: URL(string: SupabaseConfig.SUPABASE_URL)!,
        supabaseKey: SupabaseConfig.SUPABASE_KEY
    )
    
    // Fetch the profile and avatar
    func fetchProfile() async {
        do {
            let fetchedProfile: UserProfile =
            try await supabase.database
                .from("profiles")
                .select()
                .eq("id", value: userId)
                .single()
                .execute()
                .value
            
            self.profile = fetchedProfile
            
            
            if let avatarPath = fetchedProfile.avatarUrl {
                let url = try await supabase.storage
                    .from("avatars")
                    .createSignedURL(path: avatarPath, expiresIn: 60)
                self.signedAvatarUrl = url
            }
            
        } catch {
            print("Failed fetching user profile:", error)
        }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            if let profile = profile {
                
                // MARK: - Avatar
                if let url = signedAvatarUrl {
                    AsyncImage(url: url) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        Color.gray.opacity(0.3)
                    }
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                } else {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 100, height: 100)
                }
                
                Text(profile.fullName ?? "")
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Text("@\(profile.username ?? "")")
                    .foregroundColor(.gray)
                
                Text(profile.bio ?? "")
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                HStack(spacing: 10) {
                    if let major = profile.major { profileTag(text: major) }
                    if let uni = profile.university { profileTag(text: uni) }
                }
                
            } else {
                ProgressView("Loading...")
            }
        }
        .padding()
        .task { await fetchProfile() }
        .navigationTitle("Profile")
    }
    
    private func profileTag(text: String) -> some View {
        Text(text)
            .font(.caption)
            .bold()
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Color.orange.opacity(0.1))
            .foregroundColor(.orange)
            .cornerRadius(8)
    }
}

#Preview {
    ProfileDetailView(userId: UUID())
}
