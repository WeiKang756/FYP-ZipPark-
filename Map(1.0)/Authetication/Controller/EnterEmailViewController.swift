//
//  EnterEmailViewController.swift
//  Map(1.0)
//
//  Created by Wei Kang Tan on 16/10/2024.
//

import UIKit

enum Type {
    case signInWithOTP
    case resetPassword
}
class EnterEmailViewController: UIViewController {

    let authManager = AuthManager.shared
    var type: Type? = nil
    
    lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.text = "Find Your Account"
        titleLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }()
    
    lazy var label: UILabel = {
        let label = UILabel()
        label.text = "Enter Your Email Address"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var errorLabel: UILabel = {
        let errorLabel = UILabel()
        errorLabel.font = UIFont.systemFont(ofSize: 12)
        errorLabel.text = "Enter Your Email Address"
        errorLabel.textColor = UIColor.systemRed
        errorLabel.isHidden = true
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        return errorLabel
    }()
    
    lazy var emailTextField: UITextField = {
        let emailTextField  = UITextField()
        emailTextField.placeholder = "Email"
        emailTextField.layer.borderWidth = 1.0
        emailTextField.layer.cornerRadius = 15
        emailTextField.layer.borderColor = UIColor.black.cgColor
        emailTextField.autocapitalizationType = .none
        emailTextField.autocorrectionType = .no
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        return emailTextField
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        authManager.delegate = self
        emailTextField.delegate = self
        view.backgroundColor = .white
        setupView()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        authManager.delegate = self
        resetToDefault()
    }
    
    func resetToDefault() {
        // Reset the borders to the default color before validation
        let defaultBorderColor = UIColor.systemGray.cgColor
        
        emailTextField.layer.borderColor = defaultBorderColor
        errorLabel.isHidden = true
    }
    
    
    
    func setupView() {
        view.addSubview(titleLabel)
        view.addSubview(label)
        view.addSubview(emailTextField)
        view.addSubview(errorLabel)
        
        addPaddingToTextField(emailTextField)
        
        let continueButton = UIButton(type: .system)
        continueButton.backgroundColor = .black
        continueButton.tintColor = .white
        continueButton.layer.cornerRadius = 10
        continueButton.setTitle("Continue", for: .normal)
        continueButton.addTarget(self, action: #selector(confirmButtonPressed), for: .touchUpInside)
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(continueButton)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            
            label.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            label.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            
            emailTextField.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 20),
            emailTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            emailTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            emailTextField.heightAnchor.constraint(equalToConstant: 50),
            
            errorLabel.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 3),
            errorLabel.leadingAnchor.constraint(equalTo: emailTextField.leadingAnchor, constant: 5),
            
            continueButton.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 30),
            continueButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            continueButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            continueButton.heightAnchor.constraint(equalToConstant: 35)
            
        ])
    }
    
    func addPaddingToTextField(_ textField: UITextField) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always // Ensure padding is always shown
    }
    
    func validate() -> Bool{
        guard let email = emailTextField.text, !email.isEmpty else {
            let error = "Email cannot be empty"
            emailTextField.layer.borderColor = UIColor.systemRed.cgColor
            errorLabel.text = error
            errorLabel.isHidden = false
            return false
        }
        
        if !isValidEmail(email) {
            let error = "Please Enter a Valid Email"
            emailTextField.layer.borderColor = UIColor.systemRed.cgColor
            errorLabel.text = error
            errorLabel.isHidden = false
            return false
        }
        
        return true
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailTest.evaluate(with: email)
    }
    
    @objc func confirmButtonPressed() {
        if !validate() {
            return
        }
        
        guard let email = emailTextField.text else {
            return
        }
        
        switch type {
        case .signInWithOTP:
            authManager.signInWithOTP(email: email)
        case .resetPassword:
            authManager.resetPassword(email: email)
        case .none:
            return
        }
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}

extension EnterEmailViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if validate() {
            textField.resignFirstResponder()
            return true
        }else{
            return true
        }
    }
}

extension EnterEmailViewController: AuthManagerDelegate {
    func didSignInWithOTP() {
        DispatchQueue.main.async {
            guard let email = self.emailTextField.text else{
                print ("Email nil")
                return
            }
            
            let vc = OTPViewController()
            vc.verifyType = .magiclink
            vc.email = email.lowercased()
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func didSignInWithOTPFail(_ error: String) {
        DispatchQueue.main.async {
            self.showAlert(message: error)
        }
    }
    
    func didResetPassword() {
        
        DispatchQueue.main.async {
            guard let email = self.emailTextField.text else{
                print ("Email nil")
                return
            }
            
            let vc = OTPViewController()
            vc.verifyType = .recovery
            vc.email = email.lowercased()
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func didResetPasswordFail(_ error: String) {
        DispatchQueue.main.async {
            self.showAlert(message: error)
        }
    }
}

#Preview {
    EnterEmailViewController()
}
