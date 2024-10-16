//
//  PaymentViewController.swift
//  Map(1.0)
//
//  Created by Wei Kang Tan on 29/10/2024.
//

import UIKit
import StripePaymentSheet

class PaymentViewController: UIViewController {
    
    private let paymentManager = PaymentManager.shared
    var wallet: WalletData?
    let amountLabel = UILabel()
    private let tableView =  UITableView()
    var transactions: [TransactionModel]?
    let supabase = SupabaseManager.shared.client
    
    override func viewWillAppear(_ animated: Bool) {
        paymentManager.delegate = self
        Task {
            guard let wallet = await paymentManager.getWallet() else {
                return
            }
            DispatchQueue.main.async {
                self.wallet = wallet
                self.amountLabel.text = String(format: "RM %.2f", wallet.amount) // Update the balance label
                self.tableView.reloadData()
            }
        }
        paymentManager.fetchTransaction()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        tableView.register(UINib(nibName: "TransactionTableViewCell", bundle: nil), forCellReuseIdentifier: "TransactionCell")
        paymentManager.delegate = self
        if let tabBar = self.tabBarController?.tabBar {
            // Set the background color of the tab bar
            tabBar.backgroundColor = .white
            tabBar.isTranslucent = false
        }
        // Fetch wallet data asynchronously
        Task {
            guard let wallet = await paymentManager.getWallet() else {
                return
            }
            self.wallet = wallet
            // Update the UI on the main thread after fetching wallet data
            DispatchQueue.main.async {
                self.setupUI()
            }
        }
        
        tableView.dataSource = self
        paymentManager.fetchTransaction()
    }
    
    // Setup the user interface for the payment view
    func setupUI() {
        
        // Create the wallet label at the top
        let walletLabel = UILabel()
        walletLabel.text = "Wallet"
        walletLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        walletLabel.textColor = .black
        walletLabel.textAlignment = .center
        walletLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(walletLabel)
        
        // Create the wallet label at the top
        let transactionLabel = UILabel()
        transactionLabel.text = "Transaction"
        transactionLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        transactionLabel.textColor = .black
        transactionLabel.textAlignment = .center
        transactionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(transactionLabel)
        
        // Create the card view that contains balance information and other elements
        let cardView = UIView()
        cardView.backgroundColor = .black
        cardView.layer.cornerRadius = 15 // Rounded corners for the card view
        cardView.layer.masksToBounds = true // Ensure subviews are clipped to rounded corners
        cardView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(cardView)

        // Create the "+" button to add balance
        let addButton = UIButton(type: .system)
        addButton.setTitle("+", for: .normal)
        addButton.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        addButton.setTitleColor(.white, for: .normal)
        addButton.addTarget(self, action: #selector(showTopUpViewController), for: .touchUpInside)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(addButton)

        // Create the "Your Balance:" label
        let balanceLabel = UILabel()
        balanceLabel.text = "YOUR BALANCE:"
        balanceLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        balanceLabel.textColor = .white
        balanceLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(balanceLabel)

        // Create the balance amount label
        amountLabel.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        amountLabel.textColor = .white
        amountLabel.translatesAutoresizingMaskIntoConstraints = false
        amountLabel.text = wallet != nil ? String(format: "RM %.2f", wallet!.amount) : "Loading..."
        cardView.addSubview(amountLabel)

        // Create the "ZipPark" label for branding
        let zipParkLabel = UILabel()
        zipParkLabel.text = "ZipPark"
        zipParkLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        zipParkLabel.textColor = .white
        zipParkLabel.textAlignment = .right
        zipParkLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(zipParkLabel)

        // Create the parking icon image view
        let parkingIconImageView = UIImageView()
        parkingIconImageView.image = UIImage(named: "white_logo") // Replace with actual image name
        parkingIconImageView.contentMode = .scaleAspectFit // Maintain aspect ratio of the image
        parkingIconImageView.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(parkingIconImageView)
        
        // Create the table view for transactions
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        // Setup constraints for all UI elements
        NSLayoutConstraint.activate([
            // Card view constraints
            walletLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            walletLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            
            cardView.topAnchor.constraint(equalTo: walletLabel.bottomAnchor, constant: 10),
            cardView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            cardView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            cardView.heightAnchor.constraint(equalToConstant: 150),
            
            // Add button constraints
            addButton.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 10),
            addButton.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 15),
            
            // Balance label constraints
            balanceLabel.topAnchor.constraint(equalTo: addButton.bottomAnchor, constant: 15),
            balanceLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 15),
            
            // Amount label constraints
            amountLabel.topAnchor.constraint(equalTo: balanceLabel.bottomAnchor, constant: 10),
            amountLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 15),
            
            // ZipPark label constraints
            zipParkLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 15),
            zipParkLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -15),
            
            // Parking icon image view constraints
            parkingIconImageView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -10),
            parkingIconImageView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -10),
            parkingIconImageView.widthAnchor.constraint(equalToConstant: 50),
            parkingIconImageView.heightAnchor.constraint(equalToConstant: 60),
            
            transactionLabel.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 10),
            transactionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            
            tableView.topAnchor.constraint(equalTo: transactionLabel.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 10)
            
        ])
    }
    
    @objc func showTopUpViewController() {
        let floatingPanelVC = TopUpViewController()
        if let wallet = wallet {
            let balance = String(format: "RM %.2f", wallet.amount)
            floatingPanelVC.walletAmount = balance
        }
        self.navigationController?.pushViewController(floatingPanelVC, animated: true)
    }
}

//MARK: - PaymentManagerDelegate

extension PaymentViewController: PaymentManagerDelegate {
    func transactionDidFetch(_ transactionModels: [TransactionModel]) {
        transactions = transactionModels
        guard transactions != nil else {
            print("Fail to get transaction (delegate PaymentViewController)")
            return
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

extension PaymentViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numberOfRow = transactions?.count ?? 0
        return numberOfRow == 0 ? 1 : numberOfRow
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let transactions = transactions, !transactions.isEmpty {
            let cell =  tableView.dequeueReusableCell(withIdentifier: "TransactionCell", for: indexPath) as! TransactionTableViewCell
            let transaction = transactions[indexPath.row]
            cell.transactionDateLabel.text = transaction.date
            cell.transactionTypeLabel.text = transaction.type
            if transaction.type == "Top Up" {
                cell.amountLabel.textColor = .systemGreen
            } else {
                cell.amountLabel.textColor = .systemRed
            }
            cell.amountLabel.text = String(format: "RM %.2f", transaction.amount)
            return cell
        } else {
            let cell = UITableViewCell()
            cell.textLabel?.text = "No transactions have been made before."
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.textColor = .darkGray
            return cell
        }
    }
}
