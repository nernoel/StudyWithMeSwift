import SwiftUI

struct InviteFriendsView: View {
    
    @ObservedObject var viewModel: FriendsViewModel
    @Binding var invitedFriends: Set<UUID> // This is the list that goes back to CreateSessionView
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.allUsers) { user in
                    HStack {
                        // Avatar
                        if let avatar = user.avatarUrl, let url = URL(string: avatar) {
                            AsyncImage(url: url) { image in
                                image.resizable().scaledToFill()
                            } placeholder: {
                                Color.gray.opacity(0.3)
                            }
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                        } else {
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 40, height: 40)
                        }
                        
                        VStack(alignment: .leading) {
                            Text(user.fullName ?? "Unknown")
                                .fontWeight(.semibold)
                            Text("@\(user.username)")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        // Checkmark for invited / going
                        if invitedFriends.contains(user.id) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.blue)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        toggleInvite(user: user)
                    }
                }
            }
            .navigationTitle("Invite Friends")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
    
    // MARK: - Toggle Invite
    private func toggleInvite(user: FriendsViewModel.AppUser) {
        if invitedFriends.contains(user.id) {
            invitedFriends.remove(user.id)
        } else {
            invitedFriends.insert(user.id)
        }
    }
}

#Preview {
    let dummyVM = FriendsViewModel()
    dummyVM.allUsers = [
        .init(id: UUID(), username: "jdoe", fullName: "John Doe", avatarUrl: nil),
        .init(id: UUID(), username: "asmith", fullName: "Alice Smith", avatarUrl: nil)
    ]
    return InviteFriendsView(viewModel: dummyVM, invitedFriends: .constant([]))
}
