//
//  Area.swift
//  Map(1.0)
//
//  Created by Wei Kang Tan on 21/09/2024.
//

import Foundation

struct AreaModel {
    let areaID: Int
    let areaName: String
    let latitude: Double
    let longtitude: Double
    let totalParking: Int
    let availableParking: Int
    let numGreen: Int
    let numYellow: Int
    let numRed: Int
    let numDisable: Int
    var availableParkingString: String {
        return String(availableParking)
    }
    var totalParkingString: String {
        return String(totalParking)
    }
    var distance: Double?  
}

