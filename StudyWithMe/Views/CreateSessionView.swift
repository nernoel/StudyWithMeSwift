import SwiftUI
import Supabase

nonisolated
struct StudySession: Decodable, Encodable, Sendable, Identifiable {
    let id: UUID?
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
        case id, title, description
        case isOpen = "is_open"
        case sessionOwner = "session_owner"
        case studyDay = "study_day"
        case locationDetails = "location_details"
        case startTime = "start_time"
        case endTime = "end_time"
        case subject
    }
}

struct CreateSessionView: View {

    @State private var title = ""
    @State private var description = ""
    @State private var subject = ""
    @State private var locationDetails = ""
    @State private var isOpen = true
    @State private var studyDay = Date()
    @State private var startTime = Date()
    @State private var endTime = Date()
    @State private var showInviteFriends = false
    @State private var invitedFriends: Set<UUID> = []

    @StateObject private var friendsViewModel = FriendsViewModel()
    @Environment(\.dismiss) var dismiss

    private var supabase: SupabaseClient {
        SupabaseClient(
            supabaseURL: URL(string: SupabaseConfig.SUPABASE_URL)!,
            supabaseKey: SupabaseConfig.SUPABASE_KEY
        )
    }

    // MARK: - Create Session
    func createStudySession() async {
        do {
            let userId = try await supabase.auth.session.user.id
            let sessionId = UUID()

            // Ensure the creator is always part of the session
            invitedFriends.insert(userId)

            let session = StudySession(
                id: sessionId,
                title: title,
                description: description,
                isOpen: isOpen,
                sessionOwner: userId.uuidString,
                studyDay: studyDay,
                locationDetails: locationDetails,
                startTime: startTime,
                endTime: endTime,
                subject: subject
            )

            // Insert session
            try await supabase.database
                .from("study_sessions")
                .insert(session)
                .execute()

            // Insert participants
            let participantsPayload: [[String: String]] = invitedFriends.map {
                ["session_id": sessionId.uuidString, "user_id": $0.uuidString]
            }

            try await supabase.database
                .from("study_session_participants")
                .insert(participantsPayload)
                .execute()

            dismiss()
        } catch {
            print("Create session error:", error.localizedDescription)
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Title") { TextField("Session title", text: $title) }
                Section("Description") { TextEditor(text: $description).frame(height: 80) }
                Section("Course") { TextField("Course", text: $subject) }
                Section("Location") { TextEditor(text: $locationDetails).frame(height: 60) }
                Section("Visibility") { Toggle("Public", isOn: $isOpen) }
                Section("Date & Time") {
                    DatePicker("Day", selection: $studyDay, displayedComponents: .date)
                    DatePicker("Start", selection: $startTime, displayedComponents: .hourAndMinute)
                    DatePicker("End", selection: $endTime, displayedComponents: .hourAndMinute)
                }

                // MARK: - Invite Friends
                Section {
                    Button {
                        showInviteFriends = true
                    } label: {
                        HStack {
                            Text("Invite Friends")
                            Spacer()
                            if invitedFriends.isEmpty {
                                Text("Select friends")
                                    .foregroundColor(.gray)
                                    .italic()
                            } else {
                                Text("\(invitedFriends.count) selected")
                                    .foregroundColor(.blue)
                                    .bold()
                            }
                        }
                    }
                }

                Section {
                    Button("Create Session") {
                        Task { await createStudySession() }
                    }
                    .frame(maxWidth: .infinity)
                    .buttonStyle(.borderedProminent)
                }
            }
            .navigationTitle("Create Session")
            .sheet(isPresented: $showInviteFriends) {
                InviteFriendsView(viewModel: friendsViewModel, invitedFriends: $invitedFriends)
                    .onAppear {
                        Task {
                            await friendsViewModel.fetchAllUsers()
                            await friendsViewModel.fetchFriends()
                        }
                    }
            }
            .task {
                await friendsViewModel.fetchAllUsers()
                await friendsViewModel.fetchFriends()
            }
        }
    }
}

#Preview {
    CreateSessionView()
}

#Preview {
    CreateSessionView()
}
