//
//  Conversation.swift
//  StudyWithMe
//
//  Created by Noel Erulu on 3/4/26.
//


import Foundation

nonisolated
struct Conversation: Identifiable, Codable {
    let id: UUID
    let created_at: Date?
}
