//
//  LoginViewController.swift
//  Map(1.0)
//
//  Created by Wei Kang Tan on 09/10/2024.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var createAccountButton: UIButton!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var emailErrorLabel: UILabel!
    
    let supabase = SupabaseManager.shared
    let authManager = AuthManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        authManager.delegate = self

        view.backgroundColor = .white
        self.navigationItem.backButtonTitle = ""
        self.navigationController?.navigationBar.tintColor = .black
        let emailIcon = UIImage(systemName: "envelope")
        let passwordIcon = UIImage(systemName: "key.horizontal")
        let emailIconView = UIImageView(frame: CGRect(x: 10, y: 10, width: 35, height: 20))
        emailIconView.image = emailIcon
        let emailPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 55, height: 40))
        emailPaddingView.addSubview(emailIconView)
        
        let passwordIconView = UIImageView(frame: CGRect(x: 10, y: 10, width: 35, height: 20))
        passwordIconView.image = passwordIcon
        let passwordPaddingView = UIView(frame:  CGRect(x: 0, y: 0, width: 55, height: 40))
        passwordPaddingView.addSubview(passwordIconView)
        
        emailTextfield.layer.cornerRadius = 12.0
        emailTextfield.layer.borderWidth = 1.0
        emailTextfield.layer.borderColor = UIColor.systemGray.cgColor
        emailTextfield.leftView = emailPaddingView
        emailTextfield.leftViewMode = .always
        
        passwordTextField.layer.cornerRadius = 12.0
        passwordTextField.layer.borderWidth = 1.0
        passwordTextField.layer.borderColor = UIColor.systemGray.cgColor
        passwordTextField.leftView = passwordPaddingView
        passwordTextField.leftViewMode = .always
        
        emailTextfield.delegate = self
        passwordTextField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        authManager.delegate = self
        resetToDefault()
    }
    
    func resetToDefault() {
        // Reset the borders to the default color before validation
        let defaultBorderColor = UIColor.systemGray.cgColor
        
        emailTextfield.layer.borderColor = defaultBorderColor
        passwordTextField.layer.borderColor = defaultBorderColor
        errorLabel.isHidden = true
    }
    

    @IBAction func loginButtonPressed(_ sender: UIButton) {
//        performSegue(withIdentifier: "goToMapVC", sender: self)
        guard let email = emailTextfield.text else {
            print("Email Text Field is empty")
            return
        }
        
        guard let password = passwordTextField.text else {
            print("Password Text Field is empty")
            return
        }
        
        resetToDefault()
        authManager.signIn(email: email, password: password)
    }
    
    @IBAction func forgottenPasswordButtonPressed(_ sender: Any) {
        let floatingVC = FloatingViewController()
        floatingVC.modalPresentationStyle = .overFullScreen
        floatingVC.modalTransitionStyle = .crossDissolve
        floatingVC.delegate = self
        present(floatingVC, animated: true, completion: nil)
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "goToHomeScreen" {
//            if let homeViewController = segue.destination as? HomeViewController {
//                // You can pass any data to HomeViewController if needed
//                // homeViewController.data = ...
//            }
//        }
//    }
}

//MARK: FloatingViewControllerDelegate
extension LoginViewController: FloatingViewControllerDelegate {
    func didPressSignInWithOTPButton() {
        let vc = EnterEmailViewController()
        vc.type = .signInWithOTP
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func didPressResetPasswordButton() {
        let vc = EnterEmailViewController()
        vc.type = .resetPassword
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

//MARK: - UITextFieldDelegate
extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension LoginViewController: AuthManagerDelegate {
    func didSignIn() {
        // Create the Tab Bar Controller
        DispatchQueue.main.async {
            self.setRootViewControllerToHome()
        }
    }
    
    func didSignInFail(_ error: String) {
        DispatchQueue.main.async{ [self] in
            emailTextfield.layer.borderColor = UIColor.systemRed.cgColor
            passwordTextField.layer.borderColor = UIColor.systemRed.cgColor
            errorLabel.isHidden = false
            errorLabel.text = error
            showAlert(message: error)
        }
    }
    
    @MainActor
    private func setRootViewControllerToHome() {
        let vcController = HomeViewController()
        let navigationController = UINavigationController(rootViewController: vcController)
    //        navigationController.navigationBar.prefersLargeTitles = true

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
}


//MARK: - <#header section>


    
//    @IBAction func buttonTapped(_ sender: UIButton) {
//        performSegue(withIdentifier: "goToProgrammaticVC", sender: self)
//    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "goToMapVC" {
//            let destinationVC = MapViewController()
//            segue.destination.addChild(destinationVC)
//            segue.destination.view.addSubview(destinationVC.view)
//            destinationVC.didMove(toParent: segue.destination)
//        }
//    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

