//
//  Untitled.swift
//  Map(1.0)
//
//  Created by Wei Kang Tan on 14/11/2024.
//

import Foundation

struct VehicleModel: Codable {
    let user: UUID
    let plateNumber: String
    let description: String
    let color: String
    
    enum CodingKeys: String, CodingKey {
        case user = "user_id"
        case plateNumber = "plate_number"
        case description
        case color
    }
}
