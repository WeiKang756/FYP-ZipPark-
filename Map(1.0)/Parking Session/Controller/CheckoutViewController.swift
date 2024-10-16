//
//  SimplifiedCheckoutViewController.swift
//  Map(1.0)
//
//  Created by Wei Kang Tan on 19/11/2024.
//


import UIKit

class CheckoutViewController: UIViewController {
    // MARK: - UI Components
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let headerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemYellow // Changes based on parking type
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Checkout"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Review your parking details"
        label.font = .systemFont(ofSize: 16)
        label.textColor = .white.withAlphaComponent(0.8)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let locationCard = CardView()
    private let timeCard = CardView()
    private let paymentCard = CardView()
    private let walletCard = CardView()
    
    private let confirmButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Confirm Payment", for: .normal)
        button.backgroundColor = .systemYellow
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Dummy Data
    private let dummyData = (
        spotNumber: "123",
        location: "Api-Api Center, Kota Kinabalu",
        startTime: "2:30 PM",
        endTime: "4:30 PM",
        date: "Nov 19, 2024",
        duration: "2 hours",
        cost: 8.48,
        walletBalance: 50.00,
        parkingType: "disable"  // Can be: yellow, green, red, disable
    )
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        populateWithDummyData()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(headerView)
        headerView.addSubview(titleLabel)
        headerView.addSubview(subtitleLabel)
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        [locationCard, timeCard, paymentCard, walletCard].forEach { card in
            card.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(card)
        }
        
        view.addSubview(confirmButton)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Header
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 100),
            
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            titleLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 20),
            
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            
            // ScrollView
            scrollView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: confirmButton.topAnchor, constant: -20),
            
            // Content View
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Cards
            locationCard.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            locationCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            locationCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            timeCard.topAnchor.constraint(equalTo: locationCard.bottomAnchor, constant: 20),
            timeCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            timeCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            paymentCard.topAnchor.constraint(equalTo: timeCard.bottomAnchor, constant: 20),
            paymentCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            paymentCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            walletCard.topAnchor.constraint(equalTo: paymentCard.bottomAnchor, constant: 20),
            walletCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            walletCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            walletCard.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
            // Confirm Button
            confirmButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            confirmButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            confirmButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            confirmButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func populateWithDummyData() {
        // Set header color based on parking type
        switch dummyData.parkingType {
        case "yellow":
            headerView.backgroundColor = .systemYellow
        case "green":
            headerView.backgroundColor = .systemGreen
        case "red":
            headerView.backgroundColor = .systemRed
        case "disable":
            headerView.backgroundColor = .systemBlue
        default:
            headerView.backgroundColor = .systemBlue
        }
        
        setupLocationCard()
        setupTimeCard()
        setupPaymentCard()
        setupWalletCard()
    }
    
    private func setupLocationCard() {
        locationCard.configureCard(
            title: "Parking Location",
            iconName: "mappin.circle.fill",
            content: [
                InfoRow(title: "Spot #\(dummyData.spotNumber)"),
                InfoRow(title: dummyData.location, style: .subtitle)
            ]
        )
    }
    
    private func setupTimeCard() {
        timeCard.configureCard(
            title: "Duration & Time",
            iconName: "clock.fill",
            content: [
                GridRow(
                    left: InfoRow(title: "Start Time", value: dummyData.startTime),
                    right: InfoRow(title: "End Time", value: dummyData.endTime)
                ),
                GridRow(
                    left: InfoRow(title: "Date", value: dummyData.date),
                    right: InfoRow(title: "Duration", value: dummyData.duration)
                )
            ]
        )
    }
    
    private func setupPaymentCard() {
        if dummyData.parkingType == "yellow" {
            setupYellowZonePayment()
        } else {
            setupStandardPayment()
        }
    }
    
    private func setupYellowZonePayment() {
        paymentCard.configureCard(
            title: "Payment Details",
            iconName: "creditcard.fill",
            content: [
                Section(
                    title: "First 4 Hours",
                    rows: [
                        InfoRow(title: "Rate", value: "RM 0.53/30min"),
                        InfoRow(title: "Duration", value: "4 hours"),
                        InfoRow(title: "Cost", value: "RM 4.24")
                    ]
                ),
                Divider(),
                Section(
                    title: "After 4 Hours",
                    rows: [
                        InfoRow(title: "Rate", value: "RM 1.06/30min"),
                        InfoRow(title: "Duration", value: "2 hours"),
                        InfoRow(title: "Cost", value: "RM 4.24")
                    ]
                ),
                Divider(),
                InfoRow(title: "Total Cost", value: "RM 8.48", style: .total)
            ]
        )
    }
    
    private func setupStandardPayment() {
        paymentCard.configureCard(
            title: "Payment Details",
            iconName: "creditcard.fill",
            content: [
                InfoRow(title: "Parking Rate", value: "RM 0.53/hour"),
                InfoRow(title: "Duration Cost", value: String(format: "RM %.2f", dummyData.cost)),
                Divider(),
                InfoRow(title: "Total Cost", value: String(format: "RM %.2f", dummyData.cost), style: .total)
            ]
        )
    }
    
    private func setupWalletCard() {
        walletCard.configureCard(
            title: "Wallet Balance",
            iconName: "wallet.pass.fill",
            content: [
                InfoRow(
                    title: String(format: "RM %.2f", dummyData.walletBalance),
                    style: .balance
                )
            ]
        )
    }
}

#Preview {
    CheckoutViewController()
}
