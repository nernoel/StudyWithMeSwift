//
//  HomeView.swift
//  StudyWithMe
//
//  Created by Noel Erulu on 2/24/26.
//
import SwiftUI
import Supabase
import Auth

nonisolated // Main actor isolated bug fix
struct UserProfile: Decodable, Sendable {
    let userName: String?
    let fullName: String?
    
    enum CodingKeys: String, CodingKey {
    case userName
    case fullName = "full_name"
    }
}

nonisolated
struct UserStudySession: Identifiable, Decodable {
    let id: UUID?
    let title: String
    let description: String
    let isOpen: Bool
    let sessionOwner: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case title = "title"
        case description = "description"
        case isOpen = "is_open"
        case sessionOwner = "session_owner"
    }
}




struct HomeView: View {
    @EnvironmentObject var authModel: AuthModel
    
    @StateObject private var userSessionModel = UserStudySessionViewModel()
    
    @State private var userName: String = ""
    @State private var fullName: String = ""
    @State private var userStudySessions: [StudySession] = []
    
    let supabase = SupabaseClient(
        supabaseURL: URL(string: SupabaseConfig.SUPABASE_URL)!,
        supabaseKey: SupabaseConfig.SUPABASE_KEY
    )
    
    func getProfileData() async {
        do {
            let currentUser = try await supabase.auth.session.user
            let profile : UserProfile =
            try await supabase.database
                .from("profiles")
                .select()
                .eq("id", value: currentUser.id)
                .single()
                .execute()
                .value
            
            self.userName = profile.userName ?? ""
            self.fullName = profile.fullName ?? ""
            
        } catch {
            print("Error:", error.localizedDescription)
        }
    }
    
        var body: some View {
            NavigationStack {
                VStack {
                    HStack {
                        Text("Welcome \(fullName)")
                        Spacer()
                        
                        NavigationLink(destination: CreateSessionView()) {
                            Text("+")
                        }
                    }
                    .padding(.top, 10)
                    .padding(.horizontal, 25)
                    // Active user sessions
                    // Horizontal Sessions Section
                                    VStack(alignment: .leading, spacing: 12) {
                                        
                                        Text("Your Current Sessions")
                                            .font(.headline)
                                            .padding(.horizontal)
                                        
                                        ScrollView(.horizontal, showsIndicators: false) {
                                            HStack(spacing: 16) {
                                                ForEach(userSessionModel.userStudySessions) { session in
                                                    StudySessionCardView(session: session)
                                                }
                                            }
                                            .padding(.horizontal)
                                        }
                                    }
                    
                    Spacer()
                    
                }
                .task {
                    await getProfileData()
                    await userSessionModel.readUserSessions()
                }
            }
        }
}
