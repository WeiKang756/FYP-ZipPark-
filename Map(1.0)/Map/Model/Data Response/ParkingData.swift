//
//  ParkingData.swift
//  Map(1.0)
//
//  Created by Wei Kang Tan on 04/10/2024.
//

import Foundation

struct ParkingSpotData: Decodable {
    let parkingSpotID: Int
    let id: Int
    let isAvailable: Bool
    let latitude: Double
    let longitude: Double
    let type: String
    let streetID: Int
}
