import UIKit

class SignInViewController: UIViewController {
    
    private let logoImageView = UIImageView()
    private let usernameTextField = UITextField()
    private let passwordTextField = UITextField()
    private let loginButton = UIButton(type: .system)
    private let forgotPasswordButton = UIButton(type: .system)
    private let createAccountButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        // Logo
        logoImageView.image = UIImage(named: "App")
        logoImageView.contentMode = .scaleAspectFit
        
        // Username TextField
        usernameTextField.placeholder = "Username"
        usernameTextField.borderStyle = .roundedRect
        usernameTextField.backgroundColor = UIColor(white: 0.95, alpha: 1)
        
        // Password TextField
        passwordTextField.placeholder = "Password"
        passwordTextField.borderStyle = .roundedRect
        passwordTextField.backgroundColor = UIColor(white: 0.95, alpha: 1)
        passwordTextField.isSecureTextEntry = true
        
        // Login Button
        loginButton.setTitle("Log in", for: .normal)
        loginButton.backgroundColor = .black
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.layer.cornerRadius = 5
        
        // Forgot Password Button
        forgotPasswordButton.setTitle("Forgotten Password?", for: .normal)
        forgotPasswordButton.setTitleColor(.gray, for: .normal)
        
        // Create Account Button
        createAccountButton.setTitle("Create New Account", for: .normal)
        createAccountButton.setTitleColor(.black, for: .normal)
        createAccountButton.layer.borderColor = UIColor.black.cgColor
        createAccountButton.layer.borderWidth = 1
        createAccountButton.layer.cornerRadius = 5
        
        // Add subviews
        [logoImageView, usernameTextField, passwordTextField, loginButton, forgotPasswordButton, createAccountButton].forEach { view.addSubview($0) }
        
        // Enable auto layout
        [logoImageView, usernameTextField, passwordTextField, loginButton, forgotPasswordButton, createAccountButton].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
        // Set up constraints
        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
            logoImageView.widthAnchor.constraint(equalToConstant: 100),
            logoImageView.heightAnchor.constraint(equalToConstant: 100),
            
            usernameTextField.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 40),
            usernameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            usernameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            usernameTextField.heightAnchor.constraint(equalToConstant: 44),
            
            passwordTextField.topAnchor.constraint(equalTo: usernameTextField.bottomAnchor, constant: 16),
            passwordTextField.leadingAnchor.constraint(equalTo: usernameTextField.leadingAnchor),
            passwordTextField.trailingAnchor.constraint(equalTo: usernameTextField.trailingAnchor),
            passwordTextField.heightAnchor.constraint(equalToConstant: 44),
            
            loginButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 20),
            loginButton.leadingAnchor.constraint(equalTo: usernameTextField.leadingAnchor),
            loginButton.trailingAnchor.constraint(equalTo: usernameTextField.trailingAnchor),
            loginButton.heightAnchor.constraint(equalToConstant: 44),
            
            forgotPasswordButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 16),
            forgotPasswordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            createAccountButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            createAccountButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            createAccountButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7),
            createAccountButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
}

#Preview {
    SignInViewController()
}
