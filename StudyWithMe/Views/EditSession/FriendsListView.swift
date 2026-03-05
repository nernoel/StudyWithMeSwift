import SwiftUI

struct FriendsListView: View {

    @ObservedObject var viewModel: FriendsViewModel
    @Binding var invitedFriends: Set<UUID>

    var body: some View {

        NavigationStack {

            VStack(alignment: .leading, spacing: 15) {

                // Title
                Text("Friends")
                    .font(.largeTitle)
                    .bold()
                    .padding()

                // Description below title
                Text("Discover friends, add new ones, or manage your existing connections.")
                    .font(.subheadline)
                    .foregroundColor(.gray.opacity(0.7))
                    .lineLimit(2)
                    .padding()

                // List
                ScrollView {
                    LazyVStack(spacing: 12) {

                        if viewModel.allUsers.isEmpty {
                            Text("No users found.")
                                .foregroundColor(.gray)
                                .padding()
                        } else {

                            ForEach(viewModel.allUsers) { user in

                                HStack(spacing: 12) {

                                    // MARK: Avatar
                                    if let urlString = viewModel.avatarURLs[user.id],
                                       let url = URL(string: urlString) {

                                        AsyncImage(url: url) { image in
                                            image
                                                .resizable()
                                                .scaledToFill()
                                        } placeholder: {
                                            Circle()
                                                .fill(Color.gray.opacity(0.3))
                                        }
                                        .frame(width: 60, height: 60)
                                        .clipShape(Circle())

                                    } else {

                                        Circle()
                                            .fill(Color.gray.opacity(0.3))
                                            .frame(width: 60, height: 60)

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

                                    // MARK: Add / Remove Friend
                                    if viewModel.isFriend(user) {

                                        Button("Remove") {
                                            Task {
                                                await viewModel.removeFriend(userId: user.id)
                                            }
                                        }
                                        .buttonStyle(.borderedProminent)
                                        .tint(.red)
                                        .font(.caption2)

                                    } else {

                                        VStack(spacing: 4) {
                                            Text("Not a friend")
                                                .font(.caption2)
                                                .foregroundColor(.gray)
                                                .padding(.horizontal, 6)
                                                .padding(.vertical, 2)
                                                .background(Color.gray.opacity(0.15))
                                                .cornerRadius(6)

                                            Button("Add") {
                                                Task {
                                                    await viewModel.addFriend(userId: user.id)
                                                }
                                            }
                                            .buttonStyle(.borderedProminent)
                                            .tint(.green)
                                            .font(.caption2)
                                        }
                                    }
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
            }
            .task {
                await viewModel.fetchAllUsers()
                await viewModel.fetchFriends()
            }
        }
    }
}

#Preview {
    let dummyVM = FriendsViewModel()
    let user1 = FriendsViewModel.AppUser(id: UUID(), username: "jdoe", fullName: "John Doe", avatarUrl: nil)
    let user2 = FriendsViewModel.AppUser(id: UUID(), username: "asmith", fullName: "Alice Smith", avatarUrl: nil)
    dummyVM.allUsers = [user1, user2]
    dummyVM.friendsList = [user1.id] // John Doe is already a friend
    return FriendsListView(viewModel: dummyVM, invitedFriends: .constant([]))
}
