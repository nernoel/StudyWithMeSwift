import SwiftUI
import Supabase
import Auth

// MARK: - Models

nonisolated
struct UserProfile: Decodable, Sendable {
    let userName: String?
    let fullName: String?
    let avatarUrl: String?

    enum CodingKeys: String, CodingKey {
        case userName
        case fullName = "full_name"
        case avatarUrl = "avatar_url"
    }
}

nonisolated
struct UserStudySession: Identifiable, Decodable {
    let id: UUID
    let title: String?
    let description: String?
    let isOpen: Bool?
    let sessionOwner: String?
    let studyDay: Date?
    let locationDetails: String?
    let startTime: Date?
    let endTime: Date?
    let subject: String?

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case isOpen = "is_open"
        case sessionOwner = "session_owner"
        case studyDay = "study_day"
        case locationDetails = "location_details"
        case startTime = "start_time"
        case endTime = "end_time"
        case subject
    }
}

// MARK: - Home View
import SwiftUI
import Supabase
import Auth

struct HomeView: View {

    @EnvironmentObject var authModel: AuthModel
    @StateObject private var userSessionModel = UserStudySessionViewModel()
    @State private var avatarUrl: String = ""
    @State private var fullName: String = ""
    @State private var showProfileView = false
    private let supabase = SupabaseManager.shared.client

    // Fetch user profile
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

            fullName = profile.fullName ?? ""

            if let avatarPath = profile.avatarUrl {
                let signedURL = try await supabase.storage
                    .from("avatars")
                    .createSignedURL(path: avatarPath, expiresIn: 60)
                avatarUrl = signedURL.absoluteString
            }
        } catch {
            print("Profile fetch error:", error.localizedDescription)
        }
    }

    private func removeUserSession(_ session: UserStudySession) {
        userSessionModel.userStudySessions.removeAll { $0.id == session.id }
        userSessionModel.otherUserStudySessions.removeAll { $0.id == session.id }
    }

    private func refreshSessions() async {
        await userSessionModel.readUserSessions()
        await userSessionModel.readOtherUserSessions()
    }

    var body: some View {
        TabView {
            // MARK: - Posts tab
            NavigationStack {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack {
                        HStack {
                            AvatarView(avatarURL: avatarUrl)
                                .onTapGesture { showProfileView.toggle() }
                                .sheet(isPresented: $showProfileView) { ProfileView() }

                            VStack(alignment: .leading) {
                                Text("Welcome Back")
                                    .fontWidth(.expanded)
                                Text(fullName)
                                    .font(.title)
                                    .bold()
                                    .fontWidth(.expanded)
                            }

                            Spacer()

                            NavigationLink(destination: CreateSessionView()) {
                                Text("+").font(.title)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)

                        // Your sessions
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Your Active Posts").font(.title).bold().padding()
                            if userSessionModel.userStudySessions.isEmpty {
                                Text("No posts by you yet...")
                                    .font(.title)
                                    .bold()
                                    .padding()
                                    .foregroundColor(.red.opacity(0.5))
                            }

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(userSessionModel.userStudySessions) { session in
                                        StudySessionCardView(
                                            session: session,
                                            onDelete: { removeUserSession(session) },
                                            onUpdate: { Task { await refreshSessions() } }
                                        )
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 20)
                            }
                        }

                        // Other sessions
                        VStack(alignment: .leading) {
                            Text("Other Student Posts").font(.title).bold().padding()
                            if userSessionModel.otherUserStudySessions.isEmpty {
                                Text("No posts by others yet...")
                                    .font(.title)
                                    .bold()
                                    .padding()
                                    .foregroundColor(.red.opacity(0.5))
                            }

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(userSessionModel.otherUserStudySessions) { session in
                                        StudySessionCardView(
                                            session: session,
                                            onDelete: { removeUserSession(session) },
                                            onUpdate: { Task { await refreshSessions() } }
                                        )
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.vertical)
                            }
                        }

                        Spacer()
                    }
                }
                .task {
                    await getProfileData()
                    await refreshSessions()
                }
                .navigationTitle("StudyWithMe")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Sign Out") {
                            Task {
                                await authModel.signOut()
                                print("signed out successfully")
                            }
                        }
                    }
                }
            }
            .tabItem {
                Label("Posts", systemImage: "doc.text")
            }

            // MARK: - Messages tab
            NavigationStack {
                FriendsView()
            }
            .tabItem {
                Label("Messages", systemImage: "message")
            }
        }
    }
}

#Preview {
    HomeView().environmentObject(AuthModel())
}
