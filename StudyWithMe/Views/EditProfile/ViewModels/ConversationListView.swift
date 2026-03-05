import Foundation
import Combine

@MainActor
final class ConversationListViewModel: ObservableObject {

    @Published var conversations: [Conversation] = []

    private let service = ConversationService.shared

    func load() async {
        do {
            let fetched = try await service.fetchConversations()
            self.conversations = fetched
        } catch {
            print("Conversation fetch error:", error)
        }
    }
}
