//
//  PaymentManager.swift
//  Map(1.0)
//
//  Created by Wei Kang Tan on 29/10/2024.
//

import Foundation
import Functions

protocol PaymentManagerDelegate {
    func paymentIntentDidCreate(_ paymentSheetRequest: PaymentSheetRequest)
}
class PaymentManager{
    
    static let shared = PaymentManager()
    private let supabase = SupabaseManager.shared.client
    var delegate: PaymentManagerDelegate?
    
    func createPaymentIntent(amount: Double, currency: String) {
        Task{
            do{
                let user = await SupabaseManager.shared.getUser()
                
                guard let user = user else {
                    print("Fail to get user information")
                    return
                }
                print(user)
                guard let customerId = user.userMetadata["stripeCustomerId"]?.stringValue else {
                    print("Fail to get user stripe customer Id")
                    return
                }
                print(customerId)
                
                let paymentIntentRequest = PaymentIntentRequest(amount: 1099, currency: "myr", customerId: customerId)
                
                let response: PaymentIntentResponse = try await supabase.functions
                    .invoke(
                        "create-payment-intent",
                        options: FunctionInvokeOptions(
                            body: paymentIntentRequest
                        )
                    )
                
                let paymentSheetRequest = PaymentSheetRequest(clientSecret: response.clientSecret, ephemeralKeySecret: response.ephemeralKeySecret, customerId: customerId)
                
                delegate?.paymentIntentDidCreate(paymentSheetRequest)
            }catch {
                print("error: \(error.localizedDescription)")
            }
        }
    }
}
