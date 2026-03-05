import SwiftUI
import Supabase
import Combine

@MainActor
class UserStudySessionViewModel: ObservableObject {
    private let supabase = SupabaseManager.shared.client

    @Published var userStudySessions: [UserStudySession] = []
    @Published var otherUserStudySessions: [UserStudySession] = []

    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func readUserSessions() async {
        do {
            isLoading = true

            let response = try await supabase.database
                .from("study_sessions")
                .select()
                .eq("session_owner", value: supabase.auth.session.user.id.uuidString)
                .execute()

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601

            userStudySessions = try decoder.decode(
                [UserStudySession].self,
                from: response.data
            )

        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func readOtherUserSessions() async {
        do {
            let response = try await supabase.database
                .from("study_sessions")
                .select()
                .neq("session_owner", value: supabase.auth.session.user.id)
                .execute()
            
            try await print("Current user id:", supabase.auth.session.user.id.uuidString)
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            print("Other sessions:", try decoder.decode(
                [UserStudySession].self,
                from: response.data
            ))


            otherUserStudySessions = try decoder.decode(
                [UserStudySession].self,
                from: response.data
            )
            
            

        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
