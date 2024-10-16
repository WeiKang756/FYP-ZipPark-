//
//  SessionResponse.swift
//  Map(1.0)
//
//  Created by Wei Kang Tan on 20/11/2024.
//

import Foundation


// Main response structure
struct SessionResponse: Decodable {
    let success: Bool
    let message: String
    let sessionId: String?
    let data: SessionData?
    
    enum CodingKeys: String, CodingKey {
        case success
        case message
        case sessionId = "session_id"
        case data
    }
}

// Session data structure
struct SessionData: Decodable {
    let startTime: String
    let endTime: String
    let duration: String
    let date: String
    let cost: Decimal
    let remainingBalance: Decimal
    let parkingSpotId: Int
    let plateNumber: String
    
    enum CodingKeys: String, CodingKey {
        case startTime = "start_time"
        case endTime = "end_time"
        case duration
        case date
        case cost
        case remainingBalance = "remaining_balance"
        case parkingSpotId = "parking_spot_id"
        case plateNumber = "plate_number"
    }
}
