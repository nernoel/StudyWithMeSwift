import SwiftUI
import Supabase

struct EditSessionTitleView: View {
    
    @Binding var showView: Bool
    @Binding var title: String
    let sessionId: String
    
    @State private var tempTitle: String = ""
    
    private let supabase = SupabaseManager.shared.client
    
    var body: some View {
        VStack(spacing: 20) {
            
            Text("Edit Title")
                .font(.headline)
            
            TextField("Enter new title", text: $tempTitle)
                .textFieldStyle(.roundedBorder)
            
            Button("Save") {
                Task {
                    await updateTitle()
                    title = tempTitle
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
            tempTitle = title
        }
    }
    
    private func updateTitle() async {
        do {
            try await supabase.database
                .from("study_sessions")
                .update(["title": tempTitle])
                .eq("id", value: sessionId)
                .execute()
        } catch {
            print("Error updating title:", error.localizedDescription)
        }
    }
}
