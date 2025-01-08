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
    func didVerifyOTP(verificationResult: Bool, result: String) {
        print("did verify OTP")
    }
    
    func didResendOTP() {
        print("did Resend OTP")
    }
    
    func didSignUp() {
        print("did Sign Up")
    }
    
    func didSignUpFail(_ error: String) {
        print("Sign Up Fail")
    }
    
    func didSignIn() {
        print("did Sign In")
    }
    
    func didSignInFail(_ error: String) {
        print("Sign In Fail")
    }
    
    func didSignInWithOTP() {
        print("did Sign In With OTP")
    }
    
    func didSignInWithOTPFail(_ error: String) {
        print("failed to Sign In With OTP")
    }
    
    func didResetPassword() {
        print("did Reset Password")
    }
    
    func didResetPasswordFail(_ error: String) {
        print("failed to Reset Password")
    }
    
    func didUpdatePassword() {
        print("did update Password")
    }
    
    func didUpdatePasswordFail(_ error: String) {
        print("update password fail")
    }
}

enum VerifyType {
    case signup
    case magiclink
    case recovery
}

class AuthManager {
    // MARK: - Properties
    static let shared = AuthManager()
    private let supabase = SupabaseManager.shared.client
    weak var delegate: AuthManagerDelegate?
    var verificationResult: Bool?
    var resultString: String?
    var emailStatus: EmailStatus?
    var name: String?
    
    // MARK: - Authentication Methods
    func signUp(email: String, password: String, name: String) {
        Task {
            do {
                let isEmailValid = await isEmailValid(email: email)
                
                if isEmailValid {
                    let response = try await supabase.auth.signUp(email: email, password: password)
                    let user = response.user
                    self.name = name
                    print("\(user)")
                    delegate?.didSignUp()
                } else {
                    delegate?.didSignUpFail("Email already in use")
                }
            } catch {
                delegate?.didSignUpFail(error.localizedDescription)
            }
        }
    }
    
    func signIn(email: String, password: String) {
        Task {
            do {
                try await supabase.auth.signIn(email: email, password: password)
                _ = try await supabase.auth.session
                delegate?.didSignIn()
            } catch {
                delegate?.didSignInFail(error.localizedDescription)
            }
        }
    }
    
    func signInWithOTP(email: String) {
        Task {
            do {
                if await isEmailValid(email: email) {
                    delegate?.didSignInWithOTPFail("Email not exist, please do register")
                    return
                }
                
                try await supabase.auth.signInWithOTP(email: email, shouldCreateUser: false)
                delegate?.didSignInWithOTP()
            } catch {
                delegate?.didSignInWithOTPFail(error.localizedDescription)
            }
        }
    }
    
    func signOut() {
        Task {
            do {
                try await supabase.auth.signOut()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    // MARK: - Password Management
    func resetPassword(email: String) {
        Task {
            do {
                if await isEmailValid(email: email) {
                    delegate?.didResetPasswordFail("Email not exist, please do register")
                    return
                }
                
                try await supabase.auth.resetPasswordForEmail(email)
                delegate?.didResetPassword()
            } catch {
                delegate?.didResetPasswordFail(error.localizedDescription)
            }
        }
    }
    
    func updatePassword(newPassword: String) {
        Task {
            do {
                try await supabase.auth.update(user: UserAttributes(password: newPassword))
                try await supabase.auth.update(user: UserAttributes(data: ["hello": .string("world")]))
                delegate?.didUpdatePassword()
            } catch {
                delegate?.didUpdatePasswordFail(error.localizedDescription)
            }
        }
    }
    
    // MARK: - Email Validation
    func fetchEmailStatus(email: String) async throws -> EmailStatus? {
        do {
            return try await supabase
                .rpc("check_email_status", params: ["check_email": email])
                .execute()
                .value
        } catch {
            print("Fail to fetch email Status")
            throw error
        }
    }
    
    func isEmailValid(email: String) async -> Bool {
        do {
            guard let emailStatus = try await fetchEmailStatus(email: email) else {
                return false
            }
            let isEmailExist = emailStatus.exists
            let isEmailConfirmed = emailStatus.isVerified
            
            if isEmailExist && isEmailConfirmed {
                return false // Email exists and is confirmed
            } else if isEmailExist && !isEmailConfirmed {
                return true // Email exists but not confirmed
            } else {
                return true // Email doesn't exist
            }
        } catch {
            return false
        }
    }
    
    // MARK: - Stripe Integration
    func createStripeCustomer(email: String, name: String) async -> String? {
        
        let requestBody = ["email": email, "name": name]
        
        do {
            let response: CreateStripeCustomerResponse = try await supabase.functions.invoke(
                "create-stripe-customer",
                options: FunctionInvokeOptions(body: requestBody)
            )
            return response.customerId
        } catch {
            print("Failed to create Stripe customer: \(error.localizedDescription)")
            return nil
        }
    }
    
    func createWallet(createWalletRequest: CreateWalletRequest) {
        Task {
            do {
                try await supabase
                    .from("Wallet")
                    .insert(createWalletRequest)
                    .execute()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    // MARK: - OTP Management
    func verifyOTP(email: String, otp: String, verifyType: VerifyType) {
        Task {
            switch verifyType {
            case .signup:
                await handleSignupVerification(email: email, otp: otp)
            case .magiclink:
                await handleMagiclinkVerification(email: email, otp: otp)
            case .recovery:
                await handleRecoveryVerification(email: email, otp: otp)
            }
        }
    }

    // Handler functions implementations
    private func handleSignupVerification(email: String, otp: String) async {
        do {
            let response = try await supabase.auth.verifyOTP(
                email: email,
                token: otp,
                type: .signup
            )
            // Handle successful verification
            // You may want to notify a delegate or post a notification
        } catch {
            // Handle verification error
            print("Signup verification error: \(error.localizedDescription)")
        }
    }

    private func handleMagiclinkVerification(email: String, otp: String) async {
        do {
            let response = try await supabase.auth.verifyOTP(
                email: email,
                token: otp,
                type: .magiclink
            )
            // Handle successful verification
        } catch {
            // Handle verification error
            print("Magiclink verification error: \(error.localizedDescription)")
        }
    }

    private func handleRecoveryVerification(email: String, otp: String) async {
        do {
            let response = try await supabase.auth.verifyOTP(
                email: email,
                token: otp,
                type: .recovery
            )
            // Handle successful verification
        } catch {
            // Handle verification error
            print("Recovery verification error: \(error.localizedDescription)")
        }
    }
    
    func resendOTP(email: String, verifyType: VerifyType) {
        Task {
            do {
                switch verifyType {
                case .signup:
                    try await supabase.auth.resend(email: email, type: .signup)
                case .magiclink:
                    try await supabase.auth.signInWithOTP(email: email)
                case .recovery:
                    try await supabase.auth.resetPasswordForEmail(email)
                }
                delegate?.didResendOTP()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
