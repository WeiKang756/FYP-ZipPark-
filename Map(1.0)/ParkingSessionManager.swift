//
//  ParkingSessionManager.swift
//  Map(1.0)
//
//  Created by Wei Kang Tan on 19/12/2024.
//

import Foundation

protocol ParkingSessionManagerDelegate {
    func didFetchSession(_ parkingSession: ParkingSession)
}

class ParkingSessionManager {
    let supabase = SupabaseManager.shared.client
    var delegate: ParkingSessionManagerDelegate?
    
    func getSessionStart(_ parkingSessionId: UUID) {
        Task{
            do{
                guard let user = await SupabaseManager.shared.getUser() else {
                    return
                }
                
                let parkingSession: ParkingSession = try await supabase
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
                    .eq("id", value: parkingSessionId)
                    .single()
                    .execute()
                    .value
                
                print(parkingSession)
                delegate?.didFetchSession(parkingSession)
                
            }catch {
                print(error.localizedDescription)
            }
        }
    }
}
