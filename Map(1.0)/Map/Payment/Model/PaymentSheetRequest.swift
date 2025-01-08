//
//  Untitled.swift
//  Map(1.0)
//
//  Created by Wei Kang Tan on 30/10/2024.
//

struct PaymentSheetRequest: Encodable {
    let clientSecret: String
    let ephemeralKeySecret: String
    let customerId: String
}
