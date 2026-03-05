import SwiftUI
import Supabase

struct EditFullNameView: View {
    @Binding var showEditFullNameView: Bool
    @State private var newFullName: String = ""
    @State private var isLoading: Bool = false
    
    private let supabase = SupabaseManager.shared.client
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Edit full name")
                .font(.headline)
                .fontWidth(.expanded)
            
            TextField("Enter your full name", text: $newFullName)
                .frame(width: 250)
            
            Button {
                Task {
                    do {
                        isLoading = true
                        
                        try await supabase.database
                            .from("profiles")
                            .update(["full_name": newFullName])
                            .eq("id", value: supabase.auth.session.user.id)
                            .execute()
                        
                        isLoading = false
                        showEditFullNameView = false
                        
                    } catch {
                        isLoading = false
                        print("Error updating full name", error.localizedDescription)
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
    EditFullNameView(showEditFullNameView: .constant(true))
}
