//
//  profileManager.swift
//  Map(1.0)
//
//  Created by Wei Kang Tan on 13/01/2025.
//
protocol ProfileManagerDelegate {
    func didGetUserName(_ userName: String)
    func didGetUserEmail(_ userEmail: String)
    func didGetWalletAmount(_ wallet: WalletData)
}
struct ProfileManager {
    let supabase = SupabaseManager.shared.client
    var delegate: ProfileManagerDelegate?
    
    func getUserName() {
        Task{
            let user = await SupabaseManager.shared.getUser()
            guard let user = user else {
                print("Failed to get user information")
                return
            }
            
            guard let userName = user.userMetadata["name"]?.stringValue else {
                print("Fail to get user data")
                return
            }
            
            delegate?.didGetUserName(userName)
        }
    }
    
    func getUserEmail() {
        Task{
            let user = await SupabaseManager.shared.getUser()
            guard let user = user else {
                print("Failed to get user information")
                return
            }
            
            guard let userEmail = user.userMetadata["email"]?.stringValue else {
                print("Fail to get user data")
                return
            }
            
            delegate?.didGetUserEmail(userEmail)
        }
    }
    
    func getWalletAmount() {
        Task{
            let paymentManager = PaymentManager()
            guard let walletData: WalletData = await paymentManager.getWallet() else{
                print("fail to get user data")
                return
            }
            delegate?.didGetWalletAmount(walletData)
        }
    }
}
