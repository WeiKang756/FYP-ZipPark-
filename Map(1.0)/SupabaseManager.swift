import Foundation
import Supabase

class SupabaseManager {
    // MARK: - Properties
    static let shared = SupabaseManager()
    let client: SupabaseClient
    
    // MARK: - Configuration
    private enum Constants {
        static let supabaseURL = "https://tjglkbohqkecpjuxsvvl.supabase.co"
        static let supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRqZ2xrYm9ocWtlY3BqdXhzdnZsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mjc3MDY2MjYsImV4cCI6MjA0MzI4MjYyNn0.kl0bEJiPKYPFTBsWB2mrxgzVXB6eBE7uAbjLEAHjNzY"
    }
    
    // MARK: - Error Handling
    enum SupabaseError: Error {
        case invalidURL
        case sessionError
        case signOutError
        
        var localizedDescription: String {
            switch self {
            case .invalidURL:
                return "Invalid Supabase URL"
            case .sessionError:
                return "Failed to get session"
            case .signOutError:
                return "Failed to sign out"
            }
        }
    }
    
    // MARK: - Initialization
    private init() {
        guard let supabaseURL = URL(string: Constants.supabaseURL) else {
            fatalError(SupabaseError.invalidURL.localizedDescription)
        }
        
        self.client = SupabaseClient(
            supabaseURL: supabaseURL,
            supabaseKey: Constants.supabaseKey
        )
    }
    
    // MARK: - Public Methods
    func getUser() async -> User?  {
           do {
               let session = try await client.auth.session
               let user = session.user
               return user
           }catch {
               print("fail to get session")
               return nil
           }
       }
    
    func getCurrentSession() async throws -> Session {
        return try await client.auth.session
    }

    func signOut() {
        Task{
            do{
                try await client.auth.signOut()
            }catch{
                print(error.localizedDescription)
            }
        }
    }
}
