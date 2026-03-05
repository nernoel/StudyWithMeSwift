import SwiftUI
import Supabase

/*
 Supabase client manager class
 Reusable across different components
 Using Singleton pattern
 */
final class SupabaseManager {
    static let shared = SupabaseManager()

    let client: SupabaseClient

    private init() {
        client = SupabaseClient(
            supabaseURL: URL(string: SupabaseConfig.SUPABASE_URL)!,
            supabaseKey: SupabaseConfig.SUPABASE_KEY
        )
    }
}
