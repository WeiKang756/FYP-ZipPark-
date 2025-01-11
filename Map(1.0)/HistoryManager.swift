//
//  HistoryManager.swift
//  Map(1.0)
//
//  Created by Wei Kang Tan on 18/12/2024.
//

import Supabase
import Foundation

protocol HistoryManagerDelegate {
    func didFetchParkingSessionHistory(_ parkingSession: [ParkingSession])
    func didFetchReportHistory(_ report: [ReportData])
}

struct HistoryManager {
    let supabase = SupabaseManager.shared.client
    var delegate: HistoryManagerDelegate?
    
    func fetchParkingSessionHistory() {
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
                                streetID,
                                streetName,
                                Area (
                                    areaName
                                )
                            )
                        )
                    """)
                    .eq("user_id", value: user.id)
                    .execute()
                    .value
                
                print(parkingSessions)
                delegate?.didFetchParkingSessionHistory(parkingSessions)
                for parkingSession in parkingSessions {
                    let timeLeft = parkingSession.calculateTimeLeft()
                    print(timeLeft)
                }
            }catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func fetchReportHistory() {
        Task{
            do{
                guard let user = await SupabaseManager.shared.getUser() else {
                    return
                }
                
                let reports: [ReportData] = try await supabase
                    .from("reports")
                    .select()
                    .eq("user_id", value: user.id)
                    .execute()
                    .value
                
                print(reports)
                delegate?.didFetchReportHistory(reports)
            }catch{
                print(error.localizedDescription)
            }
        }
    }
}
