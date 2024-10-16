//
//  ResetPasswordViewController.swift
//  Map(1.0)
//
//  Created by Wei Kang Tan on 18/10/2024.
//

import UIKit

class ResetPasswordViewController: UIViewController {
    
    let authManager = AuthManager.shared
    
    lazy var titleLabel = {
        let titleLabel = UILabel()
        titleLabel.text = "Reset Password"
        titleLabel.font = UIFont.systemFont(ofSize: 26, weight: .bold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }()
    
    lazy var label = {
        let label = UILabel()
        label.text = "Enter your new password"
        label.font = UIFont.systemFont(ofSize: 14, weight: .light)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var passwordTextField: UITextField =  {
        let passwordTextField = UITextField()
        passwordTextField.placeholder = "New Password"
        passwordTextField.layer.borderWidth = 1.0
        passwordTextField.layer.cornerRadius = 10
        passwordTextField.layer.borderColor = UIColor.black.cgColor
        passwordTextField.autocapitalizationType = .none
        passwordTextField.autocorrectionType = .no
        passwordTextField.isSecureTextEntry = true
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        addPaddingToTextField(passwordTextField)
        return passwordTextField
    }()
    
    lazy var confirmPasswordTextField: UITextField =  {
        let confirmPasswordTextField = UITextField()
        confirmPasswordTextField.placeholder = "Confirm New Password"
        confirmPasswordTextField.layer.borderWidth = 1.0
        confirmPasswordTextField.layer.cornerRadius = 10
        confirmPasswordTextField.layer.borderColor = UIColor.black.cgColor
        confirmPasswordTextField.autocapitalizationType = .none
        confirmPasswordTextField.autocorrectionType = .no
        confirmPasswordTextField.isSecureTextEntry = true
        confirmPasswordTextField.translatesAutoresizingMaskIntoConstraints = false
        addPaddingToTextField(confirmPasswordTextField)
        return confirmPasswordTextField
    }()
    
    lazy var confirmButoton: UIButton  = {
        let button = UIButton()
        button.backgroundColor = .black
        button.tintColor = .white
        button.layer.cornerRadius = 10
        button.setTitle("Continue", for: .normal)
        button.addTarget(self, action: #selector(confirmButtonPressed), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        authManager.delegate = self
        setupView()
    }
    
    func setupView() {
        view.addSubview(titleLabel)
        view.addSubview(label)
        view.addSubview(passwordTextField)
        view.addSubview(confirmPasswordTextField)
        view.addSubview(confirmButoton)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            label.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            passwordTextField.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 20),
            passwordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            passwordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            passwordTextField.heightAnchor.constraint(equalToConstant: 50),
            
            confirmPasswordTextField.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 20),
            confirmPasswordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            confirmPasswordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            confirmPasswordTextField.heightAnchor.constraint(equalToConstant: 50),
            
            confirmButoton.topAnchor.constraint(equalTo: confirmPasswordTextField.bottomAnchor, constant: 30),
            confirmButoton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            confirmButoton .trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            confirmButoton.heightAnchor.constraint(equalToConstant: 35)
        ])
    }
    
    func addPaddingToTextField(_ textField: UITextField) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always // Ensure padding is always shown
    }
    
    func validate() -> Bool {
        guard let password = passwordTextField.text, !password.isEmpty else {
            showAlert(message: "Password field cannot be empty")
            passwordTextField.layer.borderColor = UIColor.systemRed.cgColor
            return false
        }
        
        guard let confirmPassword = confirmPasswordTextField.text, !confirmPassword.isEmpty else {
            showAlert(message: "Confirm password field cannot be empty")
            confirmPasswordTextField.layer.borderColor = UIColor.systemRed.cgColor
            return false
        }
        
        if password != confirmPassword {
            showAlert(message: "Passwords do not match")
            confirmPasswordTextField.layer.borderColor = UIColor.systemRed.cgColor
            passwordTextField.layer.borderColor = UIColor.systemRed.cgColor
            confirmPasswordTextField.layer.borderColor = UIColor.systemRed.cgColor
            return false
        }
        
        if password.count < 8 {
            showAlert(message: "Password must be at least 8 characters long")
            passwordTextField.layer.borderColor = UIColor.systemRed.cgColor
            confirmPasswordTextField.layer.borderColor = UIColor.systemRed.cgColor
            return false
        }
       
        return true
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    @objc func confirmButtonPressed() {
        if !validate() {
            return
        }
        
        guard let password = passwordTextField.text else{
            print("Password is nil")
            return
        }
        
        authManager.updatePassword(newPassword: password)
    }
}

//MARK: - UITextFieldDelegate
extension ResetPasswordViewController: UITextFieldDelegate {
     
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

//MARK: - AuthManagerDelegate
extension ResetPasswordViewController: AuthManagerDelegate {
    
    func didUpdatePassword() {
        SupabaseManager.shared.signOut()
        DispatchQueue.main.async {
            self.passwordTextField.layer.borderColor = UIColor.systemGreen.cgColor
            self.confirmPasswordTextField.layer.borderColor = UIColor.systemGreen.cgColor
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.navigationController?.popToRootViewController(animated: true)
        }
        
    }
    
    func didUpdatePasswordFail(_ error: String) {
        DispatchQueue.main.async {
            self.passwordTextField.layer.borderColor = UIColor.systemGreen.cgColor
            self.confirmPasswordTextField.layer.borderColor = UIColor.systemGreen.cgColor
        }
        
        showAlert(message: error)
    }
}

#Preview {
    ResetPasswordViewController()
}
