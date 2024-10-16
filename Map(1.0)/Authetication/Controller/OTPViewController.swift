//
//  OTPViewController.swift
//  Map(1.0)
//
//  Created by Wei Kang Tan on 10/10/2024.
//

import UIKit

class OTPViewController: UIViewController {
    private var textFields: [UITextField] = []
    private let numberOfDigits = 6
    private let verifyButton = UIButton()
    var email: String? = ""
    var verifyType: VerifyType?
    var timer: Timer?
    var secondsRemaining = 10
    let button = UIButton()
    let resendOTPButton = UIButton(type: .system)
    let resultLabel = UILabel()
    let imageView = UIImageView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        AuthManager.shared.delegate = self
        setupLabel()
        startResendTimer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        AuthManager.shared.delegate = self
    }
    
    var labelString: String {
        switch verifyType {
        case .signup:
            return "Enter OTP to Verify Your Email"
        case .recovery:
            return "Enter OTP to Reset Password"
        case .magiclink:
            return "Enter OTP to Login"
        case .none:
            return "Error"
        }
    }
    
    private func setupLabel() {
        imageView.image = UIImage(systemName: "paperplane.fill")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        
        let label = UILabel()
        label.text = labelString 
        
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        let bodyLabel = UILabel()
        bodyLabel.text = "Enter OTP sent to \(email!)"
        bodyLabel.font = UIFont.systemFont(ofSize: 12, weight: .light)
        bodyLabel.textAlignment = .center
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bodyLabel)
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        
        
        button.setTitle("Verify", for: .normal)
        button.backgroundColor = .black
        button.tintColor = .white
        button.layer.cornerRadius = 10
        button.isEnabled = false
        button.alpha = 0.5
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(verifyButtonPressed), for: .touchUpInside)
        view.addSubview(button)
        
        resultLabel.font = UIFont.systemFont(ofSize: 12) // Set the font
        resultLabel.translatesAutoresizingMaskIntoConstraints = false
        resultLabel.isHidden = true
        view.addSubview(resultLabel)
        
        resendOTPButton.setTitleColor(.systemGray, for: .normal)
        resendOTPButton.addTarget(self, action: #selector(resendOTPButtonPressed), for: .touchUpInside)
        resendOTPButton.isEnabled = false
        resendOTPButton.alpha = 0.5
        resendOTPButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(resendOTPButton)
        
        for i in 0..<numberOfDigits {
            let textField = UITextField()
            textField.borderStyle = .roundedRect
            textField.textAlignment = .center
            textField.layer.borderColor = UIColor.lightGray.cgColor
            textField.layer.borderWidth = 3.0
            textField.layer.cornerRadius = 12.0
            textField.keyboardType = .numberPad
            textField.font = UIFont.systemFont(ofSize: 24)
            textField.delegate = self
            textField.tag = i
            textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
            stackView.addArrangedSubview(textField)
            textFields.append(textField)
        }

        textFields.first?.becomeFirstResponder()

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: bodyLabel.bottomAnchor, constant: 30),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 80),
            imageView.widthAnchor.constraint(equalToConstant: 80),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            bodyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            bodyLabel.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 10),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 40),
            stackView.heightAnchor.constraint(equalToConstant: 50),
            stackView.widthAnchor.constraint(equalToConstant: CGFloat(numberOfDigits * 40)),
            resultLabel.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 10),
            resultLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.topAnchor.constraint(equalTo: resultLabel.bottomAnchor, constant: 30),
            button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            resendOTPButton.topAnchor.constraint(equalTo: button.bottomAnchor, constant: 20),
            resendOTPButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    @objc private func verifyButtonPressed() {
        validateOTP()
    }
    
    @objc private func resendOTPButtonPressed() {
        if let email = self.email, let verifyType = self.verifyType {
            AuthManager.shared.resendOTP(email: email, verifyType: verifyType)
            startResendTimer()
        }
    }

    @objc private func textFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text, text.count == 1 else {
            return
        }

        let nextTag = textField.tag + 1
        if nextTag < numberOfDigits {
            textFields[nextTag].becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            button.isEnabled = true
            button.alpha = 1.0
        }
    }

    private func validateOTP() {
        let otp = textFields.compactMap { $0.text }.joined()
        print("Entered OTP: \(otp)")
        AuthManager.shared.verifyOTP(email: email!, otp: otp, verifyType: verifyType!)
        // Handle OTP validation here
    }
    
    func startResendTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateResendTimer), userInfo: nil, repeats: true)
    }
    
    
    @objc private func updateResendTimer() {
        secondsRemaining -= 1
        if secondsRemaining > 0 {
            UIView.performWithoutAnimation {
                resendOTPButton.setTitle("Resend in \(secondsRemaining)s", for: .normal)
                resendOTPButton.layoutIfNeeded() // Ensure layout is updated smoothly
            }
        } else {
            timer?.invalidate()
            timer = nil
            secondsRemaining = 60
            UIView.performWithoutAnimation {
                resendOTPButton.setTitle("Resend OTP", for: .normal)
                resendOTPButton.layoutIfNeeded() // Ensure layout is updated smoothly
            }
            resendOTPButton.alpha = 1.0
            resendOTPButton.isEnabled = true
        }
    }
}

//MARK: UITextFieldDelegate
extension OTPViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Allow only one character per field
        guard let text = textField.text else { return false }
        return text.count == 0 || string == ""
    }
}

extension OTPViewController: AuthManagerDelegate {
    func didResendOTP() {
        print("did send OTP")
    }
    
    func didVerifyOTP(verificationResult: Bool, result: String) {
        if verificationResult {
            DispatchQueue.main.async { [self] in
                print("I have active from delegate")
                imageView.image = UIImage(systemName: "checkmark")
                imageView.tintColor = .systemGreen
                for textField in self.textFields {
                    textField.layer.borderColor = UIColor.systemGreen.cgColor
                }
                resultLabel.text = result
                resultLabel.textColor = .systemGreen
            }
            
            switch verifyType{
            case .signup:
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.navigationController?.popToRootViewController(animated: true)
                }
            case .magiclink:
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    let vc = MapViewController()
                    self.navigationController?.pushViewController(vc, animated: true)
                    self.setRootViewControllerToHome()
                }
            case .recovery:
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    let vc = ResetPasswordViewController()
                    if var navigationController = self.navigationController?.viewControllers {
                        navigationController.removeLast()
                        navigationController.append(vc)
                        self.navigationController?.setViewControllers(navigationController, animated: true)
                    }
                }
            case .none:
                print("error")
            }
        }else {
            DispatchQueue.main.async{ [self] in
                imageView.image = UIImage(systemName: "xmark")
                imageView.tintColor = .systemRed
                for textField in self.textFields {
                    textField.layer.borderColor = UIColor.systemRed.cgColor
                }
                resultLabel.text = result
                resultLabel.textColor = .systemRed
                resultLabel.isHidden = false
            }
        }
    }
    
    @MainActor
    private func setRootViewControllerToHome() {
        let tabBarController = TabBarController()
        let navigationController = UINavigationController(rootViewController: tabBarController)
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

#Preview {
    OTPViewController()
}
