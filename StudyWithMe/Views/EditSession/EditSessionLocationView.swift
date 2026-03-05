import SwiftUI
import Supabase

struct EditSessionLocationView: View {
    
    private let supabase = SupabaseManager.shared.client
    
    @Binding var showView: Bool
    @Binding var location: String
    let sessionId: String
    
    @State private var tempLocation: String = ""
    
    var body: some View {
        VStack(spacing: 20) {
            
            Text("Edit Location")
                .font(.headline)
            
            TextField("Enter location", text: $tempLocation)
                .textFieldStyle(.roundedBorder)
            
            Button("Save") {
                Task {
                    await updateLocation()
                    location = tempLocation
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
            tempLocation = location
        }
    }
    
    private func updateLocation() async {
        do {
            try await supabase.database
                .from("study_sessions")
                .update(["location_details": tempLocation])
                .eq("id", value: sessionId)
                .execute()
        } catch {
            print("Error updating location:", error.localizedDescription)
        }
    }
}
