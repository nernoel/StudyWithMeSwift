//
//  UserSessionModel.swift
//  StudyWithMe
//
//  Created by Noel Erulu on 2/25/26.
//
import Combine
import Supabase

import SwiftUI

//@MainActor
class UserStudySessionViewModel: ObservableObject {
    @Published var userStudySessions: [UserStudySession] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func getUserStudySessions() async throws -> [UserStudySession] {
        let response = try await supabase.database
            .from("study_sessions")
            .select()
            .eq("session_owner", value: supabase.auth.session.user.id.uuidString)
            .execute()
        

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        return try decoder.decode([UserStudySession].self, from: response.data)
    }

    
    func readUserSessions() async {
        do {
            userStudySessions = try await getUserStudySessions()
            print(userStudySessions)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
