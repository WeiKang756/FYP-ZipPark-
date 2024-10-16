//
//  ParkingCostResponse.swift
//  Map(1.0)
//
//  Created by Wei Kang Tan on 19/11/2024.
//
import Foundation

struct ParkingCostResponse: Codable {
    let success: Bool
    let message: String
    let data: ParkingCostData?
}

struct ParkingCostData: Codable {
    let startTime: String
    let endTime: String
    let duration: String
    let totalCost: Double
    let costBreakdown: CostBreakdown
    let thresholdExceeded: Bool
    
    enum CodingKeys: String, CodingKey {
        case startTime = "start_time"
        case endTime = "end_time"
        case duration
        case totalCost = "total_cost"
        case costBreakdown = "cost_breakdown"
        case thresholdExceeded = "threshold_exceeded"
    }
}

struct CostBreakdown: Codable {
    let firstPeriodCost: Double  // Changed from String to Double
    let secondPeriodCost: Double // Changed from String to Double
    
    enum CodingKeys: String, CodingKey {
        case firstPeriodCost = "first_period_cost"
        case secondPeriodCost = "second_period_cost"
    }
}
