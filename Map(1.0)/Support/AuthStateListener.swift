import Supabase
import UIKit

class AuthStateListener {
    private var streamTask: Task<Void, Never>?
    private let supabase: SupabaseClient

    init(supabase: SupabaseClient) {
        self.supabase = supabase
        startListening()
    }

    func startListening() {
        streamTask = Task {
            await monitorAuthState()
        }
    }

    private func monitorAuthState() async {
        for await (event, session) in supabase.auth.authStateChanges {
            switch event {
            case .passwordRecovery:
                // Handle password recovery first before any other events
                await handlePasswordRecovery(session)
                return // Exit the loop after handling password recovery
                
            case .signedIn:
                await handleSignIn(session)
                
            case .signedOut:
                await handleSignOut()
                
            case .tokenRefreshed:
                await handleTokenRefresh(session)
                
            case .userUpdated:
                await handleUserUpdate(session)
                
            case .initialSession:
                await handleInitialSession(session)
                
            case .userDeleted:
                print("User Deleted")
                
            case .mfaChallengeVerified:
                print("MFA Challenge Verified")
            }
        }
    }

    @MainActor
    private func handlePasswordRecovery(_ session: Session?) {
        print("Password Recovery Flow Started")
        setRootViewControllerToResetPassword()
    }

    @MainActor
    private func handleSignIn(_ session: Session?) {
        print("User just signed in:", session?.user.email ?? "unknown")
    }

    @MainActor
    private func handleSignOut() {
        print("User just signed out")
        setRootViewControllerToLogin()
    }

    @MainActor
    private func handleTokenRefresh(_ session: Session?) {
        print("Got new token:", session?.accessToken.prefix(10) ?? "none")
    }

    @MainActor
    private func handleUserUpdate(_ session: Session?) {
        print("User profile updated:", session?.user.email ?? "unknown")
        // Refresh UI with new user data if needed
    }

    @MainActor
    private func handleInitialSession(_ session: Session?) {
        if session != nil {
            print("User was already logged in")
            setRootViewControllerToHome()
        } else {
            print("No previous session found")
            setRootViewControllerToLogin()
        }
    }
    

    // Helper Method to Set Root View Controller to Home (TabBarController)
    @MainActor
    private func setRootViewControllerToResetPassword() {
        let resetPasswordVC = ResetPasswordViewController()
        let navigationController = UINavigationController(rootViewController: resetPasswordVC)

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return
        }

        window.rootViewController = navigationController
        window.makeKeyAndVisible()

        UIView.transition(with: window,
                         duration: 0.5,
                         options: [.transitionCrossDissolve],
                         animations: nil,
                         completion: nil)
    }
    
    @MainActor
    private func setRootViewControllerToHome() {
        // Create HomeViewController directly
        let homeVC = HomeViewController()
        let navigationController = UINavigationController(rootViewController: homeVC)
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return
        }

        window.rootViewController = navigationController
        window.makeKeyAndVisible()

        UIView.transition(with: window,
                         duration: 0.5,
                         options: [.transitionFlipFromRight],
                         animations: nil,
                         completion: nil)
    }

    // Helper Method to Set Root View Controller to Login (LoginViewController)
    @MainActor
    private func setRootViewControllerToLogin() {
        let storyboard = UIStoryboard(name: "Storyboard", bundle: nil)
        guard let loginViewController = storyboard.instantiateViewController(withIdentifier: "login") as? LoginViewController else {
            print("Could not instantiate LoginViewController")
            return
        }
        
        let navigationController = UINavigationController(rootViewController: loginViewController)

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return
        }

        window.rootViewController = navigationController
        window.makeKeyAndVisible()

        UIView.transition(with: window,
                          duration: 0.5,
                          options: [.transitionFlipFromLeft],
                          animations: nil,
                          completion: nil)
    }

    // Clean up when done
    func stopListening() {
        streamTask?.cancel()
        streamTask = nil
    }

    deinit {
        stopListening()
    }
}
