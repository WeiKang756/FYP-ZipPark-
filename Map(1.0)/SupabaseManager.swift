//
//  SupabaseManager.swift
//  Map(1.0)
//
//  Created by Wei Kang Tan on 02/10/2024.
//

import Foundation
import Supabase

class SupabaseManager{
    
    static let shared = SupabaseManager()
    let client: SupabaseClient
    var session: Session?
    
    private init() {
        self.client = SupabaseClient(
            supabaseURL: URL(string: "https://tjglkbohqkecpjuxsvvl.supabase.co")!
/*            supabaseURL: URL(string: "https://aufdbwajjpfoixgsxifr.supabase.co")!*/,
            supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRqZ2xrYm9ocWtlY3BqdXhzdnZsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mjc3MDY2MjYsImV4cCI6MjA0MzI4MjYyNn0.kl0bEJiPKYPFTBsWB2mrxgzVXB6eBE7uAbjLEAHjNzY"
            
//            supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImF1ZmRid2FqanBmb2l4Z3N4aWZyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mjg4NTY3NjYsImV4cCI6MjA0NDQzMjc2Nn0.76TQTSAWMNSnhhwxNUeX2QLgVJ30tTOOgK-cppE91Rw"
        )
    }
    
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
