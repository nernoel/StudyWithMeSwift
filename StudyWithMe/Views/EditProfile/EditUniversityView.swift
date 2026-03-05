import SwiftUI
import Supabase

struct EditUniversityView: View {
    private let supabase = SupabaseManager.shared.client
    @Binding var showEditUniversityView: Bool
    @State private var newUniversity: String = ""
    @State private var isLoading: Bool = false
    
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Edit university")
                .font(.headline)
                .fontWidth(.expanded)
            
            TextField("Enter your university", text: $newUniversity)
                .frame(width: 250)
            
            Button {
                Task {
                    do {
                        isLoading = true
                        
                        try await supabase.database
                            .from("profiles")
                            .update(["university": newUniversity])
                            .eq("id", value: supabase.auth.session.user.id)
                            .execute()
                        
                        isLoading = false
                        showEditUniversityView = false
                        
                    } catch {
                        isLoading = false
                        print("Error updating university", error.localizedDescription)
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
    EditUniversityView(showEditUniversityView: .constant(true))
}
