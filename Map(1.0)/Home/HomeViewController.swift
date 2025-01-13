//
//  HomeViewController.swift
//  Map(1.0)
//
//  Created by Wei Kang Tan on 22/11/2024.
//

import UIKit

class HomeViewController: UIViewController {
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = .systemBackground
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    // Header View with Wallet
    private let headerView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    private let emptySessionView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let emptySessionImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "car.circle")
        imageView.tintColor = .systemGray3
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let emptySessionLabel: UILabel = {
        let label = UILabel()
        label.text = "No Active Sessions"
        label.font = .systemFont(ofSize: 16)
        label.textColor = .systemGray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var activeSessions: [ParkingSession] = []
    private var wallet: WalletData?
    
    private let quickActions = [
        ("Parking", "Find spots", "mappin.circle.fill"),
        ("Scan QR", "Quick park", "qrcode.viewfinder"),
        ("Vehicles", "Manage cars", "car.fill"),
        ("Fines", "View & pay", "doc.text.fill"),
        ("Report", "Submit issue", "exclamationmark.triangle.fill"),
        ("History", "Past sessions", "clock.fill")
    ]
    
    let homeManager = HomeManager()
    let paymentManager = PaymentManager()
    let balanceLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        homeManager.delegate = self
        navigationController?.navigationBar.tintColor = .white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        homeManager.getSessionStart()
        getWalletAmount()
        setupNavigationBar()
    }
    
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        setupTableView()
        setupHeaderView()
    }
    
    
    private func setupTableView() {
        view.addSubview(tableView)
        
        // Register cells
        tableView.register(ActiveSessionCell.self, forCellReuseIdentifier: "ActiveSessionCell")
        tableView.register(QuickActionCell.self, forCellReuseIdentifier: "QuickActionCell")
        tableView.register(RecentActivityCell.self, forCellReuseIdentifier: "RecentActivityCell")
        
        tableView.delegate = self
        tableView.dataSource = self
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupNavigationBar() {
        if let navigationBar = navigationController?.navigationBar {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .black
            appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
            navigationBar.prefersLargeTitles = true
            navigationBar.standardAppearance = appearance
            navigationBar.scrollEdgeAppearance = appearance
            navigationBar.compactAppearance = appearance
            
            // Set regular title
            title = "ZipPark"
            
            // Create logo image view
            let logoImageView = UIImageView(image: UIImage(named: "white_logo")) // Replace with your logo image name
            logoImageView.contentMode = .scaleAspectFit
            logoImageView.widthAnchor.constraint(equalToConstant: 50).isActive = true
            logoImageView.heightAnchor.constraint(equalToConstant: 50).isActive = true
            
            // Create left bar button item with logo
            let leftBarItem = UIBarButtonItem(customView: logoImageView)
            navigationItem.leftBarButtonItem = leftBarItem
            
            // Add profile button to right side
            let profileButton = UIBarButtonItem(
                image: UIImage(systemName: "person.circle"),
                style: .plain,
                target: self,
                action: #selector(profileButtonTapped)
            )
            
            profileButton.tintColor = .white
            navigationItem.rightBarButtonItem = profileButton
        }
    }
    
    @objc private func profileButtonTapped() {
        // Handle profile button tap
        let profileVC = ProfileViewController() // Create your profile view controller
        navigationController?.pushViewController(profileVC, animated: true)
    }
    
    private func setupHeaderView() {
        // Set header height
        let headerHeight: CGFloat = 150
        headerView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: headerHeight)
        
        // Add wallet card
        let walletCard = createWalletCard()
        headerView.addSubview(walletCard)
        
        // Set as table header view
        tableView.tableHeaderView = headerView
    }
    
    func getWalletAmount() {
        Task {
            guard let wallet = await paymentManager.getWallet() else {
                balanceLabel.text = "RM --,--.--"
                return
            }
            self.wallet = wallet
            // Update the UI on the main thread after fetching wallet data
            DispatchQueue.main.async {
                let formattedBalance = String(format: "RM %.2f", wallet.amount)
                self.balanceLabel.text = formattedBalance
            }
        }
    }
    private func createWalletCard() -> UIView {
        let card = UIView()
        card.backgroundColor = .black
        card.layer.cornerRadius = 12
        card.layer.borderWidth = 1
        card.layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor // Add subtle border
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOffset = CGSize(width: 0, height: 2)
        card.layer.shadowRadius = 6
        card.layer.shadowOpacity = 0.1
        card.translatesAutoresizingMaskIntoConstraints = false
        
        // Title Label
        let titleLabel = UILabel()
        titleLabel.text = "Wallet Balance"
        titleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        titleLabel.textColor = .systemGray
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Balance Label
        balanceLabel.text = "RM --.--"
        balanceLabel.font = .systemFont(ofSize: 28, weight: .bold)
        balanceLabel.textColor = .white
        balanceLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Buttons Stack View
        let buttonsStackView = UIStackView()
        buttonsStackView.axis = .horizontal
        buttonsStackView.spacing = 12
        buttonsStackView.distribution = .fillEqually
        buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Transaction Button
        let transactionButton = UIButton(type: .system)
        transactionButton.setTitle("Transaction", for: .normal)
        transactionButton.setImage(UIImage(systemName: "arrow.left.arrow.right"), for: .normal)
        transactionButton.tintColor = .black
        transactionButton.backgroundColor = .white
        transactionButton.layer.cornerRadius = 8
        transactionButton.layer.borderWidth = 1
        transactionButton.layer.borderColor = UIColor.systemBlue.cgColor
        transactionButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        transactionButton.addTarget(self, action: #selector(transactionButtonTapped), for: .touchUpInside)
        
        // Top Up Button
        let topUpButton = UIButton(type: .system)
        topUpButton.setTitle("Top Up", for: .normal)
        topUpButton.setImage(UIImage(systemName: "plus"), for: .normal)
        topUpButton.tintColor = .black
        topUpButton.backgroundColor = .white
        topUpButton.layer.cornerRadius = 8
        topUpButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        topUpButton.addTarget(self, action: #selector(topUpButtonTapped), for: .touchUpInside)
        
        // Add buttons to stack view
        buttonsStackView.addArrangedSubview(transactionButton)
        buttonsStackView.addArrangedSubview(topUpButton)
        
        headerView.addSubview(card)
        // Add subviews
        card.addSubview(titleLabel)
        card.addSubview(balanceLabel)
        card.addSubview(buttonsStackView)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            card.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 8),
            card.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            card.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -16),
            card.heightAnchor.constraint(equalToConstant: 140), // Increased height
            
            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            
            balanceLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            balanceLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            
            // Position buttons at the bottom of the card
            buttonsStackView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            buttonsStackView.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            buttonsStackView.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16),
            buttonsStackView.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        return card
    }
    
    // Add the new top up button action
    @objc private func topUpButtonTapped() {
        print("Top Up button tapped")
        let vc = TopUpViewController()
        guard let wallet = wallet else {
            return
        }
        vc.walletAmount = String(wallet.amount)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // Add the new top up button action
    @objc private func transactionButtonTapped() {
        print("Transaction button tapped")
        let vc = TransactionViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3 // Active Sessions, Quick Actions, Recent Activity
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1 // Quick actions grid
        case 1: return activeSessions.isEmpty ? 1 : activeSessions.count
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "QuickActionCell", for: indexPath) as! QuickActionCell
            cell.delegate = self
            cell.configure(with: quickActions)
            return cell
        case 1:
            if activeSessions.isEmpty {
                let cell = UITableViewCell(style: .default, reuseIdentifier: "EmptyCell")
                cell.contentView.addSubview(emptySessionView)
                emptySessionView.addSubview(emptySessionImageView)
                emptySessionView.addSubview(emptySessionLabel)
                
                NSLayoutConstraint.activate([
                    emptySessionView.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 8),
                    emptySessionView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16),
                    emptySessionView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16),
                    emptySessionView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -8),
                    
                    emptySessionImageView.centerXAnchor.constraint(equalTo: emptySessionView.centerXAnchor),
                    emptySessionImageView.topAnchor.constraint(equalTo: emptySessionView.topAnchor, constant: 16),
                    emptySessionImageView.widthAnchor.constraint(equalToConstant: 50),
                    emptySessionImageView.heightAnchor.constraint(equalToConstant: 50),
                    
                    emptySessionLabel.topAnchor.constraint(equalTo: emptySessionImageView.bottomAnchor, constant: 8),
                    emptySessionLabel.centerXAnchor.constraint(equalTo: emptySessionView.centerXAnchor),
                    emptySessionLabel.bottomAnchor.constraint(equalTo: emptySessionView.bottomAnchor, constant: -16)
                ])
                
                cell.selectionStyle = .none
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ActiveSessionCell", for: indexPath) as! ActiveSessionCell
                let session = activeSessions[indexPath.row]
                cell.configure(parkingSession: session)
                return cell
            }
            
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Active Sessions"
        case 1: return "Quick Actions"
        default: return nil
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 && !activeSessions.isEmpty { // Section 1 is Active Sessions section
            let session = activeSessions[indexPath.row]
            let detailVC = ParkingSessionDetailViewController(session: session)
            // Push the detail view controller
            navigationController?.pushViewController(detailVC, animated: true)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension HomeViewController: QuickActionCellDelegate {
    func didTapQuickAction(at index: Int) {
        switch index {
        case 0: // Find Parking
            let mapVC = MapViewController()
            navigationController?.pushViewController(mapVC, animated: true)
            
        case 1: // Scan QR
            let scannerVC = QRCodeScannerViewController()
            scannerVC.delegate = self
            scannerVC.modalPresentationStyle = .fullScreen
            present(scannerVC, animated: true)
            
        case 2: // Vehicles
            let vehicleVC = VehicleViewController()
            navigationController?.pushViewController(vehicleVC, animated: true)
            
        case 3: // Fines
            // Present fines view controller
            break
            
        case 4: // Report
            let reportVC = ReportSystemViewController()
            navigationController?.pushViewController(reportVC, animated: true)
            break
            
        case 5: // History
            let historyVC = HistoryViewController()
            navigationController?.pushViewController(historyVC, animated: true)
            break
            
        default:
            break
        }
    }
}

extension HomeViewController: QRCodeScannerViewControllerDelegate {
    func didFailToScanQR(_ error: any Error) {
        print("fail")
    }
    
    func didScanQR(_ parkingSpotModel: ParkingSpotModel) {
        DispatchQueue.main.async {
            let detailsVC = ParkingSpotDetailsViewController()
            detailsVC.parkingSpotModel = parkingSpotModel
            self.navigationController?.pushViewController(detailsVC, animated: true)
        }
    }
}

extension HomeViewController: HomeManagerDelegate {
    func didFetchSession(_ parkingSessions: [ParkingSession]) {
        activeSessions = parkingSessions
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

#Preview {
    HomeViewController()
}
