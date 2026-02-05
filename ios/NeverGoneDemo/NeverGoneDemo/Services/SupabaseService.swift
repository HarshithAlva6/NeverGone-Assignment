import Foundation
import Supabase

class SupabaseService {
    static let shared = SupabaseService()
    
    let client: SupabaseClient
    
    private init() {
        self.client = SupabaseClient(
            supabaseURL: URL(string: Constants.supabaseUrl)!,
            supabaseKey: Constants.supabaseAnonKey
        )
    }
}
