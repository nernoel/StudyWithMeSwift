//
//  LoginView.swift
//  StudyWithMe
//
//  Created by Noel Erulu on 2/24/26.
//
import SwiftUI

import Auth
import Supabase

struct LoginView: View {
    @EnvironmentObject var authModel : AuthModel
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String? = nil
    @State private var isLoading: Bool = false
    
    
    private let supabase = SupabaseClient(
        supabaseURL: URL(string: SupabaseConfig.SUPABASE_URL)!,
        supabaseKey: SupabaseConfig.SUPABASE_KEY
    )
        
    var body: some View {
        NavigationStack() {
            Text("Login")
            ZStack {
                if isLoading {
                    ProgressView {
                        Text("Logging in")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                VStack {
                    TextField(
                        "Email address", text: $email
                    )
                    .textInputAutocapitalization(.never)
                    SecureField(
                        "Password", text: $password
                    )
                    .textInputAutocapitalization(.never)
                    Button("Click to login", action: {
                        Task {
                            do {
                                try await authModel.signIn(email: email, password: password)
                                print("Button clicked")
                                isLoading = true
                            } catch {
                                print("Login failed", error.localizedDescription)
                            }
                        }
                    })
                    NavigationLink(destination:
                                    HomeView()
                        .environmentObject(authModel)) {
                            
                        }
                }
                
            }
        }
        
        .navigationBarBackButtonHidden(true)
    }
}
        

#Preview {
    LoginView()
        .environmentObject(AuthModel())
}

