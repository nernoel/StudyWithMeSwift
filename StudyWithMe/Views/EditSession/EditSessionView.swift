import SwiftUI
import Supabase
import Auth

struct EditSessionView: View {
    
    // Passed from parent
    @Binding var sessionId: String
    
    // MARK: - Session State
    
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var subject: String = ""
    @State private var locationDetails: String = ""
    @State private var isOpen: Bool = true
    
    @State private var startTime: Date = Date()
    @State private var endTime: Date = Date()
    @State private var studyDay: Date = Date()
    
    // MARK: - Modal Toggles
    
    @State private var showEditTitle = false
    @State private var showEditDescription = false
    @State private var showEditSubject = false
    @State private var showEditLocation = false
    @State private var showEditStatus = false
    @State private var showEditStudyDay = false
    @State private var showEditStartTime = false
    @State private var showEditEndTime = false
    
    private let supabase = SupabaseManager.shared.client
    
    // MARK: - Model
    
    nonisolated
    struct SessionModel: Identifiable, Decodable {
        let id: UUID?
        let title: String?
        let description: String?
        let subject: String?
        let locationDetails: String?
        let isOpen: Bool?
        let startTime: Date?
        let endTime: Date?
        let studyDay: Date?
        
        enum CodingKeys: String, CodingKey {
            case id
            case title
            case description
            case subject
            case locationDetails = "location_details"
            case isOpen = "is_open"
            case startTime = "start_time"
            case endTime = "end_time"
            case studyDay = "study_day"
        }
    }
    
    // MARK: - Fetch Session
    
    func fetchSessionData() async {
        do {
            let response: SessionModel =
            try await supabase.database
                .from("study_sessions")
                .select()
                .eq("id", value: sessionId)
                .single()
                .execute()
                .value
            
            title = response.title ?? ""
            description = response.description ?? ""
            subject = response.subject ?? ""
            locationDetails = response.locationDetails ?? ""
            isOpen = response.isOpen ?? true
            startTime = response.startTime ?? Date()
            endTime = response.endTime ?? Date()
            studyDay = response.studyDay ?? Date()
            
        } catch {
            print("Error fetching session:", error.localizedDescription)
        }
    }
    
    func refreshData() {
        Task {
            await fetchSessionData()
        }
    }
    
    // MARK: - UI
    
    var body: some View {
        NavigationStack {
            ZStack {
                
                VStack(spacing: 30) {
                    
                    VStack(spacing: 0) {
                        
                        sessionRow(value: title, title: "Title") {
                            showEditTitle = true
                        }
                        
                        Divider()
                        
                        sessionRow(value: description, title: "Description") {
                            showEditDescription = true
                        }
                        
                        Divider()
                        
                        sessionRow(value: subject, title: "Subject") {
                            showEditSubject = true
                        }
                        
                        Divider()
                        
                        sessionRow(value: locationDetails, title: "Location") {
                            showEditLocation = true
                        }
                        
                        Divider()
                        
                        sessionRow(value: formattedDate(studyDay), title: "Study Day") {
                            showEditStudyDay = true
                        }

                        Divider()

                        sessionRow(value: formattedTime(startTime), title: "Start Time") {
                            showEditStartTime = true
                        }

                        Divider()

                        sessionRow(value: formattedTime(endTime), title: "End Time") {
                            showEditEndTime = true
                        }
                        
                        Divider()
                        
                        sessionRow(value: isOpen ? "Open" : "Closed", title: "Status") {
                            showEditStatus = true
                        }
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.05),
                                    radius: 10, x: 0, y: 4)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
                    
                    Spacer()
                }
                .padding()
                .blur(radius: shouldBlur ? 10 : 0)
                
                // MARK: - Modals
                
                if showEditTitle {
                    modalBackground { showEditTitle = false }
                    EditSessionTitleView(
                        showView: $showEditTitle,
                        title: $title,
                        sessionId: sessionId
                    )
                }
                
                if showEditDescription {
                    modalBackground { showEditDescription = false }
                    EditSessionDescriptionView(
                        showView: $showEditDescription,
                        description: $description,
                        sessionId: sessionId
                    )
                }
                
                if showEditSubject {
                    modalBackground { showEditSubject = false }
                    EditSessionSubjectView(
                        showView: $showEditSubject,
                        subject: $subject,
                        sessionId: sessionId
                    )
                }
                
                if showEditLocation {
                    modalBackground { showEditLocation = false }
                    EditSessionLocationView(
                        showView: $showEditLocation,
                        location: $locationDetails,
                        sessionId: sessionId
                    )
                }
                
                if showEditStatus {
                    modalBackground { showEditStatus = false }
                    EditSessionStatusView(
                        showView: $showEditStatus,
                        isOpen: $isOpen,
                        sessionId: sessionId
                    )
                }
                
                if showEditStudyDay {
                    modalBackground { showEditStudyDay = false }
                    EditSessionStudyDayView(
                        showView: $showEditStudyDay,
                        studyDay: $studyDay,
                        sessionId: sessionId
                    )
                }

                if showEditStartTime {
                    modalBackground { showEditStartTime = false }
                    EditSessionStartTimeView(
                        showView: $showEditStartTime,
                        startTime: $startTime,
                        sessionId: sessionId
                    )
                }

                if showEditEndTime {
                    modalBackground { showEditEndTime = false }
                    EditSessionEndTimeView(
                        showView: $showEditEndTime,
                        endTime: $endTime,
                        sessionId: sessionId
                    )
                }
            }
            .navigationTitle("Edit Session")
            
        }
        .task {
            await fetchSessionData()
        }
    }
    
    
    // MARK: - Blur State
    
    private var shouldBlur: Bool {
        showEditTitle ||
        showEditDescription ||
        showEditSubject ||
        showEditLocation ||
        showEditStatus
    }
    
    // MARK: - Styled Row (IDENTICAL STYLE)
    
    private func sessionRow(value: String,
                            title: String,
                            action: @escaping () -> Void) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.gray)
                
                Text(value.isEmpty ? "Not set" : value)
                    .font(.system(size: 16))
                    .foregroundColor(.primary)
            }
            
            Spacer()
            
            Image(systemName: "pencil.circle.fill")
                .font(.system(size: 20))
                .foregroundColor(.blue)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            action()
        }
    }
    
   
    
    private func modalBackground(dismiss: @escaping () -> Void) -> some View {
        Color.black.opacity(0.3)
            .ignoresSafeArea()
            .onTapGesture {
                dismiss()
            }
    }
    
    
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    private func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    @Previewable @State var sessionId = "768ef53d-31bb-461e-88a4-fd259cccc603"
    return EditSessionView(sessionId: $sessionId)
}
