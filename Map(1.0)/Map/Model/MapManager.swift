//
//  MapManager.swift
//  Map(1.0)
//
//  Created by Wei Kang Tan on 02/10/2024.
//

import Foundation
import CoreLocation

protocol MapManagerDelegate: AnyObject {
    func didFetchAreaData(_ areasModel: [AreaModel])
    func didFetchStreetAndParkingSpotData(_ streetsModel: [StreetModel])
    func didFetchParkingSpotData(_ parkingSpotModel: [ParkingSpotModel])
}

extension MapManagerDelegate {
    func didFetchAreaData(_ areasModel: [AreaModel]) {
        print("did fetch area data")
    }
    
    func didFetchStreetAndParkingSpotData(_ streetsModel: [StreetModel]) {
        print("did fetch street data")
    }
    
    func didFetchParkingSpotData(_ parkingSpotModel: [ParkingSpotModel]){
        print("did fetch parking spot data")
    }
}

struct MapManager {
    private let supabase = SupabaseManager.shared.client
    
    weak var delegate: MapManagerDelegate?
    var userLocation: UserLocation?
    
    func fetchAreaData() {
        Task {
            do {
                let areasData: [AreaData] = try await supabase
                    .from("Area")
                    .select()
                    .execute()
                    .value
                var areasModel: [AreaModel] = []
                
                guard let userLocation = userLocation else {
                    print("Fail to get user location")
                    return
                }
                
                for areaData in areasData {
                    let areaID = areaData.areaID
                    let areaName = areaData.areaName
                    let latitude = areaData.latitude
                    let longitude = areaData.longitude
                    let areaLocation = CLLocation(latitude: latitude, longitude: longitude)
                    
                    // Calculate the distance between user and area
                    let distance = calculateDistance(userLocation.location, areaLocation)
                    
                    guard let parkingSpotArray = await fetchParkingSpotArray(areaID: areaID) else {
                        print("Error Fetching Parking Spot Array (total parking & available Parking")
                        return
                    }
                    
                    let totalParking = parkingSpotArray.totalParking
                    let availableParking = parkingSpotArray.availableParking
                    
                    // Create the area model with the calculated distance
                    let areaModel = AreaModel(
                        areaID: areaID,
                        areaName: areaName,
                        latitude: latitude,
                        longtitude: longitude,
                        totalParking: totalParking,
                        availableParking: availableParking,
                        numGreen: parkingSpotArray.numGreen,
                        numYellow: parkingSpotArray.numYellow,
                        numRed: parkingSpotArray.numRed,
                        numDisable: parkingSpotArray.numDisable,
                        distance: distance
                    )
                    
                    areasModel.append(areaModel)
                }
                
                // Sort areasModel by distance
                areasModel.sort { $0.distance ?? 0 < $1.distance ?? 0 }
                
                // Notify the delegate with the sorted data
                delegate?.didFetchAreaData(areasModel)
                
            } catch {
                print("Error fetching data: \(error.localizedDescription)")
            }
        }
    }
    
    
    func fetchParkingSpotArray(areaID: Int) async -> ParkingSpotArray? {
        do {
            let parkingSpotArray: ParkingSpotArray = try await supabase
                .rpc("get_area_parking_info", params: ["area_id": areaID])
                .execute()
                .value
            
            print(parkingSpotArray)
            
            return parkingSpotArray
        }catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    func fetchStreetInfo(streetID: Int) async -> StreetInfoData? {
        do {
            let streetInfoData: StreetInfoData = try await supabase
                .rpc("get_available_parking_count_by_type_street", params: ["street_id": streetID])
                .execute()
                .value
            
            print(streetInfoData)
            
            return streetInfoData
        }catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    func fetchStreetAndParkingSpotData(areaID: Int) {
        Task {
            do {
                let streetsData: [StreetData] = try await supabase
                    .from("Street")
                    .select()
                    .eq("areaID", value: areaID)
                    .execute()
                    .value
                
                var streetsModel: [StreetModel] = []  // Initialize as an empty array
                
                for streetData in streetsData {
                    let streetID = streetData.streetID
                    
                    // Fetch parking spots for the current street
                    let parkingSpotsData: [ParkingSpotData] = try await supabase
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
                        .eq("streetID", value: streetID)
                        .execute()
                        .value
                    
                    
                    guard let userLocation = userLocation else {
                        print("dont get user location")
                        return
                    }
                    
                    var parkingSpotModels: [ParkingSpotModel] = []
                    
                    for parkingSpotData in parkingSpotsData {
                        let parkingLocation = CLLocation(latitude: parkingSpotData.latitude, longitude: parkingSpotData.longitude)
                        let distance = calculateDistance(userLocation.location, parkingLocation)
                        let parkingSpotModel = ParkingSpotModel(
                            parkingSpotID: parkingSpotData.parkingSpotID,
                            isAvailable: parkingSpotData.isAvailable,
                            type: parkingSpotData.type,
                            latitude: parkingSpotData.latitude,
                            longitude: parkingSpotData.longitude,
                            streetName: parkingSpotData.street.streetName,
                            areaName: parkingSpotData.street.area.areaName,
                            distance: distance
                        )
                        
                        print(parkingSpotModel)
                        parkingSpotModels.append(parkingSpotModel)
                    }
                    
                    guard let streetInfoData = await fetchStreetInfo(streetID: streetID) else {
                        return
                    }
                    
                    // Create StreetModel and append to streetsModel
                    let streetModel = StreetModel(
                        streetID: streetData.streetID,
                        streetName: streetData.streetName,
                        areaID: streetData.areaID,
                        numGreen: streetInfoData.numGreen,
                        numRed: streetInfoData.numRed,
                        numYellow: streetInfoData.numYellow,
                        numDisable: streetInfoData.numDisable,
                        numAvailable: streetInfoData.numAvailable,
                        parkingSpots: parkingSpotModels
                    )
                    
                    streetsModel.append(streetModel)
                }
                
                // Notify delegate with fetched data
                if streetsModel.isEmpty {
                    print("No data fetched for streets.")
                } else {
                    print(streetsModel)
                    delegate?.didFetchStreetAndParkingSpotData(streetsModel)
                }
                
            } catch {
                print("Error fetching street data: \(error.localizedDescription)")
            }
        }
    }
    
    func fetchParkingSpotData() {
        Task {
            do {
                // Fetch parking spot data including street and area relationships
                guard let userLocation = userLocation else {
                    print("user Location is nil")
                    return
                }
                
                let parkingSpotsData: [ParkingSpotData] = try await supabase
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
                    .eq("isAvailable", value: true)
                    .execute()
                    .value
                
                var parkingSpotModels: [ParkingSpotModel] = []
                for parkingSpotData in parkingSpotsData {
                    let parkingLocation = CLLocation(latitude: parkingSpotData.latitude, longitude: parkingSpotData.longitude)
                    let distance = calculateDistance(userLocation.location, parkingLocation)
                    let areaName = parkingSpotData.street.area.areaName
                    let streetName = parkingSpotData.street.streetName
                    let availableParking = ParkingSpotModel(
                        parkingSpotID: parkingSpotData.parkingSpotID,
                        isAvailable: parkingSpotData.isAvailable,
                        type: parkingSpotData.type,
                        latitude: parkingSpotData.latitude,
                        longitude: parkingSpotData.longitude,
                        streetName: streetName,
                        areaName: areaName,
                        distance: distance
                    )
                    parkingSpotModels.append(availableParking)
                }
                parkingSpotModels.sort { $0.distance ?? 0.0 < $1.distance ?? 0.0 }
                delegate?.didFetchParkingSpotData(parkingSpotModels)
                print("Have fetch parking spot data")
                
            } catch {
                // Print the error if the query fails
                print("Error fetching parking spot data: \(error.localizedDescription)")
            }
        }
    }
    
    
    func calculateDistance(_ depart: CLLocation, _ destination: CLLocation) -> CLLocationDistance {
        let distance = depart.distance(from: destination)
        return distance
    }
    
    func distanceToDistanceString(distance: Double) -> String{
        var distance = distance
        let distanceString: String
        if distance > 1000{
            distance = distance/1000
            distanceString = String(format: "%.1f KM", distance)
        }else {
            distanceString = String(format: "%.0f M", distance)
        }
        return distanceString
    }
}
