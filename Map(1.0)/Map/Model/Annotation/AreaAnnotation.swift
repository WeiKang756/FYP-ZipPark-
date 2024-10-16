//
//  CustomAnnotatio.swift
//  Map(1.0)
//
//  Created by Wei Kang Tan on 19/09/2024.
//

import Foundation
import MapKit

class AreaAnnotation: NSObject, MKAnnotation {
    let title: String?
    let availableParking: String
    let coordinate: CLLocationCoordinate2D
    let area: AreaModel
    
    init(title: String?, availableParking: String, coordinate: CLLocationCoordinate2D, area: AreaModel) {
        self.title = title
        self.availableParking = availableParking
        self.coordinate = coordinate
        self.area = area
        super.init()
    }
}
