//
//  ParkingSpotModel.swift
//  Map(1.0)
//
//  Created by Wei Kang Tan on 04/10/2024.
//

import Foundation

struct ParkingSpotModel {
    let parkingSpotID: Int
    let isAvailable: Bool
    let type: String
    let latitude: Double
    let longitude: Double
    let streetName: String
    let areaName: String
    let distance: Double?
}
