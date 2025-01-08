//
//  RegisterViewController.swift
//  ZipPark
//
//  Created by Wei Kang Tan on 20/12/2024.
//


import UIKit

class RegisterViewController: UIViewController {
    
    // MARK: - UI Components
    private let headerView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Create Account"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Enter your details to create an account"
        label.font = .systemFont(ofSize: 16)
        label.textColor = .white.withAlphaComponent(0.8)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let formContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowRadius = 5
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let usernameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Username"
        textField.backgroundColor = .systemGray6
        textField.layer.cornerRadius = 12
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Email"
        textField.backgroundColor = .systemGray6
        textField.layer.cornerRadius = 12
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.keyboardType = .emailAddress
        textField.autocapitalizationType = .none
        return textField
    }()
    
    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Password"
        textField.backgroundColor = .systemGray6
        textField.layer.cornerRadius = 12
        textField.isSecureTextEntry = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let confirmPasswordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Confirm Password"
        textField.backgroundColor = .systemGray6
        textField.layer.cornerRadius = 12
        textField.isSecureTextEntry = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Create Account", for: .normal)
        button.backgroundColor = .black
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    // MARK: - Properties
    private let authManager = AuthManager.shared
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupDelegates()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        authManager.delegate = self
        resetForm()
    }
    
    private func setupDelegates() {
        authManager.delegate = self
        [usernameTextField, emailTextField, passwordTextField, confirmPasswordTextField].forEach {
            $0?.delegate = self
        }
    }
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(headerView)
        headerView.addSubview(titleLabel)
        headerView.addSubview(subtitleLabel)
        
        view.addSubview(formContainerView)
        formContainerView.addSubview(usernameTextField)
        formContainerView.addSubview(emailTextField)
        formContainerView.addSubview(passwordTextField)
        formContainerView.addSubview(confirmPasswordTextField)
        
        view.addSubview(createButton)
        view.addSubview(activityIndicator)
        
        setupConstraints()
        setupTextFields()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Header
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 100),
            
            titleLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            
            // Form Container
            formContainerView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 20),
            formContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            formContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            // Form Fields
            usernameTextField.topAnchor.constraint(equalTo: formContainerView.topAnchor, constant: 20),
            usernameTextField.leadingAnchor.constraint(equalTo: formContainerView.leadingAnchor, constant: 16),
            usernameTextField.trailingAnchor.constraint(equalTo: formContainerView.trailingAnchor, constant: -16),
            usernameTextField.heightAnchor.constraint(equalToConstant: 50),
            
            emailTextField.topAnchor.constraint(equalTo: usernameTextField.bottomAnchor, constant: 16),
            emailTextField.leadingAnchor.constraint(equalTo: formContainerView.leadingAnchor, constant: 16),
            emailTextField.trailingAnchor.constraint(equalTo: formContainerView.trailingAnchor, constant: -16),
            emailTextField.heightAnchor.constraint(equalToConstant: 50),
            
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 16),
            passwordTextField.leadingAnchor.constraint(equalTo: formContainerView.leadingAnchor, constant: 16),
            passwordTextField.trailingAnchor.constraint(equalTo: formContainerView.trailingAnchor, constant: -16),
            passwordTextField.heightAnchor.constraint(equalToConstant: 50),
            
            confirmPasswordTextField.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 16),
            confirmPasswordTextField.leadingAnchor.constraint(equalTo: formContainerView.leadingAnchor, constant: 16),
            confirmPasswordTextField.trailingAnchor.constraint(equalTo: formContainerView.trailingAnchor, constant: -16),
            confirmPasswordTextField.heightAnchor.constraint(equalToConstant: 50),
            confirmPasswordTextField.bottomAnchor.constraint(equalTo: formContainerView.bottomAnchor, constant: -20),
            
            // Create Button
            createButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            createButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Activity Indicator
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupTextFields() {
        let textFields = [usernameTextField, emailTextField, passwordTextField, confirmPasswordTextField]
        
        textFields.forEach { textField in
            textField.delegate = self
            addPaddingToTextField(textField)
        }
        
        createButton.addTarget(self, action: #selector(createButtonPressed), for: .touchUpInside)
    }
    
    // MARK: - Helper Methods
    private func addPaddingToTextField(_ textField: UITextField) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always
    }
    
    private func resetForm() {
        resetTextFieldBorders()
        [usernameTextField, emailTextField, passwordTextField, confirmPasswordTextField].forEach {
            $0.text = ""
        }
    }
    
    private func resetTextFieldBorders() {
        [usernameTextField, emailTextField, passwordTextField, confirmPasswordTextField].forEach {
            $0.layer.borderWidth = 0
        }
    }
    
    // MARK: - Actions
    @objc private func createButtonPressed() {
        resetTextFieldBorders()
        
        if validate() {
            guard let email = emailTextField.text,
                  let password = passwordTextField.text,
                  let name = usernameTextField.text else { return }
            
            activityIndicator.startAnimating()
            authManager.signUp(email: email, password: password, name: name)
        }
    }
    
    // MARK: - Validation
    private func validate() -> Bool {
        let validations: [(UITextField, String)] = [
            (usernameTextField, "Username field cannot be empty"),
            (emailTextField, "Email field cannot be empty"),
            (passwordTextField, "Password field cannot be empty"),
            (confirmPasswordTextField, "Confirm password field cannot be empty")
        ]
        
        for (field, message) in validations {
            guard let text = field.text, !text.isEmpty else {
                showValidationError(message: message, field: field)
                return false
            }
        }
        
        guard let email = emailTextField.text, isValidEmail(email) else {
            showValidationError(message: "Email is not valid", field: emailTextField)
            return false
        }
        
        guard let password = passwordTextField.text, password.count >= 8 else {
            showValidationError(message: "Password must be at least 8 characters long", field: passwordTextField)
            return false
        }
        
        guard passwordTextField.text == confirmPasswordTextField.text else {
            showValidationError(message: "Passwords do not match", field: confirmPasswordTextField)
            return false
        }
        
        return true
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailTest.evaluate(with: email)
    }
    
    private func showValidationError(message: String, field: UITextField) {
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.systemRed.cgColor
        showAlert(message: message)
        activityIndicator.stopAnimating()
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension RegisterViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case usernameTextField:
            emailTextField.becomeFirstResponder()
        case emailTextField:
            passwordTextField.becomeFirstResponder()
        case passwordTextField:
            confirmPasswordTextField.becomeFirstResponder()
        default:
            textField.resignFirstResponder()
        }
        return true
    }
}

// MARK: - AuthManagerDelegate
extension RegisterViewController: AuthManagerDelegate {
    func didSignUpFail(_ error: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.showAlert(message: error)
            self.emailTextField.layer.borderWidth = 1
            self.emailTextField.layer.borderColor = UIColor.systemRed.cgColor
            self.activityIndicator.stopAnimating()
        }
    }
    
    func didSignUp() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            guard let email = self.emailTextField.text else { return }
            
            let otpVC = OTPViewController()
            otpVC.email = email
            otpVC.verifyType = .signup
            self.navigationController?.pushViewController(otpVC, animated: true)
            self.activityIndicator.stopAnimating()
        }
    }
}
