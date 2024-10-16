//
//  Transaction.swift
//  Map(1.0)
//
//  Created by Wei Kang Tan on 12/12/2024.
//
struct Transaction {
    let id: String
    let amount: Double
    let description: String
    let date: String
    let type: TransactionType
    
    enum TransactionType {
        case parking
        case topUp
    }
}
