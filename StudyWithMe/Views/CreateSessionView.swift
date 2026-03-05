//
//  CreateSessionView.swift
//  StudyWithMe
//
//  Created by Noel Erulu on 2/25/26.
import SwiftUI
import Supabase

/*
 Import supabase client
 */
let supabase = SupabaseClient(
    supabaseURL: URL(string: SupabaseConfig.SUPABASE_URL)!,
    supabaseKey: SupabaseConfig.SUPABASE_KEY
)

nonisolated
struct StudySession: Decodable, Encodable, Sendable {
    let title: String?
    let description: String?
    let isOpen: Bool?
    let sessionOwner: String?
    
    enum CodingKeys: String, CodingKey {
        case title = "title"
        case description = "description"
        case isOpen = "is_open"
        case sessionOwner = "session_owner"
    }
}

struct CreateSessionView: View {
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var isOpen: Bool = true
    
    @Environment(\.dismiss) var dismiss
    
    // Get the current auth user id for session owner
    func fetchCurrentUserId() async -> String? {
        do {
            let userId = try await supabase.auth.session.user.id
            return userId.uuidString
        } catch {
            print("Error fetching current user")
            return nil
        }
    }
    func createStudySession() async {
        let newSession = await StudySession(
            title: title,
            description: description,
            isOpen: isOpen,
            sessionOwner: fetchCurrentUserId()
        )
        do {
            try await supabase.database
                .from("study_sessions")
                .insert(newSession)
                .execute()
        } catch {
            print("Error:", error.localizedDescription)
        }
    }
    
    var body: some View {
        HStack {
            Text("Create a new study session")
                .bold(true)
                .fontWidth(.expanded)
        }
        Spacer()
        NavigationStack {
            VStack {
                Form {
                    Section(header: Text("Title")) {
                        TextField("Session title" ,text: $title)
                    }
                    Section(header: Text("Description")) {
                        TextField("Enter a description", text: $description)
                    }
                    Section(header: Text("Session visibility")) {
                        Toggle("Private", isOn: $isOpen)
                    }
                    // Add section to choose category / classes here later...
                }
                Button("Create new session") {
                    Task {
                        await createStudySession()
                        dismiss()
                        // Create an alert after session is created
                    }
                }
               
            }
        }
    }
}

#Preview {
    CreateSessionView()
}
