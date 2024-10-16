//
//  AuthManager.swift
//  Map(1.0)
//
//  Created by Wei Kang Tan on 09/10/2024.
//

import Foundation
import Auth
import Functions

protocol AuthManagerDelegate: AnyObject {
    func didVerifyOTP(verificationResult: Bool, result: String)
    func didResendOTP()
    func didSignUp()
    func didSignUpFail(_ error: String)
    func didSignInWithOTP()
    func didSignInWithOTPFail(_ error: String)
    func didSignIn()
    func didSignInFail(_ error: String)
    func didResetPassword()
    func didResetPasswordFail(_ error: String)
    func didUpdatePassword()
    func didUpdatePasswordFail(_ error: String)
}

extension AuthManagerDelegate {
    
    func didVerifyOTP(verificationResult: Bool, result: String){
        print("did verify OTP")
    }
    
    func didResendOTP(){
        print("did Resend OTP")
    }
    
    func didSignUp(){
        print("did Sign Up")
    }
    
    func didSignUpFail(_ error: String){
        print("Sign Up Fail")
    }
    
    func didSignIn(){
        print("did Sign In")
    }
    func didSignInFail(_ error: String){
        print("Sign In Fail")
    }
    
    func didSignInWithOTP(){
        print("did Sign In With OTP")
    }
    
    func didSignInWithOTPFail(_ error: String){
        print("failed to Sign In With OTP")
    }
    
    func didResetPassword(){
        print("did Reset Password")
        
    }
    
    func didResetPasswordFail(_ error: String){
        print("failed to Reset Password")
    }
    
    func didUpdatePassword(){
        print("did update Password")
    }
    
    func didUpdatePasswordFail(_ error: String){
        print("update password fali")
    }
}
enum VerifyType {
    case signup
    case magiclink
    case recovery
}

class AuthManager{
    
    
    static let shared = AuthManager()
    private let supabase = SupabaseManager.shared.client
    var delegate: AuthManagerDelegate?
    var verificationResult: Bool?
    var resultString: String?
    var emailStatus: EmailStatus? = nil
    var name: String? = nil
    
    
    func signUp(email: String, password: String, name: String) {
        Task {
            do {
                // Attempt to sign up the user
                let isEmailValid = await isEmailValid(email: email)
                
                if isEmailValid {
                    
                    let response = try await supabase.auth.signUp(email: email, password: password)
                    let user = response.user
                    self.name = name
                    print("\(user)")
                    delegate?.didSignUp()
                }else {
                    let error = "Email already in use"
                    delegate?.didSignUpFail(error)
                }
            } catch {
                // Handle specific errors, such as the user already being registered
                let errorMessage = error.localizedDescription
                print("Error: \(errorMessage)")
                delegate?.didSignUpFail(errorMessage)
            }
        }
    }
    
    func createStripeCustomer(email: String, name: String) async -> String?{
        // Create request payload
        let requestBody = ["email": email, "name": name]

        do {
            // Invoke the Supabase Edge Function
            let response: CreateStripeCustomerResponse = try await supabase.functions.invoke(
                "create-stripe-customer",
                options: FunctionInvokeOptions(
                    body: requestBody
                )
            )

            print("Stripe customer created with ID: \(response.customerId)")
            let customerId = response.customerId
            
            return customerId
            // Handle customerId as needed (e.g., save it to your database)
        } catch {
            print("Failed to create Stripe customer: \(error.localizedDescription)")
            return nil
        }
    }
    
    func createWallet(createWalletRequest: CreateWalletRequest) {
        Task{
            do{
                let userID = createWalletRequest.uid
                try await supabase
                    .from("Wallet")
                    .insert(createWalletRequest)
                    .execute()
            }catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func fetchEmailStatus(email: String) async throws -> EmailStatus? {
        do{
            let emailStatus: EmailStatus = try await supabase
                .rpc("check_email_status", params: ["check_email": email])
                .execute()
                .value
            
            return emailStatus
        } catch {
            // Handle specific errors, such as the user already being registered
            print("Fail to fetch email Status")
            throw error
        }
    }
    
    func signIn(email: String, password: String){
        Task{
            do{
                try await supabase.auth.signIn(email: email, password: password)
                delegate?.didSignIn()
                
                _ = try await supabase.auth.session
            }catch {
                let error = error.localizedDescription
                delegate?.didSignInFail(error)
                print(error)
            }
        }
    }
    
    func signInWithOTP(email: String) {
        Task{
            do{
                if await isEmailValid(email: email) {
                    delegate?.didSignInWithOTPFail("Email not exist, please do register")
                    return
                }
                
                try await supabase.auth.signInWithOTP(email: email, shouldCreateUser: false)
                delegate?.didSignInWithOTP()
            }catch{
                print(error.localizedDescription)
                delegate?.didSignInWithOTPFail(error.localizedDescription)
            }
        }
    }
    
    func isEmailValid(email: String) async -> Bool{
        do{
            guard let emailStatus = try await fetchEmailStatus(email: email) else {
                return false
            }
            let isEmailExist = emailStatus.exists
            let isEmailConfirmed = emailStatus.isVerified
            
            if isEmailExist, isEmailConfirmed {
                print("Email have been exsit and is confirmed. Email have been registered")
                return false
            }else if isEmailExist, !isEmailConfirmed {
                print("Email have been exsit but not confirmed. Send OTP")
                return true
            }else{
                print("Email not exist. Register the email")
                return true
            }
        }catch {
            print(error.localizedDescription)
            return false
        }
    }
    
    func resetPassword(email: String) {
        Task{
            do{
                if await isEmailValid(email: email) {
                    delegate?.didResetPasswordFail("Email not exist, please do register")
                    return
                }
                
                try await supabase.auth.resetPasswordForEmail(email)
                delegate?.didResetPassword()
            }catch {
                print(error.localizedDescription)
                print("Fail to send email")
                delegate?.didResetPasswordFail(error.localizedDescription)
            }
        }
    }
    
    func signOut() {
        Task{
            do{
                try await supabase.auth.signOut()
            }catch{
                print(error.localizedDescription)
            }
        }
    }
    
    func updatePassword(newPassword: String) {
        Task {
            do{
                try await supabase.auth.update(
                    user: UserAttributes(password: newPassword)
                )
                
                try await supabase.auth.update(
                    user: UserAttributes(
                        data: [
                          "hello": .string("world")
                        ]
                    )
                )
                
                delegate?.didUpdatePassword()
            }catch {
                let error = error.localizedDescription
                print(error)
                delegate?.didUpdatePasswordFail(error)
            }
        }
    }
    
    
    func verifyOTP(email: String, otp: String, verifyType: VerifyType) {
        Task{
            switch verifyType {
            case .signup:
                do{
                    print("I am from sign up")
                    
                    try await supabase.auth.verifyOTP(
                        email: email,
                        token: otp,
                        type: .signup
                    )
                    verificationResult = true
                    resultString = "Sucessful Verify"
                    
                    if verificationResult ?? false {
                        guard let name = name else {
                            let error = "Fail to get name"
                            delegate?.didSignUpFail(error)
                            return}
                        
                        guard let customerId = await createStripeCustomer(email: email, name: name) else {
                            let error = "Fail to create user Stripe Account"
                            print(error)
                            delegate?.didSignUpFail(error)
                            return
                        }
                        
                        try await supabase.auth.update(
                            user: UserAttributes(
                                data: [
                                    "name": .string(name),
                                    "stripeCustomerId": .string(customerId)
                                ]
                            )
                        )
                        
                        guard let user = await SupabaseManager.shared.getUser() else {
                            print("Fail to get user information")
                            return
                        }
                        
                        let uid = user.id
                        let userID = CreateWalletRequest(uid: uid)
                        createWallet(createWalletRequest: userID)
                    }
                    
                    delegate?.didVerifyOTP(verificationResult: verificationResult!, result: resultString!)
                    print("Sign Up")
                    print("OTP verified successfully!")
                    try await supabase.auth.signOut()
                    print("Successfully Sign Out!")
                }catch{
                    verificationResult = false
                    resultString = "\(error.localizedDescription)"
                    delegate?.didVerifyOTP(verificationResult: verificationResult!, result: resultString!)
                    print("\(error.localizedDescription)")
                }
            case .magiclink:
                do{
                    print("I am from log in")
                    try await supabase.auth.verifyOTP(
                        email: email,
                        token: otp,
                        type: .magiclink
                    )
                    
                    verificationResult = true
                    resultString = "Sucessful Verify"
                    delegate?.didVerifyOTP(verificationResult: verificationResult!, result: resultString!)
                    print("Magic Link")
                    print("OTP verified successfully!")
                }catch{
                    verificationResult = false
                    resultString = "\(error.localizedDescription)"
                    delegate?.didVerifyOTP(verificationResult: verificationResult!, result: resultString!)
                    print("\(error.localizedDescription)")
                }
            case .recovery:
                do{
                    print("I am from recovey")
                    print(email)
                    try await supabase.auth.verifyOTP(
                        email: email,
                        token: otp,
                        type: .recovery
                    )
                    verificationResult = true
                    resultString = "Sucessful Verify"
                    delegate?.didVerifyOTP(verificationResult: verificationResult!, result: resultString!)
                    print("Recovery")
                    print("OTP verified successfully!")
                }catch{
                    verificationResult = false
                    resultString = "\(error.localizedDescription)"
                    delegate?.didVerifyOTP(verificationResult: verificationResult!, result: resultString!)
                    print("\(error.localizedDescription)")
                    print("error twiced")
                }
            }
        }
    }
    
    
    func resendOTP(email: String, verifyType: VerifyType) {
        Task{
            switch verifyType{
                
            case .signup:
                do{
                    try await supabase.auth.resend(
                        email: email,
                        type: .signup
                    )
                    delegate?.didResendOTP()
                }catch {
                    print ("\(error.localizedDescription)")
                }
                
            case .magiclink:
                do{
                    try await supabase.auth.signInWithOTP(email: email)
                    delegate?.didResendOTP()
                }catch {
                    print ("\(error.localizedDescription)")
                }
                
            case .recovery:
                do{
                    try await supabase.auth.resetPasswordForEmail(email)
                    delegate?.didResendOTP()
                }catch {
                    print ("\(error.localizedDescription)")
                }
            }
        }
    }
    
}
