//
//  TransactionData.swift
//  Map(1.0)
//
//  Created by Wei Kang Tan on 04/11/2024.
//

import Foundation

struct TransactionData: Decodable {
    let id: String
    let walletId: String // Changed to camelCase
    let amount: Double
    let referenceId: String // Changed to camelCase
    let transactionDate: String // Changed to camelCase
    let transactionType: TransactionType // Changed to camelCase

    enum CodingKeys: String, CodingKey {
        case id
        case walletId = "wallet_id"
        case amount
        case referenceId = "reference_id"
        case transactionDate = "transaction_date"
        case transactionType = "transaction_types"
    }
}

struct TransactionType: Decodable {
    let name: String
}
