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
    private var paymentSheet: PaymentSheet?
    var wallet: WalletData?
    let amountLabel = UILabel()
    private let tableView = UITableView()
    var transactions: [TransactionModel]?
    let supabase = SupabaseManager.shared.client
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
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
        paymentManager.delegate = self
        
        // Register the table view cell
        tableView.register(UINib(nibName: "TransactionTableViewCell", bundle: nil), forCellReuseIdentifier: "TransactionCell")
        tableView.dataSource = self
        
        // Configure tab bar appearance
        if let tabBar = self.tabBarController?.tabBar {
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
    }
    
    // Setup the user interface for the payment view
    func setupUI() {
        // Wallet label
        let walletLabel = UILabel()
        walletLabel.text = "Wallet"
        walletLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        walletLabel.textColor = .black
        walletLabel.textAlignment = .center
        walletLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(walletLabel)
        
        // Transaction label
        let transactionLabel = UILabel()
        transactionLabel.text = "Transaction"
        transactionLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        transactionLabel.textColor = .black
        transactionLabel.textAlignment = .center
        transactionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(transactionLabel)
        
        // Card view
        let cardView = UIView()
        cardView.backgroundColor = .black
        cardView.layer.cornerRadius = 15
        cardView.layer.masksToBounds = true
        cardView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cardView)
        
        // Add button
        let addButton = UIButton(type: .system)
        addButton.setTitle("+", for: .normal)
        addButton.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        addButton.setTitleColor(.white, for: .normal)
        addButton.addTarget(self, action: #selector(showTopUpViewController), for: .touchUpInside)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(addButton)
        
        // Balance label
        let balanceLabel = UILabel()
        balanceLabel.text = "YOUR BALANCE:"
        balanceLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        balanceLabel.textColor = .white
        balanceLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(balanceLabel)
        
        // Amount label
        amountLabel.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        amountLabel.textColor = .white
        amountLabel.translatesAutoresizingMaskIntoConstraints = false
        amountLabel.text = wallet != nil ? String(format: "RM %.2f", wallet!.amount) : "Loading..."
        cardView.addSubview(amountLabel)
        
        // Transaction table view
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        // Constraints
        NSLayoutConstraint.activate([
            walletLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            walletLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            
            cardView.topAnchor.constraint(equalTo: walletLabel.bottomAnchor, constant: 10),
            cardView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            cardView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            cardView.heightAnchor.constraint(equalToConstant: 150),
            
            addButton.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 10),
            addButton.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 15),
            
            balanceLabel.topAnchor.constraint(equalTo: addButton.bottomAnchor, constant: 15),
            balanceLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 15),
            
            amountLabel.topAnchor.constraint(equalTo: balanceLabel.bottomAnchor, constant: 10),
            amountLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 15),
            
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

// MARK: - PaymentManagerDelegate

extension PaymentViewController: PaymentManagerDelegate {
    func transactionDidFetch(_ transactionModels: [TransactionModel]) {
        transactions = transactionModels
        guard transactions != nil else {
            print("Failed to fetch transactions.")
            return
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

// MARK: - UITableViewDataSource

extension PaymentViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactions?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let transactions = transactions, !transactions.isEmpty {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionCell", for: indexPath) as! TransactionTableViewCell
            let transaction = transactions[indexPath.row]
            cell.transactionDateLabel.text = transaction.date
            cell.transactionTypeLabel.text = transaction.type
            cell.amountLabel.textColor = transaction.type == "Top Up" ? .systemGreen : .systemRed
            cell.amountLabel.text = String(format: "RM %.2f", transaction.amount)
            return cell
        } else {
            let cell = UITableViewCell()
            cell.textLabel?.text = "No transactions available."
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.textColor = .darkGray
            return cell
        }
    }
}
