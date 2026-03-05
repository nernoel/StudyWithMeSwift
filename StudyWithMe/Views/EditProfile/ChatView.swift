//
//  ChatView 2.swift
//  StudyWithMe
//
//  Created by Noel Erulu on 3/4/26.
//


import SwiftUI

struct ChatView: View {
    
    let conversationId: UUID
    let friendName: String?
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: ChatViewModel
    @State private var messageText: String = ""
    
    init(conversationId: UUID, friendName: String?) {
        self.conversationId = conversationId
        self.friendName = friendName
        _viewModel = StateObject(
            wrappedValue: ChatViewModel(conversationId: conversationId)
        )
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            
                            if viewModel.messages.isEmpty {
                                Text("No messages yet.")
                                    .foregroundColor(.gray)
                                    .padding(.top, 40)
                            }
                            
                            ForEach(viewModel.messages) { message in
                                messageBubble(for: message)
                                    .id(message.id)
                            }
                        }
                        .padding()
                    }
                    .onChange(of: viewModel.messages.count) { _ in
                        if let last = viewModel.messages.last {
                            withAnimation {
                                proxy.scrollTo(last.id, anchor: .bottom)
                            }
                        }
                    }
                }
                
                Divider()
                
                HStack(spacing: 8) {
                    TextField("Type a message...", text: $messageText)
                        .textFieldStyle(.roundedBorder)
                    
                    Button {
                        Task { await sendMessage() }
                    } label: {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.blue)
                            .clipShape(Circle())
                    }
                }
                .padding()
            }
            .navigationTitle(friendName ?? "Chat")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
        .task {
            print("📥 ChatView opened with ID:", conversationId)
            await viewModel.fetchMessages()
        }
    }
    
    @ViewBuilder
    private func messageBubble(for message: Message) -> some View {
        HStack {
            if message.sender_id == viewModel.currentUserId {
                Spacer()
                Text(message.content)
                    .padding(12)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(16)
                    .frame(maxWidth: 250, alignment: .trailing)
            } else {
                Text(message.content)
                    .padding(12)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(16)
                    .frame(maxWidth: 250, alignment: .leading)
                Spacer()
            }
        }
    }
    
    private func sendMessage() async {
        let trimmed = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        messageText = ""
        
        do {
            try await viewModel.sendMessage(content: trimmed)
            await viewModel.fetchMessages()
        } catch {
            print("Send error:", error)
        }
    }
}

#Preview {
    ChatView(conversationId: UUID(), friendName: "John")
}
