import SwiftUI
import Supabase

struct EditMajorView: View {
    @Binding var showEditMajorView: Bool
    
    @State private var newMajor: String = ""
    @State private var isLoading: Bool = false
    
    private let supabase = SupabaseManager.shared.client
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Edit major")
                .font(.headline)
                .fontWidth(.expanded)
            
            TextField("Enter your major", text: $newMajor)
                .frame(width: 250)
            
            Button {
                Task {
                    do {
                        isLoading = true
                        
                        try await supabase.database
                            .from("profiles")
                            .update(["major": newMajor])
                            .eq("id", value: supabase.auth.session.user.id)
                            .execute()
                        
                        isLoading = false
                        showEditMajorView = false
                        
                    } catch {
                        isLoading = false
                        print("Error updating major", error.localizedDescription)
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
        .frame(width: 300, height: 120)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
}

#Preview {
    EditMajorView(showEditMajorView: .constant(true))
}
