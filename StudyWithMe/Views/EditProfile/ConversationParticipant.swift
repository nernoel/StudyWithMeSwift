//
//  ConversationParticipant.swift
//  StudyWithMe
//
//  Created by Noel Erulu on 3/4/26.
//


import Foundation

nonisolated
struct ConversationParticipant: Codable {
    let conversation_id: UUID
    let user_id: UUID
}
