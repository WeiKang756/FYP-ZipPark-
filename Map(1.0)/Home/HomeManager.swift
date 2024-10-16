//
//  HomeManager.swift
//  Map(1.0)
//
//  Created by Wei Kang Tan on 04/12/2024.
//

protocol HomeManagerDelegate {
    func didFetchSession(_ parkingSessions: [ParkingSession])
}

class HomeManager {
    let supabase = SupabaseManager.shared.client
    var delegate: HomeManagerDelegate?
    
    func getSessionStart() {
        Task{
            do{
                guard let user = await SupabaseManager.shared.getUser() else {
                    return
                }
                
                let parkingSessions: [ParkingSession] = try await supabase
                    .from("parking_sessions")
                    .select("""
                        *,
                        ParkingSpot:parking_spot_id (
                            parkingSpotID,
                            latitude,
                            longitude,
                            type,
                            isAvailable,
                            Street (
                                streetName,
                                Area (
                                    areaName
                                )
                            )
                        )
                    """)
                    .eq("user_id", value: user.id)
                    .eq("status", value: "active")
                    .execute()
                    .value
                
                print(parkingSessions)
                delegate?.didFetchSession(parkingSessions)
                for parkingSession in parkingSessions {
                    let timeLeft = parkingSession.calculateTimeLeft()
                    print(timeLeft)
                }
            }catch {
                print(error.localizedDescription)
            }
        }
    }
}
