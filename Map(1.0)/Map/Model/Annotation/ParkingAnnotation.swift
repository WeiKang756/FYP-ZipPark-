//
//  ParkingAnnotation.swift
//  Map(1.0)
//
//  Created by Wei Kang Tan on 02/10/2024.
//

import Foundation
import MapKit

class ParkingAnnotation: NSObject, MKAnnotation{
    let patkingLotID: String
    let coordinate: CLLocationCoordinate2D
    let parkingSpotModel: ParkingSpotModel
    
    init(patkingLotID: String, coordinate: CLLocationCoordinate2D, parkingSpotModel: ParkingSpotModel) {
        self.patkingLotID = patkingLotID
        self.coordinate = coordinate
        self.parkingSpotModel = parkingSpotModel
    }
}
