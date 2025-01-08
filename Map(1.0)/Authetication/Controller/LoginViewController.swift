import UIKit

class LoginViewController: UIViewController {
    
    // MARK: - UI Components
    private let headerView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Welcome to ZipPark"
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let welcomeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "white_logo")
        imageView.tintColor = .white
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Sign in to continue"
        label.font = .systemFont(ofSize: 16)
        label.textColor = .white.withAlphaComponent(0.8)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Email"
        textField.borderStyle = .none
        textField.layer.cornerRadius = 12
        textField.backgroundColor = .systemGray6
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Password"
        textField.borderStyle = .none
        textField.layer.cornerRadius = 12
        textField.backgroundColor = .systemGray6
        textField.isSecureTextEntry = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Log In", for: .normal)
        button.backgroundColor = .black
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let forgotPasswordButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Forgot Password?", for: .normal)
        button.setTitleColor(.systemGray, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let createAccountButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Don't have an account? Sign Up", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let errorLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemRed
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Properties
    let supabase = SupabaseManager.shared
    let authManager = AuthManager.shared
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        setupDelegates()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        authManager.delegate = self
        resetToDefault()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        setupHeaderView()
        setupTextFields()
        setupButtons()
    }
    
    private func setupHeaderView() {
        view.addSubview(headerView)
        headerView.addSubview(welcomeImageView)
        headerView.addSubview(titleLabel)
        headerView.addSubview(subtitleLabel)
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 240), // Increased height to accommodate image
            
            welcomeImageView.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 80),
            welcomeImageView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            welcomeImageView.widthAnchor.constraint(equalToConstant: 80),
            welcomeImageView.heightAnchor.constraint(equalToConstant: 80),
            
            titleLabel.bottomAnchor.constraint(equalTo: subtitleLabel.topAnchor, constant: -8),
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            
            subtitleLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -20),
            subtitleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20)
        ])
    }
    
    private func setupTextFields() {
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(errorLabel)
        
        setupTextField(emailTextField, withIcon: "envelope")
        setupTextField(passwordTextField, withIcon: "lock")
        
        NSLayoutConstraint.activate([
            emailTextField.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 40),
            emailTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            emailTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            emailTextField.heightAnchor.constraint(equalToConstant: 50),
            
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 16),
            passwordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            passwordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            passwordTextField.heightAnchor.constraint(equalToConstant: 50),
            
            errorLabel.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 8),
            errorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            errorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func setupTextField(_ textField: UITextField, withIcon iconName: String) {
        let iconView = UIImageView(image: UIImage(systemName: iconName))
        iconView.tintColor = .systemGray
        iconView.contentMode = .scaleAspectFit
        
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 55, height: 40))
        iconView.frame = CGRect(x: 15, y: 10, width: 20, height: 20)
        containerView.addSubview(iconView)
        
        textField.leftView = containerView
        textField.leftViewMode = .always
    }
    
    private func setupButtons() {
        view.addSubview(loginButton)
        view.addSubview(forgotPasswordButton)
        view.addSubview(createAccountButton)
        
        NSLayoutConstraint.activate([
            loginButton.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 24),
            loginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            loginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            loginButton.heightAnchor.constraint(equalToConstant: 50),
            
            forgotPasswordButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 16),
            forgotPasswordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            createAccountButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            createAccountButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func setupActions() {
        loginButton.addTarget(self, action: #selector(loginButtonPressed), for: .touchUpInside)
        forgotPasswordButton.addTarget(self, action: #selector(forgotPasswordButtonPressed), for: .touchUpInside)
        createAccountButton.addTarget(self, action: #selector(createAccountButtonPressed), for: .touchUpInside)
    }
    
    private func setupDelegates() {
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    // MARK: - Helper Methods
    private func resetToDefault() {
        errorLabel.isHidden = true
        emailTextField.backgroundColor = .systemGray6
        passwordTextField.backgroundColor = .systemGray6
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @MainActor
    private func setRootViewControllerToHome() {
        let vcController = HomeViewController()
        let navigationController = UINavigationController(rootViewController: vcController)
        
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
    
    // MARK: - Actions
    @objc private func loginButtonPressed() {
        guard let email = emailTextField.text, !email.isEmpty else {
            showAlert(message: "Please enter your email")
            return
        }
        
        guard let password = passwordTextField.text, !password.isEmpty else {
            showAlert(message: "Please enter your password")
            return
        }
        
        resetToDefault()
        authManager.signIn(email: email, password: password)
    }
    
    @objc private func forgotPasswordButtonPressed() {
        let floatingVC = FloatingViewController()
        floatingVC.modalPresentationStyle = .overFullScreen
        floatingVC.modalTransitionStyle = .crossDissolve
        floatingVC.delegate = self
        present(floatingVC, animated: true)
    }
    
    @objc private func createAccountButtonPressed() {
        let vc = RegisterViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - FloatingViewControllerDelegate
extension LoginViewController: FloatingViewControllerDelegate {
    func didPressSignInWithOTPButton() {
        let vc = EnterEmailViewController()
        vc.type = .signInWithOTP
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func didPressResetPasswordButton() {
        let vc = EnterEmailViewController()
        vc.type = .resetPassword
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            loginButtonPressed()
        }
        return true
    }
}

// MARK: - AuthManagerDelegate
extension LoginViewController: AuthManagerDelegate {
    func didSignIn() {
        DispatchQueue.main.async {
            self.setRootViewControllerToHome()
        }
    }
    
    func didSignInFail(_ error: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.emailTextField.backgroundColor = .systemRed.withAlphaComponent(0.1)
            self.passwordTextField.backgroundColor = .systemRed.withAlphaComponent(0.1)
            self.errorLabel.isHidden = false
            self.errorLabel.text = error
            self.showAlert(message: error)
        }
    }
}
