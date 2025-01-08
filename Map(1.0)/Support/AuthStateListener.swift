import Supabase
import UIKit

class AuthStateListener {
    // MARK: - Properties
    private var streamTask: Task<Void, Never>?
    private let supabase: SupabaseClient
    private let transitionDuration: TimeInterval = 0.5
    
    private let loginTransitionOptions: UIView.AnimationOptions = .transitionFlipFromLeft
    private let homeTransitionOptions: UIView.AnimationOptions = .transitionFlipFromRight
    private let defaultTransitionOptions: UIView.AnimationOptions = .transitionCrossDissolve
    
    // MARK: - Initialization
    init(supabase: SupabaseClient) {
        self.supabase = supabase
        startListening()
    }
    
    // MARK: - Public Methods
    func startListening() {
        streamTask = Task {
            await monitorAuthState()
        }
    }
    
    func stopListening() {
        streamTask?.cancel()
        streamTask = nil
    }
    
    // MARK: - Private Methods
    private func monitorAuthState() async {
        do {
            for await (event, session) in supabase.auth.authStateChanges {
                do {
                    switch event {
                    case .passwordRecovery:
                        await handlePasswordRecovery(session)
                        return
                        
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
                        await handleSignOut()
                        
                    case .mfaChallengeVerified:
                        print("MFA Challenge Verified")
                    }
                } catch {
                    print("Error handling auth state change: \(error)")
                }
            }
        } catch {
            print("Error monitoring auth state: \(error)")
        }
    }
    
    // MARK: - Event Handlers
    @MainActor
    private func handlePasswordRecovery(_ session: Session?) {
        print("Password Recovery Flow Started")
        setRootViewController(ResetPasswordViewController(), transition: defaultTransitionOptions)
    }
    
    @MainActor
    private func handleSignIn(_ session: Session?) {
        print("User signed in: \(session?.user.email ?? "unknown")")
        setRootViewController(HomeViewController(), transition: homeTransitionOptions)
    }
    
    @MainActor
    private func handleSignOut() {
        print("User signed out")
        setRootViewControllerToLogin()
    }
    
    @MainActor
    private func handleTokenRefresh(_ session: Session?) {
        if let token = session?.accessToken {
            print("Token refreshed: \(String(token.prefix(10)))...")
        }
    }
    
    @MainActor
    private func handleUserUpdate(_ session: Session?) {
        print("User profile updated: \(session?.user.email ?? "unknown")")
    }
    
    @MainActor
    private func handleInitialSession(_ session: Session?) {
        if session != nil {
            print("Existing session found")
            setRootViewController(HomeViewController(), transition: homeTransitionOptions)
        } else {
            print("No existing session")
            setRootViewControllerToLogin()
        }
    }
    
    // MARK: - Navigation Helpers
    @MainActor
    private func getKeyWindow() -> UIWindow? {
        return UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .first(where: { $0 is UIWindowScene })
            .flatMap({ $0 as? UIWindowScene })?.windows
            .first(where: \.isKeyWindow)
    }
    
    @MainActor
    private func setRootViewController(_ viewController: UIViewController,
                                     transition: UIView.AnimationOptions) {
        guard let window = getKeyWindow() else {
            print("Error: No key window found")
            return
        }
        
        let navigationController = UINavigationController(rootViewController: viewController)
        
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        
        UIView.transition(with: window,
                         duration: transitionDuration,
                         options: transition,
                         animations: nil) { [weak self] _ in
            // Handle completion if needed
        }
    }
    
    @MainActor
    private func setRootViewControllerToLogin() {
        let loginViewController: LoginViewController
        loginViewController = LoginViewController()
        setRootViewController(loginViewController, transition: loginTransitionOptions)
    }
    
    // MARK: - Cleanup
    deinit {
        stopListening()
    }
}
