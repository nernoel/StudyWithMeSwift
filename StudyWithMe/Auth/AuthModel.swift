import Foundation
import Auth
import Supabase
import Combine

class AuthModel: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var currentUser: User?
    
    private let supabase = SupabaseClient(
        supabaseURL: URL(string: SupabaseConfig.SUPABASE_URL)!,
        supabaseKey: SupabaseConfig.SUPABASE_KEY
    )
    
    init() {
        Task {
            await checkAuthStatus()
        }
    }
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
    
    func resetPassword(email: String) async throws {
        try await supabase.auth.resetPasswordForEmail(email)
    }
    
    func signOut() async {
        do {
            try await supabase.auth.signOut()
            self.currentUser = nil
            self.isAuthenticated = false
        } catch {
            print("Sign out error: \(error)")
        }
    }
    
    func signIn(email: String, password: String) async throws {
        let response = try await supabase.auth.signIn(
            email: email,
            password: password
        )
        self.currentUser = response.user
        self.isAuthenticated = true
    }
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
