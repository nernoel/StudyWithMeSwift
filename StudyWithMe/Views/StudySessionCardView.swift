//
//  StudySessionCardView.swift
//  StudyWithMe
//
//  Created by Noel Erulu on 2/26/26.
//
//
//  StudySessionCardView.swift
//  StudyWithMe
//

import SwiftUI

struct StudySessionCardView: View {
    
    let session: UserStudySession
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            Text(session.title)
                .font(.headline)
            
            Text(session.description)
                .font(.subheadline)
                .foregroundColor(.gray)
                .lineLimit(2)
            
            HStack {
                Text(session.isOpen ? "Open" : "Closed")
                    .font(.caption)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(session.isOpen ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
                    .foregroundColor(session.isOpen ? .green : .red)
                    .cornerRadius(8)
                
                Spacer()
            }
            
        }
        .padding()
        .frame(width: 260)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 4)
    }
}
