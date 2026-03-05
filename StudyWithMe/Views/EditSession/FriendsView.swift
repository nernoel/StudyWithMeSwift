import SwiftUI
import Supabase

// MARK: - Sheet Model
struct ConversationSheet: Identifiable {
    let id: UUID
    let friendName: String?
}

struct FriendsView: View {
    
    @StateObject private var viewModel = FriendsViewModel()
    @State private var selectedConversation: ConversationSheet?
    
    // Store signed URLs for avatars
    @State private var avatarURLs: [UUID: String] = [:]
    
    private let supabase = SupabaseManager.shared.client
    
    var body: some View {
        NavigationStack {
            
            VStack(alignment: .leading, spacing: 15) {
                
                // Title
                Text("Friends")
                    .font(.largeTitle)
                    .bold()
                    .padding(.horizontal)
                
                // Description
                Text("Chat with your friends here. Only friends appear in this list.")
                    .font(.subheadline)
                    .foregroundColor(.gray.opacity(0.7))
                    .lineLimit(2)
                    .padding(.horizontal)
                
                ScrollView {
                    LazyVStack(spacing: 12) {
                        
                        let friends = viewModel.allUsers.filter { viewModel.isFriend($0) }
                        
                        if friends.isEmpty {
                            Text("You have no friends yet.")
                                .foregroundColor(.gray)
                                .padding()
                        } else {
                            ForEach(friends) { user in
                                HStack(spacing: 12) {
                                    
                                    // MARK: - Avatar
                                    if let urlString = avatarURLs[user.id],
                                       let url = URL(string: urlString) {
                                        AsyncImage(url: url) { image in
                                            image.resizable().scaledToFill()
                                        } placeholder: {
                                            Circle().fill(Color.gray.opacity(0.3))
                                        }
                                        .frame(width: 60, height: 60)
                                        .clipShape(Circle())
                                        .onTapGesture {
                                            // Optional: show profile
                                        }
                                    } else {
                                        Circle()
                                            .fill(Color.gray.opacity(0.3))
                                            .frame(width: 60, height: 60)
                                            .task {
                                                await fetchSignedAvatar(for: user)
                                            }
                                    }
                                    
                                    // MARK: Name & Username
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(user.fullName ?? user.username)
                                            .font(.headline)
                                        Text("@\(user.username)")
                                            .foregroundColor(.gray)
                                            .font(.caption)
                                    }
                                    
                                    Spacer()
                                    
                                    // MARK: Chat Button
                                    Button("Chat") {
                                        Task {
                                            do {
                                                let convoId = try await ConversationService.shared
                                                    .getOrCreateConversation(with: user.id)
                                                await MainActor.run {
                                                    selectedConversation = ConversationSheet(
                                                        id: convoId,
                                                        friendName: user.fullName ?? user.username
                                                    )
                                                }
                                            } catch {
                                                print("Conversation error:", error)
                                            }
                                        }
                                    }
                                    .buttonStyle(.borderedProminent)
                                    .tint(.blue)
                                    .font(.caption2)
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.white)
                                        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                                )
                                .padding(.horizontal)
                            }
                        }
                    }
                }
            }
            .padding(.top)
            .background(Color(.systemGroupedBackground))
            .refreshable {
                await viewModel.fetchAllUsers()
                await viewModel.fetchFriends()
                await loadAllAvatars()
            }
            .task {
                await viewModel.fetchAllUsers()
                await viewModel.fetchFriends()
                await loadAllAvatars()
            }
        }
        // Chat sheet
        .sheet(item: $selectedConversation) { convo in
            ChatView(
                conversationId: convo.id,
                friendName: convo.friendName
            )
        }
    }
    
    // MARK: - Fetch signed URL for a single user
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
    
    // MARK: - Preload all avatars
    private func loadAllAvatars() async {
        for user in viewModel.allUsers {
            if viewModel.isFriend(user) {
                await fetchSignedAvatar(for: user)
            }
        }
    }
}

#Preview {
    FriendsView()
}
