import SwiftUI
import Supabase

struct EditSessionSubjectView: View {
    
    @Binding var showView: Bool
    @Binding var subject: String
    let sessionId: String
    private let supabase = SupabaseManager.shared.client
    @State private var tempSubject: String = ""
    
    var body: some View {
        VStack(spacing: 20) {
            
            Text("Edit Subject")
                .font(.headline)
            
            TextField("Enter subject", text: $tempSubject)
                .textFieldStyle(.roundedBorder)
            
            Button("Save") {
                Task {
                    await updateSubject()
                    subject = tempSubject
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
        .onAppear {
            tempSubject = subject
        }
    }
    
    private func updateSubject() async {
        do {
            try await supabase.database
                .from("study_sessions")
                .update(["subject": tempSubject])
                .eq("id", value: sessionId)
                .execute()
        } catch {
            print("Error updating subject:", error.localizedDescription)
        }
    }
}
