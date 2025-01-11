//
//  SessionExtensionManagerDelegate.swift
//  Map(1.0)
//
//  Created by Wei Kang Tan on 09/01/2025.
//

import Foundation

enum SessionExtensionError: Error {
    case expired
    case inactive
    case insufficientBalance
    case unknown(String)
    
    var message: String {
        switch self {
        case .expired:
            return "Cannot extend an expired session"
        case .inactive:
            return "Cannot extend an inactive session"
        case .insufficientBalance:
            return "Insufficient wallet balance"
        case .unknown(let message):
            return message
        }
    }
}

class SessionExtensionManager {
    let supabase = SupabaseManager.shared.client
    weak var delegate: SessionExtensionManagerDelegate?
    
    func extendSession(sessionId: UUID, additionalTime: String, estimatedCost: Double) {
        Task {
            do {
                let response: SessionExtensionResponse = try await supabase
                    .rpc(
                        "extend_parking_session",
                        params: [
                            "p_session_id": sessionId.uuidString,
                            "p_additional_time": additionalTime,
                            "p_estimated_cost": String(format: "%.2f", estimatedCost)
                        ]
                    )
                    .execute()
                    .value
                
                if response.success {
                    delegate?.didExtendSession(response)
                } else {
                    let error: SessionExtensionError
                    switch response.message {
                    case "Cannot extend an expired session":
                        error = .expired
                    case "Cannot extend an inactive session":
                        error = .inactive
                    case _ where response.message.contains("Insufficient balance"):
                        error = .insufficientBalance
                    default:
                        error = .unknown(response.message)
                    }
                    delegate?.failedToExtendSession(error)
                    print(error)
                }
            } catch {
                print("error: \(error.localizedDescription)")
                delegate?.failedToExtendSession(.unknown(error.localizedDescription))
            }
        }
    }
}

protocol SessionExtensionManagerDelegate: AnyObject {
    func didExtendSession(_ response: SessionExtensionResponse)
    func failedToExtendSession(_ error: SessionExtensionError)
}

struct SessionExtensionResponse: Decodable {
    let success: Bool
    let message: String
    let data: ExtensionData?
}

struct ExtensionData: Decodable {
    let newEndTime: String
    let additionalCost: Double
    let remainingBalance: Double
    
    enum CodingKeys: String, CodingKey {
        case newEndTime = "new_end_time"
        case additionalCost = "additional_cost"
        case remainingBalance = "remaining_balance"
    }
}
