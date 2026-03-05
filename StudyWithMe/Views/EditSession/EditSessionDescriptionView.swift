import SwiftUI
import Supabase

struct EditSessionDescriptionView: View {
    
    private let supabase = SupabaseManager.shared.client
    
    @Binding var showView: Bool
    @Binding var description: String
    let sessionId: String
    
    @State private var tempDescription: String = ""
    
    var body: some View {
        VStack(spacing: 20) {
            
            Text("Edit Description")
                .font(.headline)
            
            TextEditor(text: $tempDescription)
                .frame(height: 120)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3))
                )
            
            Button("Save") {
                Task {
                    await updateDescription()
                    description = tempDescription
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
        .frame(width: 320)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
        )
        .onAppear {
            tempDescription = description
        }
    }
    
    private func updateDescription() async {
        do {
            try await supabase.database
                .from("study_sessions")
                .update(["description": tempDescription])
                .eq("id", value: sessionId)
                .execute()
        } catch {
            print("Error updating description:", error.localizedDescription)
        }
    }
}
