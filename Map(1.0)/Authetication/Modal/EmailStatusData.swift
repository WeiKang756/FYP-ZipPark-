//
//  EmailStatus.swift
//  Map(1.0)
//
//  Created by Wei Kang Tan on 15/10/2024.
//

// Define a struct that matches the structure of the JSON
struct EmailStatus: Codable {
    let exists: Bool
    let isVerified: Bool
    
    // If the JSON keys don't match Swift naming conventions, use CodingKeys
    enum CodingKeys: String, CodingKey {
        case exists
        case isVerified = "is_verified"
    }
}
