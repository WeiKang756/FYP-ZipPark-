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
    private let vehicleCard = CardView()
    
    private let confirmButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Confirm Payment", for: .normal)
        button.backgroundColor = .systemYellow
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
        return button
    }()
    
    
    private let selectedVehicle: VehicleModel
    private let parkingSpotModel: ParkingSpotModel
    private let parkingCostModel: ParkingCostModel
    private let sessionManager = SessionManager()
    
    init(parkingSpotModel: ParkingSpotModel, selectedVehicle: VehicleModel, parkingCostModel: ParkingCostModel) {
        self.parkingSpotModel = parkingSpotModel
        self.selectedVehicle = selectedVehicle
        self.parkingCostModel = parkingCostModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        populateWithData()
        sessionManager.delegate = self
        navigationItem.title = "Checkout"
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .never
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(headerView)
        headerView.addSubview(titleLabel)
        headerView.addSubview(subtitleLabel)
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        [locationCard, vehicleCard, timeCard, paymentCard, walletCard].forEach { card in
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
            
            vehicleCard.topAnchor.constraint(equalTo: locationCard.bottomAnchor, constant: 20),
            vehicleCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            vehicleCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            // Update timeCard's top anchor to be relative to vehicleCard:
            timeCard.topAnchor.constraint(equalTo: vehicleCard.bottomAnchor, constant: 20),
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
    
    private func populateWithData() {
        // Set header color based on parking type
        switch parkingSpotModel.type {
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
        setupVehicleCard()
        setupTimeCard()
        setupPaymentCard()
        setupWalletCard()
    }
    
    private func setupLocationCard() {
        locationCard.configureCard(
            title: "Parking Location",
            iconName: "mappin.circle.fill",
            content: [
                InfoRow(title: "Spot: \(parkingSpotModel.parkingSpotID)"),
                InfoRow(title: "\(parkingSpotModel.areaName), \(parkingSpotModel.streetName)", style: .subtitle)
            ]
        )
    }
    
    private func setupVehicleCard() {
        vehicleCard.configureCard(
            title: "Vehicle Information",
            iconName: "car.fill",
            content: [
                GridRow(
                    left: InfoRow(title: "Plate Number", value: selectedVehicle.plateNumber),
                    right: InfoRow(title: "Color", value: selectedVehicle.color)
                ),
                InfoRow(title: "Model", value: selectedVehicle.description, style: .subtitle)
            ]
        )
    }
    
    private func setupTimeCard() {
        timeCard.configureCard(
            title: "Duration & Time",
            iconName: "clock.fill",
            content: [
                GridRow(
                    left: InfoRow(title: "Start Time", value: parkingCostModel.startTime),
                    right: InfoRow(title: "End Time", value: parkingCostModel.endTime)
                ),
                GridRow(
                    left: InfoRow(title: "Date", value: parkingCostModel.date),
                    right: InfoRow(title: "Duration", value: parkingCostModel.duration)
                )
            ]
        )
    }
    
    private func setupPaymentCard() {
        switch parkingSpotModel.type {
        case "green":
            setupStandardPayment()
        case "yellow":
            setupYellowZonePayment()
        case "red":
            setupRedZonePayment()
        case "disable":
            setupDisablePayment()
        default:
            break
        }
    }
    
    private func setupRedZonePayment() {
        if let secondPeriodCost = parkingCostModel.secondPeriodCost, let secondPeriodDuration = parkingCostModel.secondPeriodDuration {
            paymentCard.configureCard(
                title: "Payment Details",
                iconName: "creditcard.fill",
                content: [
                    Section(
                        title: "First Hours",
                        rows: [
                            InfoRow(title: "Rate", value: "RM 1.06/30min"),
                            InfoRow(title: "Duration", value: parkingCostModel.firstPeriodDuration),
                            InfoRow(title: "Cost", value: String(format: "RM %.2f", parkingCostModel.firstPeriodCost))
                        ]
                    ),
                    Divider(),
                    Section(
                        title: "After 4 Hours",
                        rows: [
                            InfoRow(title: "Rate", value: "RM 2.13/30min"),
                            InfoRow(title: "Duration", value: secondPeriodDuration),
                            InfoRow(title: "Cost", value: String(format: "RM %.2f", secondPeriodCost))
                        ]
                    ),
                    Divider(),
                    InfoRow(title: "Total Cost", value: String(format: "RM %.2f", parkingCostModel.totalCost), style: .total)
                ]
            )
        }else {
            paymentCard.configureCard(
                title: "Payment Details",
                iconName: "creditcard.fill",
                content: [
                    InfoRow(title: "Parking Rate", value: "RM 1.06/30 minutes"),
                    InfoRow(title: "Duration Cost", value: String(format: "RM %.2f", parkingCostModel.firstPeriodCost)),
                    Divider(),
                    InfoRow(title: "Total Cost", value: String(format: "RM %.2f", parkingCostModel.totalCost), style: .total)
                ]
            )
        }
    }
    
    private func setupYellowZonePayment() {
        if let secondPeriodCost = parkingCostModel.secondPeriodCost, let secondPeriodDuration = parkingCostModel.secondPeriodDuration {
            paymentCard.configureCard(
                title: "Payment Details",
                iconName: "creditcard.fill",
                content: [
                    Section(
                        title: "First 4 Hours",
                        rows: [
                            InfoRow(title: "Rate", value: "RM 0.53/30min"),
                            InfoRow(title: "Duration", value: parkingCostModel.firstPeriodDuration),
                            InfoRow(title: "Cost", value: String(format: "RM %.2f", parkingCostModel.firstPeriodCost))
                        ]
                    ),
                    Divider(),
                    Section(
                        title: "After 4 Hours",
                        rows: [
                            InfoRow(title: "Rate", value: "RM 1.06/30min"),
                            InfoRow(title: "Duration", value: secondPeriodDuration),
                            InfoRow(title: "Cost", value: String(format: "RM %.2f", secondPeriodCost))
                        ]
                    ),
                    Divider(),
                    InfoRow(title: "Total Cost", value: String(format: "RM %.2f", parkingCostModel.totalCost), style: .total)
                ]
            )
        }else {
            paymentCard.configureCard(
                title: "Payment Details",
                iconName: "creditcard.fill",
                content: [
                    InfoRow(title: "Parking Rate", value: "RM 0.53/30 minutes"),
                    InfoRow(title: "Duration Cost", value: String(format: "RM %.2f", parkingCostModel.firstPeriodCost)),
                    Divider(),
                    InfoRow(title: "Total Cost", value: String(format: "RM %.2f", parkingCostModel.totalCost), style: .total)
                ]
            )
        }
    }
    
    private func setupStandardPayment() {
        paymentCard.configureCard(
            title: "Payment Details",
            iconName: "creditcard.fill",
            content: [
                InfoRow(title: "Parking Rate", value: "RM 0.53/hour"),
                InfoRow(title: "Duration Cost", value: String(format: "RM %.2f", parkingCostModel.totalCost)),
                Divider(),
                InfoRow(title: "Total Cost", value: String(format: "RM %.2f", parkingCostModel.totalCost), style: .total)
            ]
        )
    }
    
    private func setupDisablePayment() {
        paymentCard.configureCard(
            title: "Payment Details",
            iconName: "creditcard.fill",
            content: [
                InfoRow(title: "Parking Rate", value: "FOC"),
                InfoRow(title: "Duration Cost", value: String(format: "RM %.2f", parkingCostModel.totalCost)),
                Divider(),
                InfoRow(title: "Total Cost", value: String(format: "RM %.2f", parkingCostModel.totalCost), style: .total)
            ]
        )
    }
    
    private func setupWalletCard() {
        walletCard.configureCard(
            title: "Wallet Balance",
            iconName: "wallet.pass.fill",
            content: [
                InfoRow(
                    title: String(format: "RM %.2f", parkingCostModel.wallet),
                    style: .balance
                )
            ]
        )
    }
    
    //MARK: - Action
    
    @objc private func confirmButtonTapped() {
        sessionManager.startSession(parkingCostModel: parkingCostModel, parkingSpotModel: parkingSpotModel, vehicleModel: selectedVehicle)
        print("confirm button tapped")
    }
    
    func showErrorAlert(on viewController: UIViewController, title: String = "Error", message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        viewController.present(alertController, animated: true, completion: nil)
    }
}

extension CheckoutViewController: SessionManagerDelegate {
    func didStartSession(_ session: SessionResponse, _ parkingSpotModel: ParkingSpotModel, _ vehicleModel: VehicleModel) {
        DispatchQueue.main.async{
            let vc = ParkingSessionSuccessViewController(sessionResponse: session, vehicleModel: vehicleModel, parkingSpotModel: parkingSpotModel)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func failTostartSession(_ error: String) {
        DispatchQueue.main.async {
            self.showErrorAlert(on: self, message: error)
        }
    }
}
