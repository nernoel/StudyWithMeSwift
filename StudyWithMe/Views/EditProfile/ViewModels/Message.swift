//
//  Message.swift
//  StudyWithMe
//
//  Created by Noel Erulu on 3/4/26.
//


import Foundation

nonisolated
struct Message: Codable, Identifiable {
    let id: UUID
    let conversation_id: UUID
    let sender_id: UUID
    let content: String
    let created_at: Date
}



nonisolated
struct MessageInsert: Codable {
    let conversation_id: UUID
    let sender_id: UUID
    let content: String
}
