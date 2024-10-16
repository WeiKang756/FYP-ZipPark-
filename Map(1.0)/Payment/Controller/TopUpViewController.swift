//
//  TopUpViewController.swift
//  Map(1.0)
//
//  Created by Wei Kang Tan on 03/11/2024.
//

import UIKit
import StripePaymentSheet

class TopUpViewController: UIViewController {
    
    private let paymentManager = PaymentManager.shared
    private var paymentSheet: PaymentSheet?
    private var selectedButton: UIButton? = nil
    private let continueButton = UIButton(type: .system)
    private var amountSelected: Double = 0.0
    var walletAmount: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = "Top Up"
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .never
        paymentManager.delegate = self
        setupUI()
    }
    
    // Setup the user interface for adding balance
    func setupUI() {

        // Create the title label
        let titleLabel = UILabel()
        titleLabel.text = "Add Money"
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.textColor = .black
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        // Create the description label
        let descriptionLabel = UILabel()
        descriptionLabel.text = "Select an amount to add money to your account, and use it to make payment."
        descriptionLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        descriptionLabel.textColor = .darkGray
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(descriptionLabel)
        
        // Create the balance options buttons in a grid (1 row with 3 buttons)
        let amounts = ["RM 10": 1000.0, "RM 20": 2000.0, "RM 50": 5000.0, "RM 100": 10000.0, "RM 200": 20000.0, "RM 500": 50000.0]
        var buttons: [UIButton] = []
        let sortedAmounts = amounts.sorted { $0.value < $1.value }
        
        for (amount, value) in sortedAmounts {
            let button = UIButton(type: .system)
            button.setTitle(amount, for: .normal)
            button.backgroundColor = .systemGray6
            button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
            button.setTitleColor(.black, for: .normal)
            button.layer.cornerRadius = 10
            button.addTarget(self, action: #selector(balanceButtonTapped(_:)), for: .touchUpInside)
            button.tag = Int(value) // Set tag to identify the button value later
            button.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(button)
            buttons.append(button)
        }
        
        // Create a UIStackView to hold the buttons in a grid layout
        let buttonStackView = UIStackView()
        buttonStackView.axis = .vertical
        buttonStackView.alignment = .fill
        buttonStackView.distribution = .fillProportionally
        buttonStackView.spacing = 15
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonStackView)
        
        // Create horizontal stacks of buttons
        for i in stride(from: 0, to: buttons.count, by: 3) {
            let rowStackView = UIStackView(arrangedSubviews: Array(buttons[i..<min(i + 3, buttons.count)]))
            rowStackView.axis = .horizontal
            rowStackView.alignment = .fill
            rowStackView.distribution = .fillEqually
            rowStackView.spacing = 15
            buttonStackView.addArrangedSubview(rowStackView)
        }
        
        // Create the balance label
        let balanceLabel = UILabel()
        if let walletAmount = walletAmount{
            balanceLabel.text = "Balance: \(walletAmount)"
        } else{
            print("Fail to get wallet balance")
            balanceLabel.text = "Balance: N/A"
        }
        balanceLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        balanceLabel.textColor = .black
        balanceLabel.textAlignment = .center
        balanceLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(balanceLabel)
        
        // Create the continue button
        continueButton.setTitle("Continue", for: .normal)
        continueButton.backgroundColor = .systemGray5
        continueButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        continueButton.setTitleColor(.white, for: .normal)
        continueButton.layer.cornerRadius = 10
        continueButton.isEnabled = false
        continueButton.addTarget(self, action: #selector(continueButtonTapped), for: .touchUpInside)
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(continueButton)
        
        // Setup constraints for UI elements
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 15),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            buttonStackView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 30),
            buttonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            balanceLabel.topAnchor.constraint(equalTo: buttonStackView.bottomAnchor, constant: 30),
            balanceLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            continueButton.topAnchor.constraint(equalTo: balanceLabel.bottomAnchor, constant: 30),
            continueButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            continueButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            continueButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc func cancelButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func balanceButtonTapped(_ sender: UIButton) {
        // Handle button tap, using the tag to identify which button was tapped
        if let selectedButton = selectedButton {
            // Reset previously selected button to default appearance
            selectedButton.backgroundColor = .systemGray6
            selectedButton.setTitleColor(.black, for: .normal)
        }
        
        // Set the new selected button
        selectedButton = sender
        selectedButton?.backgroundColor = .black
        selectedButton?.setTitleColor(.white, for: .normal)
        
        // Update the amountSelected variable
        amountSelected = Double(sender.tag)
        
        // Enable the continue button
        continueButton.backgroundColor = .black
        continueButton.isEnabled = true
    }
    
    @objc func continueButtonTapped() {
        print("User selected amount to top up: RM \(amountSelected / 100)")
        // Trigger the creation of a payment intent or perform other actions
        // Example: checkout(amount: amountSelected)
        
        paymentManager.createPaymentIntent(amount: amountSelected)
    }
    

    
    // Setup the PaymentSheet with the provided client secret, ephemeral key secret, and customer ID
    func setupPaymentSheet(clientSecret: String, ephemeralKeySecret: String, customerId: String) {
        // Set the publishable key for Stripe
        STPAPIClient.shared.publishableKey = "pk_test_51PTWrT1sc4VuKoffQkWIq0IhT7ZUkqLKQgfwv8lWVhUjCWauvO1IHCmBv4BaHRB2hx0M8Kx9GFxkFwalv084yo6F0008njRZXa"
        
        // Create a PaymentSheet configuration
        var configuration = PaymentSheet.Configuration()
        configuration.merchantDisplayName = "Zip Park" // Display name for the merchant
        configuration.customer = .init(id: customerId, ephemeralKeySecret: ephemeralKeySecret)
        
        // Initialize the PaymentSheet with the clientSecret and configuration
        self.paymentSheet = PaymentSheet(paymentIntentClientSecret: clientSecret, configuration: configuration)
    }
    
    // Function to present the PaymentSheet to the user
    func presentPaymentSheet() {
        paymentSheet?.present(from: self) { paymentResult in
            // Handle the result of the payment
            switch paymentResult {
            case .completed:
                self.navigationController?.popViewController(animated: true)
                print("Payment successful!") // Payment was successful
            case .canceled:
                print("Payment canceled.") // User canceled the payment
            case .failed(let error):
                print("Payment failed: \(error.localizedDescription)") // Payment failed with an error
            }
        }
    }
}

// Extension to handle PaymentManagerDelegate methods
extension TopUpViewController: PaymentManagerDelegate {
    func paymentIntentDidCreate(_ paymentSheetRequest: PaymentSheetRequest) {
        // Log the received clientSecret and ephemeralKeySecret for debugging
        print("Received clientSecret: \(paymentSheetRequest.clientSecret)")
        print("Received ephemeralKeySecret: \(paymentSheetRequest.ephemeralKeySecret)")
        
        // Setup the PaymentSheet with the received parameters
        setupPaymentSheet(clientSecret: paymentSheetRequest.clientSecret, ephemeralKeySecret: paymentSheetRequest.ephemeralKeySecret, customerId: paymentSheetRequest.customerId)
        
        // Present the PaymentSheet on the main thread
        DispatchQueue.main.async {
            self.presentPaymentSheet()
        }
    }
}
