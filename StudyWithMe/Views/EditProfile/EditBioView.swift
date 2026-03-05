import SwiftUI
import Supabase

struct EditBioView: View {
    @Binding var showEditBioView: Bool
    @State private var newBio: String = ""
    @State private var isLoading: Bool = false
    
    private let supabase = SupabaseManager.shared.client
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Edit bio")
                .font(.headline)
                .fontWidth(.expanded)
            
            TextEditor(text: $newBio)
                .frame(width: 250, height: 80)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3))
                )
            
            Button {
                Task {
                    do {
                        isLoading = true
                        
                        try await supabase.database
                            .from("profiles")
                            .update(["bio": newBio])
                            .eq("id", value: supabase.auth.session.user.id)
                            .execute()
                        
                        isLoading = false
                        showEditBioView = false
                        
                    } catch {
                        isLoading = false
                        print("Error updating bio", error.localizedDescription)
                    }
                }
            } label: {
                if isLoading {
                    ProgressView()
                } else {
                    Text("Save")
                        .fontWeight(.semibold)
                }
            }
            .disabled(isLoading)
            
        }
        .padding()
        .frame(width: 300, height: 180)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
}

#Preview {
    EditBioView(showEditBioView: .constant(true))
}
