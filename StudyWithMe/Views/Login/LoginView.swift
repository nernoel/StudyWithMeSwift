import SwiftUI
import Auth
import Supabase

struct LoginView: View {
    
    @EnvironmentObject var authModel : AuthModel
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String? = nil
    @State private var isLoading: Bool = false
    
    private let supabase = SupabaseManager.shared.client
        
    var body: some View {
        
        NavigationStack {
            
            VStack(spacing: 24) {
                
                Spacer()
                
                Text("StudyWithMe")
                    .font(.largeTitle)
                    .bold()
                    .fontWidth(.expanded)
                
                Text("Please sign in to continue")
                    .font(.subheadline)
                    .foregroundStyle(Color.gray.opacity(0.7))
                
                VStack(spacing: 20) {
                    
                    TextField("Email", text: $email)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(16)
                        .frame(width: 350)
                        .textInputAutocapitalization(.never)
                    
                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(16)
                        .frame(width: 350)
                        .textInputAutocapitalization(.never)
                    
                    if let errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                    
                    Button {
                        Task {
                            await signIn()
                        }
                    } label: {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("Sign In")
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(16)
                        .shadow(color: .gray.opacity(0.3), radius: 8)
                    }
                    .disabled(isLoading)
                }
                .padding(.horizontal, 24)
                
                Spacer()
                
                // ✅ Register Link
                NavigationLink("Don't have an account? Register") {
                    RegistrationView()
                        .environmentObject(authModel)
                }
                .font(.footnote)
                .padding(.bottom, 30)
            }
            .navigationBarBackButtonHidden(true)
        }
    }
    
    // MARK: - Sign In Logic
    
    private func signIn() async {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter email and password."
            return
        }
        
        do {
            isLoading = true
            try await authModel.signIn(email: email, password: password)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthModel())
}
