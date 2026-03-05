import Foundation
import Supabase

final class ConversationService {
    
    static let shared = ConversationService()
    
    private let supabase = SupabaseManager.shared.client
    
    private init() {}
    
    nonisolated
    struct EmptyConversation: Encodable {}
    
    // MARK: - Get or Create Conversation
    func getOrCreateConversation(with otherUserId: UUID) async throws -> UUID {
        
        let currentUserId = try await supabase.auth.session.user.id
        
        // Step 1: Get all conversations current user is in
        let myParticipations: [ConversationParticipant] = try await supabase.database
            .from("conversation_participants")
            .select()
            .eq("user_id", value: currentUserId)
            .execute()
            .value
        
        print("Current user:", currentUserId)
        print("Other user:", otherUserId)
        
        let myConversationIds = myParticipations.map { $0.conversation_id }
        
        // Step 2: Check if other user is in any of those conversations
        if !myConversationIds.isEmpty {
            
            let sharedParticipants: [ConversationParticipant] = try await supabase.database
                .from("conversation_participants")
                .select()
                .eq("user_id", value: otherUserId)
                .in("conversation_id", value: myConversationIds)
                .execute()
                .value
            
            if let existing = sharedParticipants.first {
                return existing.conversation_id
            }
        }
        
        // Step 3: Create new conversation
        let newConversation: Conversation = try await supabase.database
            .from("conversations")
            .insert(EmptyConversation())
            .select()
            .single()
            .execute()
            .value
        
        print("Created conversation:", newConversation.id)
        
        // Step 4: Add both participants
        let participants = [
            ConversationParticipant(conversation_id: newConversation.id, user_id: currentUserId),
            ConversationParticipant(conversation_id: newConversation.id, user_id: otherUserId)
        ]
        
        try await supabase.database
            .from("conversation_participants")
            .insert(participants)
            .execute()
        
        return newConversation.id
    }
    
    // MARK: - Fetch Conversations
    func fetchConversations() async throws -> [Conversation] {
        
        let currentUserId = try await supabase.auth.session.user.id
        
        let participations: [ConversationParticipant] = try await supabase.database
            .from("conversation_participants")
            .select()
            .eq("user_id", value: currentUserId)
            .execute()
            .value
        
        let convoIds = participations.map { $0.conversation_id }
        
        guard !convoIds.isEmpty else { return [] }
        
        let conversations: [Conversation] = try await supabase.database
            .from("conversations")
            .select()
            .in("id", value: convoIds)
            .execute()
            .value
        
        return conversations
    }
    
    // MARK: - Fetch Messages
    func fetchMessages(conversationId: UUID) async throws -> [Message] {
        
        let messages: [Message] = try await supabase.database
            .from("messages")
            .select()
            .eq("conversation_id", value: conversationId)
            .order("created_at", ascending: true)
            .execute()
            .value
        
        return messages
    }
    
    // MARK: - Send Message
    func sendMessage(conversationId: UUID, text: String) async throws {
        
        let currentUserId = try await supabase.auth.session.user.id
        
        let newMessage = MessageInsert(
            conversation_id: conversationId,
            sender_id: currentUserId,
            content: text
        )
        
        try await supabase.database
            .from("messages")
            .insert(newMessage)
            .execute()
    }
}
