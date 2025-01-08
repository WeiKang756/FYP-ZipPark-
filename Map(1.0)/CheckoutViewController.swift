import StripePaymentSheet

class CheckoutViewController: UIViewController {
    var paymentSheet: PaymentSheet?
    let backendCheckoutUrl = URL(string: "YourBackendURL/payment-sheet")!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Fetch the payment setup data
        var request = URLRequest(url: backendCheckoutUrl)
        request.httpMethod = "POST"
        let task = URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) in
            // Parse response JSON for client secret, ephemeral key, customer ID, and publishable key
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                  let customerId = json["customer"] as? String,
                  let ephemeralKeySecret = json["ephemeralKey"] as? String,
                  let paymentIntentClientSecret = json["paymentIntent"] as? String,
                  let publishableKey = json["publishableKey"] as? String else {
                return
            }

            STPAPIClient.shared.publishableKey = publishableKey
            // Set up PaymentSheet with the retrieved configuration
            var configuration = PaymentSheet.Configuration()
            configuration.merchantDisplayName = "Your Business Name"
            configuration.customer = .init(id: customerId, ephemeralKeySecret: ephemeralKeySecret)
            configuration.allowsDelayedPaymentMethods = true // optional

            self?.paymentSheet = PaymentSheet(paymentIntentClientSecret: paymentIntentClientSecret, configuration: configuration)
            DispatchQueue.main.async {
                // Enable the checkout button to start payment
            }
        }
        task.resume()
    }

    @objc func didTapCheckoutButton() {
        paymentSheet?.present(from: self) { paymentResult in
            switch paymentResult {
            case .completed:
                print("Payment succeeded!")
            case .canceled:
                print("Payment canceled.")
            case .failed(let error):
                print("Payment failed: \(error.localizedDescription)")
            }
        }
    }
}
