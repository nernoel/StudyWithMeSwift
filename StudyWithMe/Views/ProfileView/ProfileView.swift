import SwiftUI
import Supabase
import Foundation

struct ProfileView: View {

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

    @State private var showEditProfile = false
    @State private var showFriendsList = false

    @State private var username: String = ""
    @State private var fullName: String = ""
    @State private var bio: String = ""
    @State private var major: String = ""
    @State private var university: String = ""
    @State private var avatarUrl: String = ""

    @StateObject private var friendsViewModel = FriendsViewModel()
    @State private var avatarURLs: [UUID: String] = [:]

    private let supabase = SupabaseManager.shared.client

    // MARK: - Fetch Profile
    func getProfileData() async {
        do {
            let currentUser = try await supabase.auth.session.user

            let profile: UserProfile = try await supabase.database
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
                    .createSignedURL(path: avatarPath, expiresIn: 60)
                self.avatarUrl = signedURL.absoluteString
            }

        } catch {
            print("Error fetching profile:", error.localizedDescription)
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {

                    // MARK: - Avatar & Basic Info
                    if !avatarUrl.isEmpty, let url = URL(string: avatarUrl) {
                        AsyncImage(url: url) { image in
                            image.resizable().scaledToFill()
                        } placeholder: {
                            Circle().fill(Color.gray.opacity(0.3))
                        }
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                    } else {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 100, height: 100)
                    }

                    Text(fullName)
                        .font(.title3)
                        .fontWeight(.semibold)

                    Text("@\(username)")
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    Text(bio)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    HStack(spacing: 10) {
                        profileTag(text: major)
                        profileTag(text: university)
                    }

                    Button("Edit Profile") {
                        showEditProfile.toggle()
                    }
                    .font(.caption)
                    .bold()
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.blue.opacity(0.15))
                    .foregroundColor(.blue)
                    .cornerRadius(10)

                    Divider()

                    // MARK: - Friends Section
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Your Friends")
                                .font(.headline)
                            Spacer()
                            Button("Manage") {
                                showFriendsList.toggle()
                            }
                        }

                        if friendsViewModel.friendsList.isEmpty {
                            Text("You have no friends yet.")
                                .foregroundColor(.gray)
                        } else {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(friendsViewModel.allUsers.filter { friendsViewModel.friendsList.contains($0.id) }) { friend in
                                        VStack {
                                            if let urlString = avatarURLs[friend.id],
                                               let url = URL(string: urlString) {
                                                AsyncImage(url: url) { image in
                                                    image.resizable().scaledToFill()
                                                } placeholder: {
                                                    Circle().fill(Color.gray.opacity(0.3))
                                                }
                                                .frame(width: 50, height: 50)
                                                .clipShape(Circle())
                                            } else {
                                                Circle()
                                                    .fill(Color.gray.opacity(0.3))
                                                    .frame(width: 50, height: 50)
                                                    .task {
                                                        await fetchSignedAvatar(for: friend)
                                                    }
                                            }

                                            Text(friend.fullName ?? "")
                                                .font(.caption)
                                            
                                            /*
                                            Button("Remove") {
                                                Task {
                                                    await friendsViewModel.removeFriend(userId: friend.id)
                                                }
                                            }
                                            .buttonStyle(.borderedProminent)
                                            .tint(.red)
                                             */
                                        }
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Profile")
            .sheet(isPresented: $showEditProfile) { EditProfileView() }
            .sheet(isPresented: $showFriendsList) {
                FriendsListView(viewModel: friendsViewModel, invitedFriends: .constant([]))
            }
            .task {
                await getProfileData()
                await friendsViewModel.fetchAllUsers()
                await friendsViewModel.fetchFriends()
            }
        }
    }

    // MARK: - Profile Tag
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

    // MARK: - Fetch single signed URL
    private func fetchSignedAvatar(for user: FriendsViewModel.AppUser) async {
        guard let path = user.avatarUrl else { return }
        do {
            let signedURL = try await supabase.storage
                .from("avatars")
                .createSignedURL(path: path, expiresIn: 60)
            await MainActor.run {
                avatarURLs[user.id] = signedURL.absoluteString
            }
        } catch {
            print("Failed to load avatar for \(user.username):", error)
        }
    }
}

#Preview {
    ProfileView()
}
