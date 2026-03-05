import SwiftUI
import PhotosUI
import Storage
import Supabase

struct EditProfileView: View {
    private let supabase = SupabaseManager.shared.client
    struct UserProfile: Identifiable, nonisolated Decodable {
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
    
    @State private var username: String = ""
    @State private var fullName: String = ""
    @State private var bio: String = ""
    @State private var major: String = ""
    @State private var university: String = ""
    @State private var avatarUrl: String = ""
    
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil
    
    @StateObject private var viewModel = EditProfileViewModel()
    
    @State var showEditUsername: Bool = false
    @State var showEditFullName: Bool = false
    @State var showEditMajor: Bool = false
    @State var showEditUniversity: Bool = false
    @State var showEditBio: Bool = false
    
    
    // MARK: - Fetch Profile
    func getProfileData() async {
        do {
            let currentUser = try await supabase.auth.session.user
            
            let profile: UserProfile =
            try await supabase.database
                .from("profiles")
                .select()
                .eq("id", value: currentUser.id)
                .single()
                .execute()
                .value
            
            self.username = profile.username ?? ""
            self.fullName = profile.fullName ?? ""
            self.bio = profile.bio ?? ""
            self.major = profile.major ?? ""
            self.university = profile.university ?? ""
            
            if let avatarPath = profile.avatarUrl {
                let signedURL = try await supabase.storage
                    .from("avatars")
                    .createSignedURL(path: avatarPath, expiresIn: 3600)
                
                self.avatarUrl = signedURL.absoluteString
            }
            
        } catch {
            print("Error fetching profile:", error.localizedDescription)
        }
    }
    
    func refreshProfile() {
        Task {
            await getProfileData()
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                
                VStack(spacing: 30) {
                    
                    // MARK: - Avatar
                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        AvatarView(avatarURL: avatarUrl)
                            .overlay(
                                Circle()
                                    .stroke(Color.pink.opacity(0.4), lineWidth: 3)
                            )
                            .shadow(color: .blue.opacity(0.2), radius: 8, x: 0, y: 4)
                    }
                    .onChange(of: selectedItem) {
                        Task {
                            await viewModel.handleImageSelection( selectedItem)
                        }
                    }
                    
                    // MARK: - Info Section
                    VStack(spacing: 0) {
                        
                        profileRow(value: username, title: "Username") {
                            showEditUsername = true
                        }
                        
                        Divider()
                        
                        profileRow(value: fullName, title: "Full name") {
                            showEditFullName = true
                        }
                        
                        Divider()
                        
                        profileRow(value: major, title: "Major") {
                            showEditMajor = true
                        }
                        
                        Divider()
                        
                        profileRow(value: university, title: "University") {
                            showEditUniversity = true
                        }
                        
                        Divider()
                        
                        profileRow(value: bio, title: "Bio") {
                            showEditBio = true
                        }
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
                    
                    Spacer()
                }
                .padding()
                .blur(radius: showEditUsername ? 10 : 0)
                
                // MARK: - Modals
                
                if showEditUsername {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture {
                            showEditUsername = false
                        }
                    
                    EditUsernameView(showEditUsernameView: $showEditUsername)
                        .frame(width: 300)
                        .padding()
                    
                }
                
                if showEditFullName {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture { showEditFullName = false }
                    
                    EditFullNameView(showEditFullNameView: $showEditFullName)
                }
                
                if showEditMajor {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture { showEditMajor = false }
                    
                    EditMajorView(showEditMajorView: $showEditMajor)
                }
                
                if showEditUniversity {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture { showEditUniversity = false }
                    
                    EditUniversityView(showEditUniversityView: $showEditUniversity)
                }
                
                if showEditBio {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture { showEditBio = false }
                    
                    EditBioView(showEditBioView: $showEditBio)
                }
            }
            .navigationTitle("Edit Profile")
            .task {
                await getProfileData()
            }
        }
    }
    
    // MARK: - Reusable Styled Row
    private func profileRow(value: String?, title: String, action: @escaping () -> Void) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.gray)
                
                Text(value?.isEmpty == false ? value! : "Not set")
                    .font(.system(size: 16))
                    .foregroundColor(.primary)
            }
            
            Spacer()
            
            Image(systemName: "pencil.circle.fill")
                .font(.system(size: 20))
                .foregroundColor(.blue)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            action()
        }
    }
}

#Preview {
    EditProfileView()
}
