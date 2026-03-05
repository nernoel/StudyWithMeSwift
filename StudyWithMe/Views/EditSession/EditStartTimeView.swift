import SwiftUI
import Supabase

struct EditSessionStartTimeView: View {
    
    private let supabase = SupabaseManager.shared.client
    @Binding var showView: Bool
    @Binding var startTime: Date
    
    let sessionId: String
    
    @State private var tempTime: Date = Date()
    
    var body: some View {
        VStack(spacing: 20) {
            
            Text("Edit Start Time")
                .font(.headline)
            
            DatePicker(
                "Start Time",
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
                        await updateStartTime()
                        startTime = tempTime
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
            tempTime = startTime
        }
    }
    
    func updateStartTime() async {
        do {
            try await supabase.database
                .from("study_sessions")
                .update(["start_time": tempTime])
                .eq("id", value: sessionId)
                .execute()
        } catch {
            print("Error updating start time:", error.localizedDescription)
        }
    }
}
