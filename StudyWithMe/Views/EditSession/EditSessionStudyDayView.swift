import SwiftUI
import Supabase

struct EditSessionStudyDayView: View {
    
    private let supabase = SupabaseManager.shared.client
    
    @Binding var showView: Bool
    @Binding var studyDay: Date
    
    let sessionId: String
    
    @State private var tempDate: Date = Date()
    
    var body: some View {
        VStack(spacing: 20) {
            
            Text("Edit Study Day")
                .font(.headline)
            
            DatePicker(
                "Study Day",
                selection: $tempDate,
                displayedComponents: .date
            )
            .datePickerStyle(.graphical)
            
            HStack {
                
                Button("Cancel") {
                    showView = false
                }
                .foregroundColor(.red)
                
                Spacer()
                
                Button("Done") {
                    Task {
                        await updateStudyDay()
                        studyDay = tempDate
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
            tempDate = studyDay
        }
    }
    
    func updateStudyDay() async {
        do {
            try await supabase.database
                .from("study_sessions")
                .update(["study_day": tempDate])
                .eq("id", value: sessionId)
                .execute()
        } catch {
            print("Error updating study day:", error.localizedDescription)
        }
    }
}
