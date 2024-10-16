//
//  Street.swift
//  Map(1.0)
//
//  Created by Wei Kang Tan on 02/10/2024.
//

import Foundation

struct StreetModel {
    let streetID: Int
    let streetName: String
    let areaID: Int
    let numGreen: Int
    let numRed: Int
    let numYellow: Int
    let numDisable: Int
    let numAvailable: Int
    let parkingSpots: [ParkingSpotModel]
}
