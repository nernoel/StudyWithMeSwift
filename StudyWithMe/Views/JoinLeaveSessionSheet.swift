import SwiftUI
import Supabase

struct JoinLeaveSessionSheet: View {
    
    let session: UserStudySession
    let userHasJoined: Bool
    
    @Environment(\.dismiss) var dismiss
    
    private let supabase = SupabaseManager.shared.client
    
    var body: some View {
        VStack(spacing: 30) {
            
            Text(userHasJoined ? "Leave Session?" : "Join Session?")
                .font(.title2)
                .bold()
            
            Button(userHasJoined ? "Leave" : "Join") {
                Task {
                    await updateParticipation()
                    dismiss()
                }
            }
            .frame(maxWidth: 220)
            .padding()
            .background(userHasJoined ? Color.red : Color.blue)
            .foregroundColor(.white)
            .clipShape(Capsule())
            
            Button("Cancel") {
                dismiss()
            }
        }
        .padding()
    }
    
    private func updateParticipation() async {
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
                    .insert([
                        "session_id": session.id,
                        "user_id": userId
                    ])
                    .execute()
            }
        } catch {
            print("Join/Leave error:", error.localizedDescription)
        }
    }
}
