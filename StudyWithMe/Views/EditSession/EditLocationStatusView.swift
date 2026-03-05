import SwiftUI
import Supabase

struct EditSessionStatusView: View {
    
    
    @Binding var showView: Bool
    @Binding var isOpen: Bool
    let sessionId: String
    
    private let supabase = SupabaseManager.shared.client
    
    var body: some View {
        VStack(spacing: 20) {
            
            Text("Edit Status")
                .font(.headline)
            
            Toggle("Session Open", isOn: $isOpen)
            
            Button("Save") {
                Task {
                    await updateStatus()
                    showView = false
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
            .background(Color.blue)
            .foregroundColor(.white)
            .clipShape(Capsule())
        }
        .padding()
        .frame(width: 300)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
        )
    }
    
    private func updateStatus() async {
        do {
            try await supabase.database
                .from("study_sessions")
                .update(["is_open": isOpen])
                .eq("id", value: sessionId)
                .execute()
        } catch {
            print("Error updating status:", error.localizedDescription)
        }
    }
}
