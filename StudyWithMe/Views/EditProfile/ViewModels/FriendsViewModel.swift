import SwiftUI
import Supabase
import Foundation
import Combine

@MainActor
class FriendsViewModel: ObservableObject {

    // MARK: - User Model
    nonisolated
    struct AppUser: Identifiable, Codable, Hashable {
        let id: UUID
        let username: String
        let fullName: String?
        let avatarUrl: String?

        enum CodingKeys: String, CodingKey {
            case id
            case username
            case fullName = "full_name"
            case avatarUrl = "avatar_url"
        }
    }

    // MARK: - Published properties
    @Published var allUsers: [AppUser] = []
    @Published var friendsList: [UUID] = []
    @Published var selectedFriends: Set<UUID> = []

    // Avatar cache
    @Published var avatarURLs: [UUID: String] = [:]

    // MARK: - Supabase Client
    private let supabase = SupabaseClient(
        supabaseURL: URL(string: SupabaseConfig.SUPABASE_URL)!,
        supabaseKey: SupabaseConfig.SUPABASE_KEY
    )

    // MARK: - Fetch current user ID
    private func currentUserId() async -> UUID? {
        do {
            return try await supabase.auth.session.user.id
        } catch {
            print("Failed to fetch current user ID:", error.localizedDescription)
            return nil
        }
    }

    // MARK: - Fetch all users except current user
    func fetchAllUsers() async {
        guard let uid = await currentUserId() else { return }

        do {
            let response: [AppUser] = try await supabase.database
                .from("profiles")
                .select()
                .neq("id", value: uid.uuidString)
                .execute()
                .value

            self.allUsers = response

            // Load avatars after users load
            await loadAvatars()

        } catch {
            print("Failed to fetch users:", error)
        }
    }

    // MARK: - Load avatar images from Supabase Storage
    func loadAvatars() async {

        for user in allUsers {

            guard let avatarPath = user.avatarUrl else { continue }

            do {
                let signedURL = try await supabase.storage
                    .from("avatars")
                    .createSignedURL(
                        path: avatarPath,
                        expiresIn: 3600
                    )

                avatarURLs[user.id] = signedURL.absoluteString

            } catch {
                print("Avatar load error:", error)
            }
        }
    }

    // MARK: - Fetch current user's friends
    func fetchFriends() async {
        guard let uid = await currentUserId() else { return }

        do {

            nonisolated
            struct FriendRecord: Decodable {
                let friend_id: UUID
            }

            let response: [FriendRecord] = try await supabase.database
                .from("friends")
                .select("friend_id")
                .eq("user_id", value: uid.uuidString)
                .execute()
                .value

            self.friendsList = response.map { $0.friend_id }

        } catch {
            print("Failed to fetch friends:", error)
        }
    }

    // MARK: - Check if user is already a friend
    func isFriend(_ user: AppUser) -> Bool {
        friendsList.contains(user.id)
    }

    // MARK: - Add friend
    func addFriend(userId: UUID) async {
        guard let uid = await currentUserId() else { return }

        do {
            try await supabase.database
                .from("friends")
                .insert([
                    ["user_id": uid.uuidString, "friend_id": userId.uuidString]
                ])
                .execute()

            if !friendsList.contains(userId) {
                friendsList.append(userId)
            }

        } catch {
            print("Failed to add friend:", error)
        }
    }

    // MARK: - Remove friend
    func removeFriend(userId: UUID) async {
        guard let uid = await currentUserId() else { return }

        do {
            try await supabase.database
                .from("friends")
                .delete()
                .eq("user_id", value: uid.uuidString)
                .eq("friend_id", value: userId.uuidString)
                .execute()

            friendsList.removeAll { $0 == userId }

        } catch {
            print("Failed to remove friend:", error)
        }
    }
}
