import SwiftUI
import Supabase
import Auth

struct StudySessionCardView: View {
    
    @State private var showMoreInformation = false
    @State private var showEditSheet = false
    
    @State private var fullName = "Loading..."
    @State private var isSessionOwner = false
    
    @State private var participantCount: Int = 0
    @State private var userHasJoined: Bool = false
    
    let session: UserStudySession
    
    var onDelete: (() -> Void)? = nil
    var onUpdate: (() -> Void)? = nil
    
    private let supabase = SupabaseManager.shared.client
    
    private var isExpired: Bool {
        guard let studyDay = session.studyDay,
              let endTime = session.endTime else { return false }
        
        let calendar = Calendar.current
        let combined = calendar.date(
            bySettingHour: calendar.component(.hour, from: endTime),
            minute: calendar.component(.minute, from: endTime),
            second: 0,
            of: studyDay
        )
        return combined ?? Date() < Date()
    }
    
    // MARK: - Fetch session info
    private func fetchSessionData() async {
        do {
            let authSession = try await supabase.auth.session
            let currentUserId = authSession.user.id
            
            if let owner = session.sessionOwner,
               let ownerUUID = UUID(uuidString: owner),
               ownerUUID == currentUserId {
                isSessionOwner = true
                fullName = "You"
            } else {
                isSessionOwner = false
                struct Profile: Decodable { let full_name: String }
                let res = try await supabase.database
                    .from("profiles")
                    .select("full_name")
                    .eq("id", value: session.sessionOwner ?? "")
                    .single()
                    .execute()
                let profile = try JSONDecoder().decode(Profile.self, from: res.data)
                fullName = profile.full_name
            }
            
            // Participant count
            let countRes = try await supabase.database
                .from("study_session_participants")
                .select("id", count: .exact)
                .eq("session_id", value: session.id)
                .execute()
            
            participantCount = countRes.count ?? 0
            
            // Check if user has joined
            let joinRes = try await supabase.database
                .from("study_session_participants")
                .select("user_id")
                .eq("session_id", value: session.id)
                .eq("user_id", value: currentUserId)
                .execute()
            
            struct JoinCheck: Decodable { let user_id: UUID }
            let decoded = try JSONDecoder().decode([JoinCheck].self, from: joinRes.data)
            userHasJoined = !decoded.isEmpty
            
            onUpdate?()
        } catch {
            print("Fetch error:", error.localizedDescription)
        }
    }
    
    // MARK: - Join/Leave session
    private func joinLeaveSession() async {
        do {
            let userId = try await supabase.auth.session.user.id
            
            if userHasJoined {
                try await supabase.database
                    .from("study_session_participants")
                    .delete()
                    .eq("session_id", value: session.id)
                    .eq("user_id", value: userId)
                    .execute()
            } else {
                try await supabase.database
                    .from("study_session_participants")
                    .insert([["session_id": session.id.uuidString, "user_id": userId.uuidString]])
                    .execute()
            }
            
            await fetchSessionData()
        } catch {
            print("Join/Leave error:", error.localizedDescription)
        }
    }
    
    // MARK: - UI
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            // Subject tag
            if let subject = session.subject {
                Text(subject.uppercased())
                    .font(.caption.bold())
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue.opacity(0.15))
                    .foregroundColor(.blue)
                    .clipShape(Capsule())
            }
            
            // Title
            Text(session.title ?? "Untitled Session")
                .font(.title3.bold())
                .lineLimit(2)
            
            // Host info
            Text("Hosted by \(fullName)")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Divider()
            
            // Date & time
            if let studyDay = session.studyDay {
                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                    Text(formattedDate(studyDay))
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            
            if let start = session.startTime, let end = session.endTime {
                HStack(spacing: 6) {
                    Image(systemName: "clock")
                    Text("\(formattedTime(start)) - \(formattedTime(end))")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Bottom actions
            HStack {
                
                // Status tag
                Text(session.isOpen == true ? "OPEN" : "CLOSED")
                    .font(.caption.bold())
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(session.isOpen == true ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
                    .foregroundColor(session.isOpen == true ? .green : .red)
                    .clipShape(Capsule())
                
                Spacer()
                
                Label("\(participantCount) going", systemImage: "person.2.fill")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                // Conditional buttons
                if isSessionOwner {
                    Button("Edit") { showEditSheet = true }
                        .font(.caption.bold())
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(Color.yellow)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                } else {
                    Button(userHasJoined ? "Leave" : "Join") {
                        Task { await joinLeaveSession() }
                    }
                    .font(.caption.bold())
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(userHasJoined ? Color.red : Color.blue)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(Color.white)
                .opacity(isExpired ? 0.5 : 1)
        )
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
        .frame(width: 320)
        .onTapGesture { showMoreInformation = true }
        .sheet(isPresented: $showEditSheet) {
            EditSessionView(sessionId: .constant(session.id.uuidString))
        }
        .sheet(isPresented: $showMoreInformation) {
            ShowMoreInformation(session: session)
        }
        .task { await fetchSessionData() }
    }
    
    // MARK: - Helper functions
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    private func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
