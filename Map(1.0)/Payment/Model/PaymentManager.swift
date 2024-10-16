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
    func transactionDidFetch(_ transactionModels: [TransactionModel])
}

extension PaymentManagerDelegate {
    func paymentIntentDidCreate(_ paymentSheetRequest: PaymentSheetRequest) {
        print("Payment Intent Did Created (default)")
    }
    
    func transactionDidFetch(_ transactionModels: [TransactionModel]) {
        print("Transaction Did Fetch (default)")
    }
}

class PaymentManager{
    
    static let shared = PaymentManager()
    private let supabase = SupabaseManager.shared.client
    var delegate: PaymentManagerDelegate?
    
    func createPaymentIntent(amount: Double) {
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
                
                guard let wallet = await getWallet() else {
                    print("Fail to get user id")
                    return
                }
                print(wallet)
                
                let paymentIntentRequest = PaymentIntentRequest(amount: amount, currency: "myr", customerId: customerId, walletId: wallet.id)
                
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
    
    func getWallet() async -> WalletData? {
        do{
            guard let user = await SupabaseManager.shared.getUser() else {
                print("Fail to get user object")
                return nil
            }
            
            let uid = user.id
            let wallet: WalletData = try await supabase
                .from("Wallet")
                .select()
                .eq("uid", value: uid)
                .single()
                .execute()
                .value
            
            return wallet
        }catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    func fetchTransaction() {
        Task{
            do{
                guard let wallet = await getWallet() else {
                    print("Fail to get user wallet object")
                    return
                }
                let walletId = wallet.id
                let transactionData: [TransactionData] = try await supabase
                    .from("transactions")
                    .select(
                    """
                      id,
                      wallet_id,
                      amount,
                      reference_id,
                      transaction_date,
                      transaction_types(name)
                    """
                    )
                    .eq("wallet_id", value: walletId) // Add filter to find by wallet_id'
                    .order("transaction_date", ascending: false)
                    .execute()
                    .value
                
                var transactionModels: [TransactionModel] = []
                
                for transaction in transactionData {
                    let id = transaction.id
                    let amount = transaction.amount
                    let reference = transaction.referenceId
                    guard let formattedDateString = formatDateString(transaction.transactionDate) else {
                        return
                    }
                    let date = formattedDateString.date
                    let time = formattedDateString.time
                    let type = transaction.transactionType.name
                    let transactionModel = TransactionModel(id: id, amount: amount, reference: reference, date: date, time: time, type: type)
                    transactionModels.append(transactionModel)
                }
                
                if transactionModels.isEmpty {
                    print("Fail to get transaction model")
                }else {
                    delegate?.transactionDidFetch(transactionModels)
                }
            }catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func formatDateString(_ dateString: String) -> (date: String, time: String)? {
        // Define the date formatter for the input string
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        // Parse the date string
        guard let date = formatter.date(from: dateString) else {
            return nil
        }
        
        // Create a new date formatter for displaying the date and time
        let displayFormatter = DateFormatter()
        displayFormatter.timeZone = TimeZone.current
        
        // Format the date part
        displayFormatter.dateStyle = .medium
        displayFormatter.timeStyle = .none
        let formattedDate = displayFormatter.string(from: date)
        
        // Format the time part
        displayFormatter.dateStyle = .none
        displayFormatter.timeStyle = .short
        let formattedTime = displayFormatter.string(from: date)
        
        return (date: formattedDate, time: formattedTime)
    }
    
}
