import UIKit

class OTPViewController: UIViewController {
    // MARK: - Properties
    private var textFields: [UITextField] = []
    private let numberOfDigits = 6
    private var timer: Timer?
    private var secondsRemaining = 60
    var email: String?
    var verifyType: VerifyType?
    
    // MARK: - UI Components
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "paperplane.fill")
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .black
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .systemGray
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let otpStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let verifyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Verify", for: .normal)
        button.backgroundColor = .black
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.isEnabled = false
        button.alpha = 0.5
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let resendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(.systemGray, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14)
        button.isEnabled = false
        button.alpha = 0.5
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let resultLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .center
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.color = .white
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTextFields()
        setupActions()
        AuthManager.shared.delegate = self
        startResendTimer()
        updateTitles()
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(containerView)
        [imageView, titleLabel, subtitleLabel, otpStackView,
         verifyButton, resendButton, resultLabel, loadingIndicator].forEach {
            containerView.addSubview($0)
        }
        
        setupConstraints()
    }
    
    private func setupTextFields() {
        for i in 0..<numberOfDigits {
            let textField = createOTPTextField(tag: i)
            otpStackView.addArrangedSubview(textField)
            textFields.append(textField)
        }
        textFields.first?.becomeFirstResponder()
    }
    
    private func createOTPTextField(tag: Int) -> UITextField {
        let textField = UITextField()
        textField.borderStyle = .none
        textField.textAlignment = .center
        textField.backgroundColor = .systemGray6
        textField.layer.cornerRadius = 12
        textField.keyboardType = .numberPad
        textField.font = .systemFont(ofSize: 24, weight: .bold)
        textField.delegate = self
        textField.tag = tag
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)),
                          for: .editingChanged)
        return textField
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            imageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 40),
            imageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 80),
            imageView.widthAnchor.constraint(equalToConstant: 80),
            
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            otpStackView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 40),
            otpStackView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            otpStackView.heightAnchor.constraint(equalToConstant: 50),
            otpStackView.widthAnchor.constraint(equalToConstant: CGFloat(numberOfDigits * 45)),
            
            resultLabel.topAnchor.constraint(equalTo: otpStackView.bottomAnchor, constant: 16),
            resultLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            resultLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            verifyButton.bottomAnchor.constraint(equalTo: resendButton.topAnchor, constant: -16),
            verifyButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            verifyButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            verifyButton.heightAnchor.constraint(equalToConstant: 50),
            
            resendButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -40),
            resendButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: verifyButton.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: verifyButton.centerYAnchor)
        ])
    }
    
    private func setupActions() {
        verifyButton.addTarget(self, action: #selector(verifyButtonPressed), for: .touchUpInside)
        resendButton.addTarget(self, action: #selector(resendOTPButtonPressed), for: .touchUpInside)
    }
    
    private func updateTitles() {
        titleLabel.text = getTitleForVerifyType()
        if let email = email {
            subtitleLabel.text = "Enter OTP sent to \(email)"
        }
    }
    
    private func getTitleForVerifyType() -> String {
        switch verifyType {
        case .signup:
            return "Enter OTP to Verify Your Email"
        case .recovery:
            return "Enter OTP to Reset Password"
        case .magiclink:
            return "Enter OTP to Login"
        case .none:
            return "Verification Required"
        }
    }
    
    // MARK: - Timer Methods
    private func startResendTimer() {
        timer?.invalidate()
        secondsRemaining = 60
        updateResendButtonTitle()
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self,
                                   selector: #selector(updateResendTimer),
                                   userInfo: nil, repeats: true)
    }
    
    @objc private func updateResendTimer() {
        secondsRemaining -= 1
        if secondsRemaining > 0 {
            updateResendButtonTitle()
        } else {
            enableResendButton()
        }
    }
    
    private func updateResendButtonTitle() {
        UIView.performWithoutAnimation {
            resendButton.setTitle("Resend in \(secondsRemaining)s", for: .normal)
            resendButton.layoutIfNeeded()
        }
    }
    
    private func enableResendButton() {
        timer?.invalidate()
        timer = nil
        UIView.animate(withDuration: 0.3) {
            self.resendButton.setTitle("Resend OTP", for: .normal)
            self.resendButton.alpha = 1.0
            self.resendButton.isEnabled = true
        }
    }
    
    // MARK: - Action Methods
    @objc private func verifyButtonPressed() {
        guard let email = email, let verifyType = verifyType else { return }
        
        let otp = textFields.compactMap { $0.text }.joined()
        startLoading()
        AuthManager.shared.verifyOTP(email: email, otp: otp, verifyType: verifyType)
    }
    
    @objc private func resendOTPButtonPressed() {
        guard let email = email, let verifyType = verifyType else { return }
        AuthManager.shared.resendOTP(email: email, verifyType: verifyType)
        startResendTimer()
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text, text.count == 1 else { return }
        
        let nextTag = textField.tag + 1
        if nextTag < numberOfDigits {
            textFields[nextTag].becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            enableVerifyButton()
        }
    }
    
    private func enableVerifyButton() {
        let isComplete = textFields.allSatisfy { $0.text?.count == 1 }
        UIView.animate(withDuration: 0.3) {
            self.verifyButton.isEnabled = isComplete
            self.verifyButton.alpha = isComplete ? 1.0 : 0.5
        }
    }
    
    private func startLoading() {
        loadingIndicator.startAnimating()
        verifyButton.setTitle("", for: .normal)
        verifyButton.isEnabled = false
    }
    
    private func stopLoading() {
        loadingIndicator.stopAnimating()
        verifyButton.setTitle("Verify", for: .normal)
        verifyButton.isEnabled = true
    }
    
    private func handleSuccess() {
        UIView.animate(withDuration: 0.3) {
            self.imageView.image = UIImage(systemName: "checkmark.circle.fill")
            self.imageView.tintColor = .systemGreen
            self.textFields.forEach { $0.backgroundColor = .systemGreen.withAlphaComponent(0.1) }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.navigateAfterSuccess()
        }
    }
    
    private func handleError(_ message: String) {
        UIView.animate(withDuration: 0.3) {
            self.imageView.image = UIImage(systemName: "xmark.circle.fill")
            self.imageView.tintColor = .systemRed
            self.textFields.forEach { $0.backgroundColor = .systemRed.withAlphaComponent(0.1) }
            self.resultLabel.text = message
            self.resultLabel.textColor = .systemRed
            self.resultLabel.isHidden = false
        }
    }
    
    private func navigateAfterSuccess() {
        switch verifyType {
        case .signup:
            navigationController?.popToRootViewController(animated: true)
        case .magiclink:
            let tabBarController = TabBarController()
            setRootViewController(tabBarController)
        case .recovery:
            let resetPasswordVC = ResetPasswordViewController()
            navigationController?.setViewControllers([resetPasswordVC], animated: true)
        case .none:
            break
        }
    }
    
    @MainActor
    private func setRootViewController(_ viewController: UIViewController) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return }
        
        let navigationController = UINavigationController(rootViewController: viewController)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        
        UIView.transition(with: window, duration: 0.5,
                         options: .transitionFlipFromRight,
                         animations: nil, completion: nil)
    }
}

// MARK: - UITextFieldDelegate
extension OTPViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField,
                  shouldChangeCharactersIn range: NSRange,
                  replacementString string: String) -> Bool {
        guard let text = textField.text else { return false }
        return text.count + string.count <= 1
    }
}

// MARK: - AuthManagerDelegate
extension OTPViewController: AuthManagerDelegate {
    func didResendOTP() {
        print("OTP resent successfully")
    }
    
    func didVerifyOTP(verificationResult: Bool, result: String) {
        DispatchQueue.main.async {
            self.stopLoading()
            if verificationResult {
                self.handleSuccess()
            } else {
                self.handleError(result)
            }
        }
    }
}
