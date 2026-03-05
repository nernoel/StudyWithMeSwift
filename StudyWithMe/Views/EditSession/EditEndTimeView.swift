import SwiftUI
import Supabase

struct EditSessionEndTimeView: View {
    
    @Binding var showView: Bool
    @Binding var endTime: Date
    
    let sessionId: String
    
    @State private var tempTime: Date = Date()
    
    private let supabase = SupabaseManager.shared.client
    
    var body: some View {
        VStack(spacing: 20) {
            
            Text("Edit End Time")
                .font(.headline)
            
            DatePicker(
                "End Time",
                selection: $tempTime,
                displayedComponents: .hourAndMinute
            )
            .datePickerStyle(.wheel)
            
            HStack {
                
                Button("Cancel") {
                    showView = false
                }
                .foregroundColor(.red)
                
                Spacer()
                
                Button("Done") {
                    Task {
                        await updateEndTime()
                        endTime = tempTime
                        showView = false
                    }
                }
                .foregroundColor(.blue)
            }
        }
        .padding()
        .frame(width: 350)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(radius: 10)
        )
        .onAppear {
            tempTime = endTime
        }
    }
    
    func updateEndTime() async {
        do {
            try await supabase.database
                .from("study_sessions")
                .update(["end_time": tempTime])
                .eq("id", value: sessionId)
                .execute()
        } catch {
            print("Error updating end time:", error.localizedDescription)
        }
    }
}
