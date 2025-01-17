import Foundation
import CoreLocation
import Supabase

// MARK: - Protocols
protocol MapManagerDelegate: AnyObject {
    func didFetchAreaData(_ areasModel: [AreaModel])
    func didFetchStreetAndParkingSpotData(_ streetsModel: [StreetModel])
    func didFetchParkingSpotData(_ parkingSpotModel: [ParkingSpotModel])
}

// MARK: - Default Protocol Implementation
extension MapManagerDelegate {
    func didFetchAreaData(_ areasModel: [AreaModel]) {
        print("Did fetch area data")
    }
    
    func didFetchStreetAndParkingSpotData(_ streetsModel: [StreetModel]) {
        print("Did fetch street data")
    }
    
    func didFetchParkingSpotData(_ parkingSpotModel: [ParkingSpotModel]) {
        print("Did fetch parking spot data")
    }
}

// MARK: - Error Types
enum MapManagerError: Error {
    case userLocationNotAvailable
    case parkingDataFetchFailed(areaID: Int)
    case streetDataFetchFailed(streetID: Int)
    case invalidData
}

// MARK: - MapManager Implementation
struct MapManager {
    // MARK: - Properties
    private let supabase = SupabaseManager.shared.client
    weak var delegate: MapManagerDelegate?
    var userLocation: UserLocation?
    
    // MARK: - Public Methods
    func fetchAreaData() {
        Task {
            do {
                guard let userLocation = userLocation else {
                    print("Error: User location not available")
                    return
                }
                
                let areasData: [AreaData] = try await supabase
                    .from("Area")
                    .select()
                    .execute()
                    .value
                
                var areasModel: [AreaModel] = []
                
                for areaData in areasData {
                    let areaLocation = CLLocation(latitude: areaData.latitude, longitude: areaData.longitude)
                    let distance = calculateDistance(userLocation.location, areaLocation)
                    
                    guard let parkingSpotArray = await fetchParkingSpotArray(areaID: areaData.areaID) else {
                        print("Error: Unable to fetch parking data for area \(areaData.areaID)")
                        continue
                    }
                    
                    let areaModel = AreaModel(
                        areaID: areaData.areaID,
                        areaName: areaData.areaName,
                        latitude: areaData.latitude,
                        longtitude: areaData.longitude,
                        totalParking: parkingSpotArray.totalParking,
                        availableParking: parkingSpotArray.availableParking,
                        numGreen: parkingSpotArray.numGreen,
                        numYellow: parkingSpotArray.numYellow,
                        numRed: parkingSpotArray.numRed,
                        numDisable: parkingSpotArray.numDisable,
                        distance: distance
                    )
                    
                    areasModel.append(areaModel)
                }
                
                areasModel.sort { $0.distance ?? Double.infinity < $1.distance ?? Double.infinity }
                delegate?.didFetchAreaData(areasModel)
                
            } catch {
                print("Error fetching area data: \(error.localizedDescription)")
            }
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
                
                guard let userLocation = userLocation else {
                    print("Error: User location not available")
                    return
                }
                
                var streetsModel: [StreetModel] = []
                
                for streetData in streetsData {
                    let streetID = streetData.streetID
                    
                    let parkingSpotsData: [ParkingSpotData] = try await supabase
                        .from("ParkingSpot")
                        .select("""
                            *, 
                            Street!inner(
                                streetID,
                                streetName,
                                Area!inner(
                                    areaName
                                )
                            )
                        """)
                        .eq("streetID", value: streetID)
                        .execute()
                        .value
                    
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
                        
                        parkingSpotModels.append(parkingSpotModel)
                    }
                    
                    guard let streetInfoData = await fetchStreetInfo(streetID: streetID) else {
                        print("Error: Unable to fetch street info for street \(streetID)")
                        continue
                    }
                    
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
                
                if !streetsModel.isEmpty {
                    delegate?.didFetchStreetAndParkingSpotData(streetsModel)
                } else {
                    print("No street data available")
                }
                
            } catch {
                print("Error fetching street data: \(error.localizedDescription)")
            }
        }
    }
    
    func fetchParkingSpotData() {
        Task {
            do {
                guard let userLocation = userLocation else {
                    print("Error: User location not available")
                    return
                }
                
                // 1. First fetch parking spots with street information
                let parkingSpotsData: [ParkingSpotData] = try await supabase
                    .from("ParkingSpot")
                    .select("""
                        *, 
                        Street!inner(
                            streetID,
                            streetName,
                            Area!inner(
                                areaName
                            )
                        )
                    """)
                    .eq("isAvailable", value: true)
                    .execute()
                    .value
                
                print("Successfully fetched parking spot data")
                
                // 2. Group spots by street to efficiently fetch street info
                let groupedByStreet = Dictionary(grouping: parkingSpotsData) { $0.street.streetName }
                
                // 3. Create dictionary to store street info
                var streetInfoDict: [String: StreetInfoData] = [:]
                
                // 4. Fetch street info for each unique street
                for (_, spots) in groupedByStreet {
                    if let firstSpot = spots.first {
                        let streetInfo: StreetInfoData = try await supabase
                            .rpc("get_available_parking_count_by_type_street", params: ["street_id": firstSpot.street.streetID])
                            .single()
                            .execute()
                            .value
                        streetInfoDict[firstSpot.street.streetName] = streetInfo
                    }
                }
                
                // 5. Create ParkingSpotModels array
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
                    
                    parkingSpotModels.append(parkingSpotModel)
                }
                
                // 6. Sort using the new ParkingSpotSorter
                let sortedSpots = ParkingSpotSorter.sortParkingSpots(
                    spots: parkingSpotModels,
                    streetInfo: streetInfoDict
                )
                
                // 7. Send sorted results to delegate
                print("Successfully sorted parking spots")
                delegate?.didFetchParkingSpotData(sortedSpots)
            } catch {
                print("Error fetching parking spot data: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Private Methods
    private func fetchParkingSpotArray(areaID: Int) async -> ParkingSpotArray? {
        do {
            let parkingSpotArray: ParkingSpotArray = try await supabase
                .rpc("get_area_parking_info", params: ["area_id": areaID])
                .execute()
                .value
            return parkingSpotArray
        } catch {
            print("Error fetching parking spot array: \(error.localizedDescription)")
            return nil
        }
    }
    
    private func fetchStreetInfo(streetID: Int) async -> StreetInfoData? {
        do {
            let streetInfoData: StreetInfoData = try await supabase
                .rpc("get_available_parking_count_by_type_street", params: ["street_id": streetID])
                .execute()
                .value
            return streetInfoData
        } catch {
            print("Error fetching street info: \(error.localizedDescription)")
            return nil
        }
    }
    
    func calculateDistance(_ depart: CLLocation, _ destination: CLLocation) -> Double {
        return depart.distance(from: destination)
    }
    
    func distanceToDistanceString(distance: Double) -> String {
        var distance = distance
        let distanceString: String
        
        if distance > 1000 {
            distance = distance / 1000
            distanceString = String(format: "%.1f KM", distance)
        } else {
            distanceString = String(format: "%.0f M", distance)
        }
        
        return distanceString
    }
}
