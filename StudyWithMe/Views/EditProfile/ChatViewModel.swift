import Foundation
import Supabase
import Combine


@MainActor
final class ChatViewModel: ObservableObject {
    
    @Published var messages: [Message] = []
    @Published var currentUserId: UUID?
    
    private let service = ConversationService.shared
    private let conversationId: UUID
    private let supabase = SupabaseManager.shared.client
    
    init(conversationId: UUID) {
        self.conversationId = conversationId
        
        Task {
            do {
                let session = try await supabase.auth.session
                currentUserId = session.user.id
            } catch {
                print("Failed to get current user:", error)
            }
        }
    }
    
    func fetchMessages() async {
        do {
            messages = try await service.fetchMessages(conversationId: conversationId)
        } catch {
            print("Fetch messages error:", error)
        }
    }
    
    func sendMessage(content: String) async throws {
        try await service.sendMessage(
            conversationId: conversationId,
            text: content
        )
    }
}
