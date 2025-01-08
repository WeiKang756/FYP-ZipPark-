//
//  PaymentIntentResponse.swift
//  Map(1.0)
//
//  Created by Wei Kang Tan on 29/10/2024.
//


struct PaymentIntentResponse: Decodable {
    let clientSecret: String
    let ephemeralKeySecret: String
}

