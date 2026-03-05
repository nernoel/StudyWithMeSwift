import SwiftUI
import Supabase
import Auth

struct ShowMoreInformation: View {
    
    let session: UserStudySession
    
    @State private var participantCount = 0
    @State private var userHasJoined = false
    @State private var isOwner = false
    @State private var showJoinLeaveSheet = false
    @State private var showEditSheet = false
    
    private let supabase = SupabaseManager.shared.client
    
    // MARK: - Fetch Info
    
    private func fetchInfo() async {
        do {
            let auth = try await supabase.auth.session
            let currentUser = auth.user.id
            
            // Check if owner
            if let owner = session.sessionOwner,
               let uuid = UUID(uuidString: owner),
               uuid == currentUser {
                isOwner = true
            } else {
                isOwner = false
            }
            
            // Fetch participant count
            let countRes = try await supabase.database
                .from("study_session_participants")
                .select("id", count: .exact)
                .eq("session_id", value: session.id)
                .execute()
            
            participantCount = countRes.count ?? 0
            
            // Check if user joined
            let joinRes = try await supabase.database
                .from("study_session_participants")
                .select("user_id")
                .eq("session_id", value: session.id)
                .eq("user_id", value: currentUser)
                .execute()
            
            struct JoinCheck: Decodable { let user_id: UUID }
            let decoded = try JSONDecoder().decode([JoinCheck].self, from: joinRes.data)
            userHasJoined = !decoded.isEmpty
            
        } catch {
            print("ShowMoreInformation fetch error:", error.localizedDescription)
        }
    }
    
    // MARK: - UI
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                
                // Subject
                if let subject = session.subject {
                    Text(subject)
                        .font(.title)
                        .bold()
                        .foregroundColor(.blue)
                }
                
                // Title
                Text(session.title ?? "Untitled Session")
                    .font(.title2)
                    .bold()
                
                // Open / Closed Badge
                Text(session.isOpen == true ? "OPEN" : "CLOSED")
                    .font(.caption.bold())
                    .padding(6)
                    .background(
                        session.isOpen == true
                        ? Color.green.opacity(0.2)
                        : Color.red.opacity(0.2)
                    )
                    .foregroundColor(
                        session.isOpen == true ? .green : .red
                    )
                    .clipShape(Capsule())
                
                // Participant Count
                Label("\(participantCount) going", systemImage: "person.2.fill")
                    .font(.subheadline)
                
                Divider()
                
                // Date & Time
                if let studyDay = session.studyDay {
                    Label(formattedDate(studyDay), systemImage: "calendar")
                }
                
                if let start = session.startTime,
                   let end = session.endTime {
                    Label("\(formattedTime(start)) - \(formattedTime(end))",
                          systemImage: "clock")
                }
                
                Divider()
                
                // Location
                if let location = session.locationDetails {
                    Text("Location")
                        .font(.headline)
                    Text(location)
                }
                
                // Description
                if let description = session.description {
                    Text("Description")
                        .font(.headline)
                    Text(description)
                }
                
                Divider()
                
                // Owner / Join Leave Button
                if isOwner {
                    Button("Edit Session") {
                        showEditSheet = true
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.yellow)
                    .clipShape(Capsule())
                } else {
                    Button(userHasJoined ? "Leave Session" : "Join Session") {
                        showJoinLeaveSheet = true
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(userHasJoined ? Color.red : Color.blue)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
                }
                
                Divider()
                
                
                ParticipantsListView(sessionId: session.id)
            }
            .padding()
        }
        .task {
            await fetchInfo()
        }
        .sheet(isPresented: $showJoinLeaveSheet, onDismiss: {
            Task {
                await fetchInfo()
            }
        }) {
            JoinLeaveSessionSheet(
                session: session,
                userHasJoined: userHasJoined
            )
        }
        .sheet(isPresented: $showEditSheet) {
            EditSessionView(
                sessionId: .constant(session.id.uuidString)
            )
        }
    }
}

// MARK: - Date Formatting Helpers

func formattedDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    return formatter.string(from: date)
}

func formattedTime(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.timeStyle = .short
    return formatter.string(from: date)
}

func formattedDay(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "EEEE"   // Monday, Tuesday, etc.
    return formatter.string(from: date)
}

#Preview {
    
    let studyDay = Calendar.current.date(
        from: DateComponents(year: 2026, month: 3, day: 15)
    )
    
    let startTime = Calendar.current.date(
        from: DateComponents(year: 2026, month: 3, day: 15, hour: 14, minute: 0)
    )
    
    let endTime = Calendar.current.date(
        from: DateComponents(year: 2026, month: 3, day: 15, hour: 16, minute: 0)
    )
    
    return ShowMoreInformation(
        session: UserStudySession(
            id: UUID(),
            title: "Calc 3 Midterm Review",
            description: "We’ll be reviewing line integrals, surface integrals, Green’s Theorem, and Stokes’ Theorem before the midterm. Bring your textbook, notes, and practice problems. We’ll work through examples together.",
            isOpen: true,
            sessionOwner: UUID().uuidString,
            studyDay: studyDay,
            locationDetails: "Library Room 204 - Science Building, 2nd Floor",
            startTime: startTime,
            endTime: endTime,
            subject: "MATH 241 - Calculus III"
        )
    )
}

    #Preview {
        let studyDay = Calendar.current.date(
            from: DateComponents(year: 2026, month: 3, day: 15)
        )
        
        let startTime = Calendar.current.date(
            from: DateComponents(year: 2026, month: 3, day: 15, hour: 14, minute: 0)
        )
        
        let endTime = Calendar.current.date(
            from: DateComponents(year: 2026, month: 3, day: 15, hour: 16, minute: 0)
        )
        
        return ShowMoreInformation(
            session: UserStudySession(
                id: UUID(),
                title: "Calc 3 Midterm Review",
                description: "We’ll be reviewing line integrals, surface integrals, Green’s Theorem, and Stokes’ Theorem before the midterm. Bring your textbook, notes, and practice problems. We’ll work through examples together.",
                isOpen: true,
                sessionOwner: "12345-user-id",
                studyDay: studyDay,
                locationDetails: "Library Room 204 - Science Building, 2nd Floor",
                startTime: startTime,
                endTime: endTime,
                subject: "MATH 241 - Calculus III"
            )
        )
    }
