//
//  PaymentIntentRequest.swift
//  Map(1.0)
//
//  Created by Wei Kang Tan on 29/10/2024.
//
import Foundation

struct PaymentIntentRequest: Encodable {
    let amount: Double
    let currency: String
    let customerId: String
    let walletId: UUID
}
