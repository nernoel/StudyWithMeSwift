//
//  RegistrationView.swift
//  StudyWithMe
//
//  Created by Noel Erulu on 3/4/26.
//


//
//  RegistrationView.swift
//  StudyWithMe
//

import SwiftUI
import Supabase
import Auth

struct RegistrationView: View {
    
    @EnvironmentObject var authModel: AuthModel
    
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    
    @State private var errorMessage: String? = nil
    @State private var isLoading: Bool = false
    
    var body: some View {
        
        NavigationStack {
            
            VStack(spacing: 16) {
                
                // Title
                Text("Create Account")
                    .font(.largeTitle)
                    .bold()
                    .fontWidth(.expanded)
                
                Text("Join StudyWithMe")
                    .font(.subheadline)
                    .foregroundStyle(Color.gray.opacity(0.7))
                
                VStack(spacing: 20) {
                    
                    
                    // Email
                    TextField("Email", text: $email)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(16)
                        .frame(width: 350)
                        .textInputAutocapitalization(.never)
                    
                    // Password
                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(16)
                        .frame(width: 350)
                    
                    // Confirm Password
                    SecureField("Confirm Password", text: $confirmPassword)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(16)
                        .frame(width: 350)
                    
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                    
                    // Register Button
                    Button {
                        Task {
                            await register()
                        }
                    } label: {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(.circular)
                                    .tint(.white)
                            } else {
                                Text("Create Account")
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(16)
                        .shadow(color: .gray.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .disabled(isLoading)
                    
                }
                .padding(.horizontal, 24)
                
                Spacer()
                
                NavigationLink("Already have an account? Sign In", destination: LoginView())
                    .font(.footnote)
                
            }
            .navigationBarBackButtonHidden(true)
        }
    }
    
    // MARK: - Register Logic
    
    private func register() async {
        guard !email.isEmpty,
              !password.isEmpty else {
            errorMessage = "All fields are required."
            return
        }
        
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match."
            return
        }
        
        do {
            isLoading = true
            try await authModel.register(
                email: email,
                password: password,
            )
            
            print("Registration successful")
            
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}

#Preview {
    RegistrationView()
}
