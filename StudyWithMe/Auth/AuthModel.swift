import Foundation
import Auth
import Supabase
import Combine

/*
 Class checks if user is authenticated or not
 Keeps track of the user's auth status in the application
 Includes various methods to check user auth status
 */
class AuthModel: ObservableObject {
    private let supabase = SupabaseManager.shared.client
    
    @Published var isAuthenticated: Bool = false
    @Published var currentUser: User?
    
    init() {
        Task {
            await checkAuthStatus()
        }
    }
    
    // Check users auth status
    @MainActor
    func checkAuthStatus() async {
        do {
            let session = try await supabase.auth.session
            let user = session.user
            self.currentUser = user
            self.isAuthenticated = true
            
        } catch {
            print("No active session: \(error)")
            self.isAuthenticated = false
            self.currentUser = nil
        }
    }
        
    // Get the current auth user ID
    func getCurrentUserId() async -> UUID? {
        do {
            let userId = try await supabase.auth.session.user.id
            return userId
        } catch {
            print("No active session: \(error)")
            return nil
        }
    }
    
    // Reset user passsword
    func resetPassword(email: String) async throws {
        try await supabase.auth.resetPasswordForEmail(email)
    }
    
    // Sign out user
    func signOut() async {
        do {
            try await supabase.auth.signOut()
            self.currentUser = nil
            self.isAuthenticated = false
        } catch {
            print("Sign out error: \(error)")
        }
    }
    
    // Sign in user
    func signIn(email: String, password: String) async throws {
        let response = try await supabase.auth.signIn(
            email: email,
            password: password
        )
        self.currentUser = response.user
        self.isAuthenticated = true
    }
    
    // Register a new user
    @MainActor
    func register(email: String, password: String) async throws {
        let response = try await supabase.auth.signUp(
            email: email,
            password: password
        )
        self.currentUser = response.user
        self.isAuthenticated = true
    }
}
