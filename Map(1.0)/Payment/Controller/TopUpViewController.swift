import UIKit
import StripePaymentSheet

class TopUpViewController: UIViewController {
    
    // MARK: - Properties
    private let paymentManager = PaymentManager.shared
    private var paymentSheet: PaymentSheet?
    private var selectedButton: UIButton? = nil
    private var amountSelected: Double = 0.0
    var walletAmount: String?
    
    // MARK: - UI Components
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Add Money"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .black
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Select an amount to add money to your account."
        label.font = .systemFont(ofSize: 16)
        label.textColor = .darkGray
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var buttonStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.spacing = 15
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var balanceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var continueButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Continue", for: .normal)
        button.backgroundColor = .systemGray5
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(continueButtonTapped), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewController()
        setupUI()
        paymentManager.delegate = self
        updateBalanceLabel()
    }
    
    // MARK: - Setup
    private func configureViewController() {
        view.backgroundColor = .systemBackground
        navigationItem.title = "Top Up"
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .never
    }
    
    private func setupUI() {
        setupViews()
        setupAmountButtons()
        setupConstraints()
    }
    
    private func setupViews() {
        [titleLabel, descriptionLabel, buttonStackView, balanceLabel, continueButton, loadingIndicator].forEach {
            view.addSubview($0)
        }
    }
    
    private func updateBalanceLabel() {
        if let amount = walletAmount {
            balanceLabel.text = "Current Balance: RM \(amount)"
        } else {
            balanceLabel.text = "Current Balance: Loading..."
        }
    }
    
    private func setupAmountButtons() {
        let amounts = [
            "RM 10": 1000.0,
            "RM 20": 2000.0,
            "RM 50": 5000.0,
            "RM 100": 10000.0,
            "RM 200": 20000.0,
            "RM 500": 50000.0
        ].sorted { $0.value <= $1.value }
        
        var currentRowStack: UIStackView?
        
        for (index, amount) in amounts.enumerated() {
            if index % 3 == 0 {
                currentRowStack = createRowStack()
                buttonStackView.addArrangedSubview(currentRowStack!)
            }
            
            let button = createAmountButton(title: amount.key, value: amount.value)
            currentRowStack?.addArrangedSubview(button)
        }
        
        // Fill remaining spaces in last row if needed
        if let lastRow = currentRowStack, amounts.count % 3 != 0 {
            let remainingSpaces = 3 - (amounts.count % 3)
            for _ in 0..<remainingSpaces {
                let spacerView = UIView()
                lastRow.addArrangedSubview(spacerView)
            }
        }
    }
    
    private func createRowStack() -> UIStackView {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 12
        return stack
    }
    
    private func createAmountButton(title: String, value: Double) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.backgroundColor = .systemGray6
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.setTitleColor(.black, for: .normal)
        button.layer.cornerRadius = 12
        button.tag = Int(value)
        button.addTarget(self, action: #selector(balanceButtonTapped(_:)), for: .touchUpInside)
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        return button
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            balanceLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 24),
            balanceLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            balanceLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            buttonStackView.topAnchor.constraint(equalTo: balanceLabel.bottomAnchor, constant: 32),
            buttonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            continueButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            continueButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            continueButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            continueButton.heightAnchor.constraint(equalToConstant: 50),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: continueButton.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: continueButton.centerYAnchor)
        ])
    }
    
    // MARK: - Actions
    @objc private func balanceButtonTapped(_ sender: UIButton) {
        UIView.animate(withDuration: 0.2) {
            // Reset previous selection
            self.selectedButton?.backgroundColor = .systemGray6
            self.selectedButton?.setTitleColor(.black, for: .normal)
            
            // Set new selection
            self.selectedButton = sender
            self.selectedButton?.backgroundColor = .black
            self.selectedButton?.setTitleColor(.white, for: .normal)
            
            // Update amount and continue button
            self.amountSelected = Double(sender.tag)
            self.continueButton.backgroundColor = .black
            self.continueButton.isEnabled = true
        }
    }
    
    @objc private func continueButtonTapped() {
        guard amountSelected > 0 else { return }
        
        loadingIndicator.startAnimating()
        continueButton.setTitle("", for: .normal)
        continueButton.isEnabled = false
        
        paymentManager.createPaymentIntent(amount: amountSelected)
    }
    
    private func handlePaymentCompletion(success: Bool) {
        loadingIndicator.stopAnimating()
        continueButton.setTitle("Continue", for: .normal)
        continueButton.isEnabled = true
        
        if success {
            navigationController?.popViewController(animated: true)
        }
    }
}

// MARK: - PaymentManagerDelegate
extension TopUpViewController: PaymentManagerDelegate {
    func paymentIntentDidCreate(_ paymentSheetRequest: PaymentSheetRequest) {
        setupPaymentSheet(
            clientSecret: paymentSheetRequest.clientSecret,
            ephemeralKeySecret: paymentSheetRequest.ephemeralKeySecret,
            customerId: paymentSheetRequest.customerId
        )
        
        DispatchQueue.main.async { [weak self] in
            self?.presentPaymentSheet()
        }
    }
    
    private func setupPaymentSheet(clientSecret: String, ephemeralKeySecret: String, customerId: String) {
        STPAPIClient.shared.publishableKey = "pk_test_51PTWrT1sc4VuKoffQkWIq0IhT7ZUkqLKQgfwv8lWVhUjCWauvO1IHCmBv4BaHRB2hx0M8Kx9GFxkFwalv084yo6F0008njRZXa"
        
        var configuration = PaymentSheet.Configuration()
        configuration.merchantDisplayName = "Zip Park"
        configuration.customer = .init(id: customerId, ephemeralKeySecret: ephemeralKeySecret)
        
        paymentSheet = PaymentSheet(paymentIntentClientSecret: clientSecret, configuration: configuration)
    }
    
    private func presentPaymentSheet() {
        loadingIndicator.stopAnimating()
        continueButton.setTitle("Continue", for: .normal)
        
        paymentSheet?.present(from: self) { [weak self] paymentResult in
            switch paymentResult {
            case .completed:
                self?.handlePaymentCompletion(success: true)
            case .canceled:
                self?.handlePaymentCompletion(success: false)
            case .failed(let error):
                print("Payment failed: \(error.localizedDescription)")
                self?.handlePaymentCompletion(success: false)
                // Show error alert here
            }
        }
    }
}
