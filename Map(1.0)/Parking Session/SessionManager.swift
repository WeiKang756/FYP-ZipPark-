//
//  SessionManager.swift
//  Map(1.0)
//
//  Created by Wei Kang Tan on 19/11/2024.
//
import Foundation

protocol SessionManagerDelegate: AnyObject {
    func didCalculatedParkingCost(_ parkingCostModel: ParkingCostModel)
    func didStartSession(_ session: SessionResponse, _ parkingSpotModel: ParkingSpotModel, _ vehicleModel: VehicleModel)
    func failTostartSession(_ error: String)
}

extension SessionManagerDelegate {
    func didCalculatedParkingCost(_ parkingCostModel: ParkingCostModel) {
        print("did calculated parking cost")
    }
    
    func didStartSession(_ session: SessionResponse, _ parkingSpotModel: ParkingSpotModel, _ vehicleModel: VehicleModel){
        print("did start session")
    }
    
    func failTostartSession(_ error: String){
        print("fail to start")
    }
}

class SessionManager {
    
    private let supabase = SupabaseManager.shared.client
    private let paymentManager = PaymentManager()
    var delegate: SessionManagerDelegate?
    
    // ISO formatter for parsing server responses
    let isoFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0) // Parse as UTC
        return formatter
    }()

    // Formatter for user-facing time strings
    let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.timeZone = TimeZone.current // Local time zone
        return formatter
    }()

    // Formatter for user-facing date strings
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        formatter.timeZone = TimeZone.current // Local time zone
        return formatter
    }()

    func formatParkingTimes(from response: ParkingCostResponse) -> (startTime: String, endTime: String, date: String, duration: String)? {
        guard let data = response.data else {
            return nil
        }
        
        // Parse start and end dates
        guard let startDate = isoFormatter.date(from: data.startTime),
              let endDate = isoFormatter.date(from: data.endTime) else {
            print("Failed to parse dates")
            return nil
        }
        
        // Format for display
        let dateString = self.dateFormatter.string(from: startDate)
        let startTimeFormatted = self.timeFormatter.string(from: startDate)
        let endTimeFormatted = self.timeFormatter.string(from: endDate)
        
        // Calculate duration
        let durationComponents = data.duration.split(separator: ":")
        var durationString = ""
        if let hours = Int(durationComponents[0]),
           let minutes = Int(durationComponents[1]) {
            if hours > 0 {
                durationString += "\(hours)h "
            }
            if minutes > 0 {
                durationString += "\(minutes)min"
            }
        }
        
        return (startTimeFormatted, endTimeFormatted, dateString, durationString)
    }
    
    func calculatePeriodDurations(totalDuration: String, parkingType: String) -> (first: String, second: String?) {
        let components = totalDuration.split(separator: ":")
        guard components.count >= 2,
              let hours = Int(components[0]),
              let minutes = Int(components[1]) else {
            return ("", nil)
        }
        
        let totalMinutes = (hours * 60) + minutes
        let threshold: Int
        
        // Set threshold based on parking type
        switch parkingType {
        case "yellow":
            threshold = 4 * 60  // 4 hours in minutes
        case "red":
            threshold = 1 * 60  // 1 hour in minutes
        default:
            return (formatDuration(minutes: totalMinutes), nil)
        }
        
        // If total duration is less than or equal to threshold
        if totalMinutes <= threshold {
            return (formatDuration(minutes: totalMinutes), nil)
        }
        
        // Calculate first and second period durations
        let firstPeriodMinutes = threshold
        let secondPeriodMinutes = totalMinutes - threshold
        
        return (
            formatDuration(minutes: firstPeriodMinutes),
            formatDuration(minutes: secondPeriodMinutes)
        )
    }
    
    private func formatDuration(minutes: Int) -> String {
        let hours = minutes / 60
        let remainingMinutes = minutes % 60
        
        var formatted = ""
        if hours > 0 {
            formatted += "\(hours)h "
        }
        if remainingMinutes > 0 {
            formatted += "\(remainingMinutes)min"
        }
        return formatted.trimmingCharacters(in: .whitespaces)
    }
    
    
    func calculateParkingCost(parkingSpotModel: ParkingSpotModel, duration: String) {
        Task {
            do {
                // First, let's print the parameters we're sending
                print("Sending parameters: type=\(parkingSpotModel.type), duration=\(duration)")
                
                // Make the RPC call
                let response: ParkingCostResponse = try await supabase
                    .rpc("calculate_parking_cost",
                         params: [
                            "p_parking_type": parkingSpotModel.type,
                            "p_duration": duration
                         ])
                    .execute()
                    .value
                
                // Print the raw response for debugging
                print("Raw Response:", response)
                
                // If successful, print the data
                if response.success {
                    print("Calculation successful:")
                    print("Total Cost:", response.data?.totalCost ?? 0)
                    print("Start Time:", response.data?.startTime ?? "")
                    print("End Time:", response.data?.endTime ?? "")
                    print("Threshold Exceeded:", response.data?.thresholdExceeded ?? false)
                } else {
                    print("Calculation failed:", response.message)
                }
                
                var secondPeriodCost: Double?
                guard let timeInfo = formatParkingTimes(from: response),
                      let data = response.data else {
                    print("fail to parse the date and time/ response data")
                    return
                }
                
                if data.costBreakdown.secondPeriodCost == 0 {
                    secondPeriodCost = nil
                } else {
                    secondPeriodCost = data.costBreakdown.secondPeriodCost
                }
                
                // Calculate period durations
                let periodDurations = calculatePeriodDurations(
                    totalDuration: data.duration,
                    parkingType: parkingSpotModel.type
                )
                
                guard let walletData = await paymentManager.getWallet() else {
                    return
                }
                
                let parkingCostModel = ParkingCostModel(
                    startTime: timeInfo.startTime,
                    endTime: timeInfo.endTime,
                    date: timeInfo.date,
                    duration: timeInfo.duration,
                    totalCost: data.totalCost,
                    firstPeriodCost: data.costBreakdown.firstPeriodCost,
                    secondPeriodCost: secondPeriodCost,
                    wallet: walletData.amount,
                    firstPeriodDuration: periodDurations.first,
                    secondPeriodDuration: periodDurations.second
                )
                
                delegate?.didCalculatedParkingCost(parkingCostModel)
                
            } catch {
                print("Error details:", error)
                print("Error description:", error.localizedDescription)
            }
        }
    }
    
    func startSession(parkingCostModel: ParkingCostModel, parkingSpotModel: ParkingSpotModel, vehicleModel: VehicleModel) {
        Task {
            do {
                guard let user = await SupabaseManager.shared.getUser() else {
                    print("Failed to get user object")
                    return
                }
                
                let userId = user.id
                let response: SessionResponse = try await supabase
                    .rpc(
                        "start_parking_session",
                        params: [
                            "p_user_id": userId.uuidString,
                            "p_plate_number": vehicleModel.plateNumber,
                            "p_parking_spot_id": String(parkingSpotModel.parkingSpotID),
                            "p_time_interval": parkingCostModel.duration,
                            "p_estimated_cost": String(format: "%.2f", parkingCostModel.totalCost)
                        ]
                    )
                    .execute()
                    .value
                
                // Check the success property to handle the response accordingly
                if response.success {
                    print("Parking session started successfully:")
                    if let data = response.data {
                        print("Start Time: \(data.startTime)")
                        print("End Time: \(data.endTime)")
                        print("Duration: \(data.duration)")
                        print("Remaining Balance: \(data.remainingBalance)")
                        delegate?.didStartSession(response, parkingSpotModel, vehicleModel)
                    }
                } else {
                    print("Failed to start parking session:")
                    let error = response.message
                    print("Message: \(error)")
                    delegate?.failTostartSession(error)
                }

            } catch {
                print("Error occurred: \(error.localizedDescription)")
            }
        }
    }
}
