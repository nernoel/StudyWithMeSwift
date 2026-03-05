import SwiftUI
import Supabase

struct ParticipantsListView: View {
    
    let sessionId: UUID
    
    @State private var participants: [SessionParticipant] = []
    @State private var isLoading = true
    @State private var avatarURLs: [UUID: String] = [:]
    
    struct SessionParticipant: Identifiable {
        let id: UUID
        let fullName: String?
        let avatarUrl: String?
    }
    
    private let supabase = SupabaseManager.shared.client
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            Text("Participants")
                .font(.title2.weight(.bold))
                .padding(.horizontal)
            
            if isLoading {
                ProgressView().padding()
            } else if participants.isEmpty {
                Text("No one has joined yet.")
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
            } else {
                ScrollView {
                    VStack(spacing: 14) {
                        ForEach(participants) { participant in
                            participantRow(participant)
                        }
                    }
                    .padding()
                }
            }
        }
        .task {
            await fetchParticipants()
        }
    }
    
    // MARK: - Participant Row
    @ViewBuilder
    private func participantRow(_ participant: SessionParticipant) -> some View {
        HStack(spacing: 16) {
            
            if let urlString = avatarURLs[participant.id], let url = URL(string: urlString) {
                AsyncImage(url: url) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 55, height: 55)
                .clipShape(Circle())
            } else if let path = participant.avatarUrl {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 55, height: 55)
                    .task {
                        await fetchSignedAvatar(for: participant)
                    }
            } else {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 55, height: 55)
                    .foregroundColor(.gray.opacity(0.6))
            }
            
            Text(participant.fullName ?? "Unknown User")
                .font(.headline)
            
            Spacer()
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 18).fill(Color.white))
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 4)
    }
    
    // MARK: - Fetch Participants
    private func fetchParticipants() async {
        isLoading = true
        do {
            struct ParticipantID: Decodable { let user_id: UUID }
            struct Profile: Decodable { let id: UUID; let full_name: String?; let avatar_url: String? }
            
            let participantResponse = try await supabase.database
                .from("study_session_participants")
                .select("user_id")
                .eq("session_id", value: sessionId)
                .execute()
            
            let decoder = JSONDecoder()
            let participantIDs = try decoder.decode([ParticipantID].self, from: participantResponse.data)
            let userIds = participantIDs.map { $0.user_id }
            if userIds.isEmpty {
                participants = []
                isLoading = false
                return
            }
            
            let profileResponse = try await supabase.database
                .from("profiles")
                .select("id, full_name, avatar_url")
                .in("id", value: userIds)
                .execute()
            
            let profiles = try decoder.decode([Profile].self, from: profileResponse.data)
            
            participants = userIds.map { id in
                let profile = profiles.first(where: { $0.id == id })
                return SessionParticipant(
                    id: id,
                    fullName: profile?.full_name,
                    avatarUrl: profile?.avatar_url
                )
            }
            
            // Preload signed URLs
            for participant in participants {
                await fetchSignedAvatar(for: participant)
            }
            
        } catch {
            print("Error fetching participants:", error.localizedDescription)
        }
        isLoading = false
    }
    
    // MARK: - Fetch signed URL for a participant
    private func fetchSignedAvatar(for participant: SessionParticipant) async {
        guard let path = participant.avatarUrl else { return }
        do {
            let signedURL = try await supabase.storage
                .from("avatars")
                .createSignedURL(path: path, expiresIn: 60)
            await MainActor.run {
                avatarURLs[participant.id] = signedURL.absoluteString
            }
        } catch {
            print("Failed to load avatar for participant \(participant.id):", error)
        }
    }
}
