import UIKit

class ParkingSessionSuccessViewController: UIViewController, ParkingSessionManagerDelegate {
    func didFetchSession(_ parkingSession: ParkingSession) {

        // Initialize the ParkingSessionDetailViewController
        let vc = ParkingSessionDetailViewController(session: parkingSession)
        
        DispatchQueue.main.async {
            // Clear the stack except the root view controller
            if let rootVC = self.navigationController?.viewControllers.first {
                self.navigationController?.setViewControllers([rootVC, vc], animated: true)
            } else {
                print("No root view controller found in the navigation stack.")
            }
        }
    }

    
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
        view.backgroundColor = .systemGreen
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let successImageView: UIImageView = {
        let config = UIImage.SymbolConfiguration(pointSize: 60, weight: .regular)
        let image = UIImage(systemName: "checkmark.circle.fill", withConfiguration: config)
        let imageView = UIImageView(image: image)
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Session Started!"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Your parking session has been confirmed"
        label.font = .systemFont(ofSize: 16)
        label.textColor = .white.withAlphaComponent(0.8)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let locationCard = CardView()
    private let vehicleCard = CardView()
    private let timeCard = CardView()
    private let paymentCard = CardView()
    
    private let viewSessionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("View Active Session", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemGreen
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.layer.cornerRadius = 12
        button.addTarget(self, action: #selector(viewButtonPressed), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let backToHomeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Back to Home", for: .normal)
        button.setTitleColor(.systemGray, for: .normal)
        button.backgroundColor = .systemGray6
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.layer.cornerRadius = 12
        button.addTarget(self, action: #selector(backToHomePressed), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let sessionResponse: SessionResponse
    private let vehicleModel: VehicleModel
    private let parkingSpotModel: ParkingSpotModel
    
    init(sessionResponse: SessionResponse, vehicleModel: VehicleModel, parkingSpotModel: ParkingSpotModel) {
        self.sessionResponse = sessionResponse
        self.vehicleModel = vehicleModel
        self.parkingSpotModel = parkingSpotModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupDummyData()
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(headerView)
        headerView.addSubview(successImageView)
        headerView.addSubview(titleLabel)
        headerView.addSubview(subtitleLabel)
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        [locationCard, vehicleCard, timeCard, paymentCard].forEach { card in
            card.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(card)
        }
        
        view.addSubview(viewSessionButton)
        view.addSubview(backToHomeButton)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Header
            headerView.topAnchor.constraint(equalTo: view.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 220),
            
            successImageView.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            successImageView.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 60),
            successImageView.widthAnchor.constraint(equalToConstant: 60),
            successImageView.heightAnchor.constraint(equalToConstant: 60),
            
            titleLabel.topAnchor.constraint(equalTo: successImageView.bottomAnchor, constant: 16),
            titleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            
            // ScrollView
            scrollView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: viewSessionButton.topAnchor, constant: -20),
            
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
            
            timeCard.topAnchor.constraint(equalTo: vehicleCard.bottomAnchor, constant: 20),
            timeCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            timeCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            paymentCard.topAnchor.constraint(equalTo: timeCard.bottomAnchor, constant: 20),
            paymentCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            paymentCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            paymentCard.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
            // Buttons
            viewSessionButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            viewSessionButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            viewSessionButton.bottomAnchor.constraint(equalTo: backToHomeButton.topAnchor, constant: -12),
            viewSessionButton.heightAnchor.constraint(equalToConstant: 50),
            
            backToHomeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            backToHomeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            backToHomeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            backToHomeButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupDummyData() {
        // Location Card
        locationCard.configureCard(
            title: "Parking Location",
            iconName: "mappin.circle.fill",
            content: [
                InfoRow(title: "Spot: \(parkingSpotModel.parkingSpotID)"),
                InfoRow(title: "\(parkingSpotModel.areaName), \(parkingSpotModel.streetName)", style: .subtitle)
            ]
        )
        
        // Vehicle Card
        vehicleCard.configureCard(
            title: "Vehicle Details",
            iconName: "car.fill",
            content: [
                GridRow(
                    left: InfoRow(title: "Plate Number", value: "\(vehicleModel.plateNumber)"),
                    right: InfoRow(title: "Color", value: "\(vehicleModel.color)")
                ),
                InfoRow(title: "Model", value: "\(vehicleModel.description)", style: .subtitle)
            ]
        )
        
        // Time Card
        guard let data = sessionResponse.data else {return}
        timeCard.configureCard(
            title: "Session Time",
            iconName: "clock.fill",
            content: [
                GridRow(
                    left: InfoRow(title: "Start Time", value: DateFormatterUtility.shared.formatDate(data.startTime, to: .time)),
                    right: InfoRow(title: "End Time", value: DateFormatterUtility.shared.formatDate(data.endTime, to: .time))
                ),
                GridRow(
                    left: InfoRow(title: "Date", value: data.date),
                    right: InfoRow(title: "Duration", value: DateFormatterUtility.shared.formatDuration(data.duration))
                )
            ]
        )
        
        // Payment Card
        paymentCard.configureCard(
            title: "Payment Summary",
            iconName: "creditcard.fill",
            content: [
                InfoRow(title: "Parking Fee", value: "\(data.cost)"),
                InfoRow(title: "Remaining Balance", value: "\(data.remainingBalance)", style: .balance),
                Divider()
            ]
        )
    }
    
    @objc func backToHomePressed() {
        // First, get to the root view controller of the current navigation stack
        navigationController?.popToRootViewController(animated: true)
    }
    
    @objc func viewButtonPressed() {
        // First, get to the root view controller of the current navigation stack
        let parkingSessionManger = ParkingSessionManager()
        parkingSessionManger.delegate = self
        guard let uuidString = sessionResponse.sessionId else {
            return
        }
        // Convert String to UUID
        if let uuid = UUID(uuidString: uuidString) {
            parkingSessionManger.getSessionStart(uuid)
        } else {
            print("Invalid UUID string")
        }
    }
}

