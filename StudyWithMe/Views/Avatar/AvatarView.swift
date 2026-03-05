//
//  ProfilePicture.swift
//  StudyWithMe
//
//  Created by Noel Erulu on 2/28/26.
//
import SwiftUI

struct AvatarView: View {
    let avatarURL: String?
    
    var body: some View {
        if let avatarURL,
           let url = URL(string: avatarURL) {
            
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure:
                    Image(systemName: "xmark.circle")
                        .foregroundColor(.red)
                case .empty:
                    ProgressView()
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 80, height: 80)
            .clipShape(Circle())
            
        } else {
            Image("anon_profilepic")
                .resizable()
                .scaledToFill()
                .frame(width: 80, height: 80)
                .clipShape(Circle())
        }
    }
}

#Preview {
    AvatarView(avatarURL: "")
}
