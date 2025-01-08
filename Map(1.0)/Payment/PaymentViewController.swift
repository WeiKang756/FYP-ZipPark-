//
//  PaymentViewController.swift
//  Map(1.0)
//
//  Created by Wei Kang Tan on 29/10/2024.
//

import UIKit
import StripePaymentSheet

class PaymentViewController: UIViewController {
    
    let paymentManager = PaymentManager.shared
    var paymentSheet: PaymentSheet?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        paymentManager.delegate = self
        setupUI()
    }
    
    func setupUI() {
        let checkoutButton = UIButton(type: .system)
        checkoutButton.setTitle("Checkout", for: .normal)
        checkoutButton.addTarget(self, action: #selector(checkout), for: .touchUpInside)
        checkoutButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(checkoutButton)
        
        NSLayoutConstraint.activate([
            checkoutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            checkoutButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    func setupPaymentSheet(clientSecret: String, ephemeralKeySecret: String, customerId: String) {
        // Create PaymentSheet configuration
        STPAPIClient.shared.publishableKey = "pk_test_51PTWrT1sc4VuKoffQkWIq0IhT7ZUkqLKQgfwv8lWVhUjCWauvO1IHCmBv4BaHRB2hx0M8Kx9GFxkFwalv084yo6F0008njRZXa"
        var configuration = PaymentSheet.Configuration()
        configuration.merchantDisplayName = "Zip Park"
        configuration.customer = .init(id: customerId, ephemeralKeySecret: ephemeralKeySecret)
        
        // Initialize the PaymentSheet with the clientSecret and configuration
        self.paymentSheet = PaymentSheet(paymentIntentClientSecret: clientSecret, configuration: configuration)
    }
    
    @IBAction func payButtonTapped(_ sender: UIButton) {
    }
    
    func presentPaymentSheet() {
        // Present the PaymentSheet to the user
        paymentSheet?.present(from: self) { paymentResult in
            switch paymentResult {
            case .completed:
                
                print("Payment successful!")
            case .canceled:
                print("Payment canceled.")
            case .failed(let error):
                print("Payment failed: \(error.localizedDescription)")
            }
        }
    }
    
    @objc func checkout() {
        paymentManager.createPaymentIntent(amount: 40.0, currency: "usd")
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

extension PaymentViewController: PaymentManagerDelegate {
    func paymentIntentDidCreate(_ paymentSheetRequest: PaymentSheetRequest) {
        print("Received clientSecret: \(paymentSheetRequest.clientSecret)")
        print("Received ephemeralKeySecret: \(paymentSheetRequest.ephemeralKeySecret)")
        setupPaymentSheet(clientSecret: paymentSheetRequest.clientSecret, ephemeralKeySecret: paymentSheetRequest.ephemeralKeySecret, customerId: paymentSheetRequest.customerId)
        DispatchQueue.main.async{
            self.presentPaymentSheet()
        }
    }
}

#Preview {
    PaymentViewController()
}
