//
//  RegisterViewController.swift
//  Map(1.0)
//
//  Created by Wei Kang Tan on 09/10/2024.
//

import UIKit

class RegisterViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    let authManager = AuthManager.shared
    var activityIndicator: UIActivityIndicatorView = {
            let indicator = UIActivityIndicatorView(style: .large)
            indicator.translatesAutoresizingMaskIntoConstraints = false
            indicator.hidesWhenStopped = true // Automatically hide when stopped
            return indicator
        }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        authManager.delegate = self
        usernameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self
        passwordTextField.isSecureTextEntry = true
        confirmPasswordTextField.isSecureTextEntry = true

        
        view.addSubview(activityIndicator)
        
        // Center the activity indicator in the view
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        addPaddingToTextField(usernameTextField)
        addPaddingToTextField(emailTextField)
        addPaddingToTextField(passwordTextField)
        addPaddingToTextField(confirmPasswordTextField)
        
        usernameTextField.layer.cornerRadius = 12.0
        usernameTextField.layer.borderWidth = 1.0
        usernameTextField.layer.borderColor = UIColor.systemGray.cgColor
        
        emailTextField.layer.cornerRadius = 12.0
        emailTextField.layer.borderWidth = 1.0
        emailTextField.layer.borderColor = UIColor.systemGray.cgColor
        
        passwordTextField.layer.cornerRadius = 12.0
        passwordTextField.layer.borderWidth = 1.0
        passwordTextField.layer.borderColor = UIColor.systemGray.cgColor
        
        confirmPasswordTextField.layer.cornerRadius = 12.0
        confirmPasswordTextField.layer.borderWidth = 1.0
        confirmPasswordTextField.layer.borderColor = UIColor.systemGray.cgColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Perform your actions here, e.g., reset form fields or update UI
        print("User has returned to RegisterViewController")
        authManager.delegate = self
    }
    
    func addPaddingToTextField(_ textField: UITextField) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always // Ensure padding is always shown
    }
    
    @IBAction func createButtonPressed(_ sender: Any) {
        resetTextFieldBorders()
        
        if validate() {
            let email = emailTextField.text!
            let password = passwordTextField.text!
            let name = usernameTextField.text!
            
            authManager.signUp(email: email, password: password, name: name)
        }
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailTest.evaluate(with: email)
    }
    
    func validate() -> Bool {
        activityIndicator.startAnimating()
        
        guard let userName = usernameTextField.text, !userName.isEmpty else {
            showAlert(message: "Username field cannot be empty")
            self.activityIndicator.stopAnimating()
            usernameTextField.layer.borderColor = UIColor.systemRed.cgColor
            return false
        }
        
        guard let email = emailTextField.text, !email.isEmpty else {
            showAlert(message: "Email field cannot be empty")
            self.activityIndicator.stopAnimating()
            emailTextField.layer.borderColor = UIColor.systemRed.cgColor
            return false
        }
        
        if !isValidEmail(email) {
            showAlert(message: "Email is not valid")
            self.activityIndicator.stopAnimating()
            emailTextField.layer.borderColor = UIColor.systemRed.cgColor
        }
        
        guard let password = passwordTextField.text, !password.isEmpty else {
            showAlert(message: "Password field cannot be empty")
            self.activityIndicator.stopAnimating()
            passwordTextField.layer.borderColor = UIColor.systemRed.cgColor
            return false
        }
        
        guard let confirmPassword = confirmPasswordTextField.text, !confirmPassword.isEmpty else {
            showAlert(message: "Confirm password field cannot be empty")
            self.activityIndicator.stopAnimating()
            confirmPasswordTextField.layer.borderColor = UIColor.systemRed.cgColor
            return false
        }
        
        if password != confirmPassword {
            showAlert(message: "Passwords do not match")
            self.activityIndicator.stopAnimating()
            confirmPasswordTextField.layer.borderColor = UIColor.systemRed.cgColor
            passwordTextField.layer.borderColor = UIColor.systemRed.cgColor
            confirmPasswordTextField.layer.borderColor = UIColor.systemRed.cgColor
            return false
        }
        
        if password.count < 8 {
            showAlert(message: "Password must be at least 8 characters long")
            self.activityIndicator.stopAnimating()
            passwordTextField.layer.borderColor = UIColor.systemRed.cgColor
            confirmPasswordTextField.layer.borderColor = UIColor.systemRed.cgColor
            return false
        }
        
        // You can add more criteria (e.g., check for numbers, special characters, etc.)
        return true
    }
    
    func resetTextFieldBorders() {
        // Reset the borders to the default color before validation
        let defaultBorderColor = UIColor.systemGray.cgColor
        
        usernameTextField.layer.borderColor = defaultBorderColor
        emailTextField.layer.borderColor = defaultBorderColor
        passwordTextField.layer.borderColor = defaultBorderColor
        confirmPasswordTextField.layer.borderColor = defaultBorderColor
    }

}

//MARK: - UITextFieldDelegate

extension RegisterViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
//
//    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
//        <#code#>
//    }
}

//MARK: - AuthManagerDelegate
extension RegisterViewController: AuthManagerDelegate {
    func didSignUpFail(_ error: String) {
        DispatchQueue.main.async{
            self.showAlert(message: error)
            print("Sign Up Fail")
            self.emailTextField.layer.borderColor = UIColor.systemRed.cgColor
            self.activityIndicator.stopAnimating()
        }
    }
    
    func didSignUp() {
        print("did Sign Up")
        print("I have activated")
        DispatchQueue.main.async {
            let email = self.emailTextField.text!
            print("I have not activated")
            let otpVC = OTPViewController()// Always create a new instance here
            otpVC.email = email
            otpVC.verifyType = .signup
            self.navigationController?.pushViewController(otpVC, animated: true)
            self.activityIndicator.stopAnimating()
        }
    }
}
