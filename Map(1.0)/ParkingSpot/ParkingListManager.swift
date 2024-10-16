//
//  ParkingListManager.swift
//  Map(1.0)
//
//  Created by Wei Kang Tan on 18/12/2024.
//

protocol ParkingListManagerDelegate {
    func didFetchAllParkingSpot(_ parkingSpotModels: [ParkingSpotModel])
}

struct ParkingListManager {
    let supabase = SupabaseManager.shared.client
    var delegate: ParkingListManagerDelegate?
    
    func fetchAllParkingSpot() {
        Task{
            do {
                let parkingSpotData: [ParkingSpotData] = try await supabase
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
                    .execute()
                    .value
                
                var parkingSpotModels: [ParkingSpotModel] = []
                
                for parkingSpot in parkingSpotData {
                    let parkingSpotModel = ParkingSpotModel(parkingSpotID: parkingSpot.parkingSpotID, isAvailable: parkingSpot.isAvailable, type: parkingSpot.type, latitude: parkingSpot.latitude, longitude: parkingSpot.longitude, streetName: parkingSpot.street.streetName, areaName: parkingSpot.street.area.areaName, distance: nil)
                    
                    parkingSpotModels.append(parkingSpotModel)
                }
                
                delegate?.didFetchAllParkingSpot(parkingSpotModels)
            }catch {
                print(error.localizedDescription)
            }
        }
        
    }
}
