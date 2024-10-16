//
//  QRManager.swift
//  Map(1.0)
//
//  Created by Wei Kang Tan on 26/11/2024.
//

import Foundation

protocol QRManagerDelegate: AnyObject {
    func didFetchParkingSpot(_ parkingSpot: ParkingSpotModel)
    func didFailToFetchParkingSpot(_ error: Error)
}

class QRManager {
    
    let supabase = SupabaseManager.shared.client
    var delegate: QRManagerDelegate?
    
    func fetchParkingSpot(parkingLotID: String) {
        Task{
            do{
                let parkingSpotData: ParkingSpotData = try await supabase
                    .from("ParkingSpot")
                    .select("""
                            *, 
                            Street!inner(
                                streetName,
                                Area!inner(
                                    areaName
                                )
                            )
                            """)
                    .eq("parkingSpotID", value: parkingLotID)
                    .single() 
                    .execute()
                    .value
                
                
                let areaName = parkingSpotData.street.area.areaName
                let streetName = parkingSpotData.street.streetName
                let parking = ParkingSpotModel(
                    parkingSpotID: parkingSpotData.parkingSpotID,
                    isAvailable: parkingSpotData.isAvailable,
                    type: parkingSpotData.type,
                    latitude: parkingSpotData.latitude,
                    longitude: parkingSpotData.longitude,
                    streetName: streetName,
                    areaName: areaName,
                    distance: nil
                )
                print(parking)
                delegate?.didFetchParkingSpot(parking)
            }catch{
                
                delegate?.didFailToFetchParkingSpot(error)
                print("QRManager: \(error.localizedDescription)")
            }
        }
    }
}
