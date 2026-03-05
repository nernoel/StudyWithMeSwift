//
//  ShowEditUsernameView.swift
//  StudyWithMe
//
//  Created by Noel Erulu on 3/1/26.
//
import SwiftUI
import Supabase

struct EditUsernameView: View {
    private let supabase = SupabaseManager.shared.client
    @Binding var showEditUsernameView: Bool
    @State private var newUsername: String = ""
    
    @State private var isLoading: Bool = false
    
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Edit username")
                .font(.headline)
                .fontWidth(.expanded)
            
            TextField("Enter your new username", text: $newUsername)
                .frame(width: 250)
        
            Button() {
                Task {
                    do {
                        isLoading = true
                        try await supabase.database
                            .from("profiles")
                            .update(["username": newUsername])
                            .eq("id", value: supabase.auth.session.user.id)
                            .execute()
                        
                        // On success
                        isLoading = false
                        showEditUsernameView = false
                        
                    } catch {
                        print("Error occurred updating username", error.localizedDescription)
                    }
                }
            } label : {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(.blue)
                } else {
                    Text("Save")
                        .fontWeight(.semibold)
                }
            }
            // After user updates toggle isLoading to false
            .disabled(isLoading)
           
            
        }
        .padding()
        .frame(width: 300, height: 100)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
        
        
       
    }
}

#Preview {
    EditUsernameView(showEditUsernameView: .constant(true))
}
