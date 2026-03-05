import SwiftUI
import Supabase
import Foundation

struct ShowJoinConfirmationView: View {
    
    let session: UserStudySession
    let onJoinSuccess: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var isJoining = false
    @State private var errorMessage: String?


    struct SessionParticipant: Identifiable, Decodable {
        let id: UUID
        let fullName: String?
        let avatarUrl: String?
        
        enum CodingKeys: String, CodingKey {
            case id = "user_id"
            case fullName = "full_name"
            case avatarUrl = "avatar_url"
        }
    }
    
    private let supabase = SupabaseManager.shared.client
    
    var body: some View {
        VStack(spacing: 24) {
            
            Text("Join Session")
                .font(.title2.weight(.bold))
            
            Text("Are you sure you want to join \"\(session.title ?? "this session")\"?")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            if let errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            HStack(spacing: 20) {
                
                Button("Cancel") {
                    dismiss()
                }
                .foregroundColor(.gray)
                
                Button {
                    Task {
                        await joinSession()
                    }
                } label: {
                    if isJoining {
                        ProgressView()
                    } else {
                        Text("Confirm")
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color.blue)
                .foregroundColor(.white)
                .clipShape(Capsule())
            }
        }
        .padding(30)
        .presentationDetents([.medium])
    }
    
    // MARK: - Join Logic
    
    private func joinSession() async {
        do {
            isJoining = true
            
            let userId = try await supabase.auth.session.user.id
            
            try await supabase.database
                .from("study_session_participants")
                .insert([
                    "session_id": session.id,
                    "user_id": userId
                ])
                .execute()
            
            isJoining = false
            dismiss()
            onJoinSuccess()
            
        } catch {
            errorMessage = error.localizedDescription
            isJoining = false
        }
    }
}
