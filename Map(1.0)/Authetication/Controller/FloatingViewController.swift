//
//  FloatingViewController.swift
//  Map(1.0)
//
//  Created by Wei Kang Tan on 16/10/2024.
//


import UIKit

protocol FloatingViewControllerDelegate: AnyObject {
    func didPressSignInWithOTPButton()
    func didPressResetPasswordButton()
}
class FloatingViewController: UIViewController {
    
    var delegate: FloatingViewControllerDelegate?
    let supabase = SupabaseManager.shared.client
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the background color with some transparency
        view.backgroundColor = UIColor(white: 0, alpha: 0.5)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissOnBackgroundTap(_:)))
        view.addGestureRecognizer(tapGesture)
            
        // Create a content view for the floating part
        let floatingView = UIView()
        floatingView.backgroundColor = .white
        floatingView.layer.cornerRadius = 20
        floatingView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(floatingView)
        
        // Add constraints to center the floating view
        NSLayoutConstraint.activate([
            floatingView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            floatingView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 50),
            floatingView.widthAnchor.constraint(equalToConstant: 300),
            floatingView.heightAnchor.constraint(equalToConstant: 155)
        ])
        
        // Ensure that taps inside the floatingView are not recognized by the gesture recognizer
        floatingView.isUserInteractionEnabled = true
        
        // Add your buttons or other elements to the floating view
        let dismissButton = UIButton(type: .system)
        dismissButton.setTitle("Cancel", for: .normal)
        dismissButton.addTarget(self, action: #selector(dismissFloatingView), for: .touchUpInside)
        dismissButton.tintColor = .black
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        floatingView.addSubview(dismissButton)
        
        let signInWithOTPButton = UIButton(type: .system)
        signInWithOTPButton.setTitle("Sign In with OTP", for: .normal)
        signInWithOTPButton.addTarget(self, action: #selector(signInWithOTPButtonPressed), for: .touchUpInside)
        signInWithOTPButton.tintColor = .black
        signInWithOTPButton.layer.borderWidth = 1.0
        signInWithOTPButton.layer.borderColor = UIColor.black.cgColor
        signInWithOTPButton.layer.cornerRadius = 10.0
        signInWithOTPButton.translatesAutoresizingMaskIntoConstraints = false
        floatingView.addSubview(signInWithOTPButton)
        
        let resetPasswordButton = UIButton(type: .system)
        resetPasswordButton.setTitle("Reset Password", for: .normal)
        resetPasswordButton.addTarget(self, action: #selector(resetBUtttonPressed), for: .touchUpInside)
        resetPasswordButton.tintColor = .black
        resetPasswordButton.layer.borderWidth = 1.0
        resetPasswordButton.layer.borderColor = UIColor.black.cgColor
        resetPasswordButton.layer.cornerRadius = 10.0
        resetPasswordButton.translatesAutoresizingMaskIntoConstraints = false
        floatingView.addSubview(resetPasswordButton)
    
        
        // Add constraints to the button
        NSLayoutConstraint.activate([
            dismissButton.centerXAnchor.constraint(equalTo: floatingView.centerXAnchor),
            dismissButton.bottomAnchor.constraint(equalTo: floatingView.bottomAnchor, constant: -10),
            
            signInWithOTPButton.leadingAnchor.constraint(equalTo: floatingView.leadingAnchor, constant: 50),
            signInWithOTPButton.trailingAnchor.constraint(equalTo: floatingView.trailingAnchor, constant: -50),
            signInWithOTPButton.topAnchor.constraint(equalTo: floatingView.topAnchor, constant: 20),
            
            resetPasswordButton.leadingAnchor.constraint(equalTo: floatingView.leadingAnchor, constant: 50),
            resetPasswordButton.trailingAnchor.constraint(equalTo: floatingView.trailingAnchor, constant: -50),
            resetPasswordButton.topAnchor.constraint(equalTo: signInWithOTPButton.bottomAnchor, constant: 20),
        ])
    }
    
    @objc func dismissOnBackgroundTap(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func dismissFloatingView() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func signInWithOTPButtonPressed() {
        dismissFloatingView()
        delegate?.didPressSignInWithOTPButton()
    }
    
    @objc func resetBUtttonPressed() {
        dismissFloatingView()
        delegate?.didPressResetPasswordButton()
    }
}

#Preview {
    FloatingViewController()
}
