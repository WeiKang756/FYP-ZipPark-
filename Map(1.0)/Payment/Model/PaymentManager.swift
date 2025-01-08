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

class PaymentManager {
    
    static let shared = PaymentManager()
    private let supabase = SupabaseManager.shared.client
    var delegate: PaymentManagerDelegate?
    
    func createPaymentIntent(amount: Double) {
        Task {
            do {
                // Get user and validate
                let user = await SupabaseManager.shared.getUser()
                guard let user = user else {
                    print("Failed to get user information")
                    return
                }
                print("User:", user)
                
                // Get customer ID
                guard let customerId = user.userMetadata["stripeCustomerId"]?.stringValue else {
                    print("Failed to get user stripe customer ID")
                    return
                }
                print("Customer ID:", customerId)
                
                // Get wallet
                guard let wallet = await getWallet() else {
                    print("Failed to get wallet")
                    return
                }
                print("Wallet:", wallet)
                
                // Create payment intent request
                let paymentIntentRequest = PaymentIntentRequest(
                    amount: amount,
                    currency: "myr",
                    customerId: customerId,
                    walletId: wallet.id
                )
                
                // Make API call
                let response: PaymentIntentResponse = try await supabase.functions
                    .invoke(
                        "create-payment-intent",
                        options: FunctionInvokeOptions(
                            body: paymentIntentRequest
                        )
                    )
                
                // Create payment sheet request
                let paymentSheetRequest = PaymentSheetRequest(
                    clientSecret: response.clientSecret,
                    ephemeralKeySecret: response.ephemeralKeySecret,
                    customerId: customerId
                )
                
                // Notify delegate
                delegate?.paymentIntentDidCreate(paymentSheetRequest)
            } catch {
                print("Error creating payment intent:", error.localizedDescription)
            }
        }
    }
    
    func getWallet() async -> WalletData? {
        do {
            guard let user = await SupabaseManager.shared.getUser() else {
                print("Failed to get user object")
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
        } catch {
            print("Error getting wallet:", error.localizedDescription)
            return nil
        }
    }
    
    func fetchTransaction() {
        Task {
            do {
                guard let wallet = await getWallet() else {
                    print("Failed to get user wallet object")
                    return
                }
                
                let walletId = wallet.id
                let transactionData: [TransactionData] = try await supabase
                    .from("transactions")
                    .select("""
                      id,
                      wallet_id,
                      amount,
                      reference_id,
                      transaction_date,
                      transaction_types(name)
                    """)
                    .eq("wallet_id", value: walletId)
                    .order("transaction_date", ascending: false)
                    .execute()
                    .value
                
                var transactionModels: [TransactionModel] = []
                
                for transaction in transactionData {
                    guard let formattedDate = formatDateString(transaction.transactionDate) else {
                        continue
                    }
                    
                    let transactionModel = TransactionModel(
                        id: transaction.id,
                        amount: transaction.amount,
                        reference: transaction.referenceId,
                        date: formattedDate.date,
                        time: formattedDate.time,
                        type: transaction.transactionType.name
                    )
                    transactionModels.append(transactionModel)
                }
                
                if transactionModels.isEmpty {
                    print("No transactions found")
                } else {
                    delegate?.transactionDidFetch(transactionModels)
                }
            } catch {
                print("Error fetching transactions:", error.localizedDescription)
            }
        }
    }
    
    func formatDateString(_ dateString: String) -> (date: String, time: String)? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        guard let date = formatter.date(from: dateString) else {
            print("Failed to parse date string:", dateString)
            return nil
        }
        
        let displayFormatter = DateFormatter()
        displayFormatter.timeZone = TimeZone.current
        
        displayFormatter.dateStyle = .medium
        displayFormatter.timeStyle = .none
        let formattedDate = displayFormatter.string(from: date)
        
        displayFormatter.dateStyle = .none
        displayFormatter.timeStyle = .short
        let formattedTime = displayFormatter.string(from: date)
        
        return (date: formattedDate, time: formattedTime)
    }
}
