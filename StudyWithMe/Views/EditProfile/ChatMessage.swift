//
//  ChatMessage.swift
//  StudyWithMe
//
//  Created by Noel Erulu on 3/4/26.
//


import Foundation

nonisolated
struct ChatMessage: Identifiable, Codable {
    let id: UUID
    let conversation_id: UUID
    let sender_id: UUID
    let content: String
    let created_at: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case conversation_id
        case sender_id
        case content
        case created_at
    }
}
