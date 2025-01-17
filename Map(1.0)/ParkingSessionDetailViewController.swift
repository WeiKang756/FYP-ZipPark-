import UIKit

class ParkingSessionDetailViewController: UIViewController {
    
    // MARK: - UI Components
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .systemGray6
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let extendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Extend Session", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let sessionCard = DetailCard()
    private let locationCard = DetailCard()
    private let vehicleCard = DetailCard()
    private let paymentCard = DetailCard()
    
    // MARK: - Properties
    private var dummySession: ParkingSession? = nil
    private let parkingSessionManager = ParkingSessionManager()
    private let sessionManager = SessionExtensionManager()
    
    // MARK: - Lifecycle
    init(session: ParkingSession) {
        self.dummySession = session
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureCards()
        navigationItem.title = "Session Detail"
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .never
        parkingSessionManager.delegate = self
        sessionManager.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateExtendButtonState()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        title = "Session Details"
        view.backgroundColor = .systemBackground
        
        setupExtendButton()
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        [sessionCard, locationCard, vehicleCard, paymentCard].forEach { card in
            contentView.addSubview(card)
        }
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: extendButton.topAnchor, constant: -20),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            sessionCard.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            sessionCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            sessionCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            locationCard.topAnchor.constraint(equalTo: sessionCard.bottomAnchor, constant: 16),
            locationCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            locationCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            vehicleCard.topAnchor.constraint(equalTo: locationCard.bottomAnchor, constant: 16),
            vehicleCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            vehicleCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            paymentCard.topAnchor.constraint(equalTo: vehicleCard.bottomAnchor, constant: 16),
            paymentCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            paymentCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            paymentCard.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupExtendButton() {
        view.addSubview(extendButton)
        
        NSLayoutConstraint.activate([
            extendButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            extendButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            extendButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            extendButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        extendButton.addTarget(self, action: #selector(extendButtonTapped), for: .touchUpInside)
    }
    
    private func updateExtendButtonState() {
        guard let parkingSession = dummySession else { return }
        
        let endTime = DateFormatterUtility.shared.dateFromString(parkingSession.endTime)
        let isExpired = endTime?.compare(Date()) == .orderedAscending
        
        extendButton.isEnabled = !isExpired && parkingSession.status == "active"
        extendButton.backgroundColor = isExpired || parkingSession.status != "active" ? .systemGray3 : .systemBlue
        
        if isExpired {
            extendButton.setTitle("Session Expired", for: .disabled)
        } else if parkingSession.status != "active" {
            extendButton.setTitle("Session Inactive", for: .disabled)
        } else {
            extendButton.setTitle("Extend Session", for: .normal)
        }
    }
    
    // MARK: - Actions
    @objc private func extendButtonTapped() {
        guard let parkingSession = dummySession else { return }
        let vc = SessionExtensionViewController(parkingType: parkingSession.parkingSpot.type)
        vc.delegate = self
        present(vc, animated: true)
    }
    
    // MARK: - Helpers
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSSSSSZZZZZ"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()
    
    private func formatTime(_ timeString: String) -> String {
        if let date = timeFormatter.date(from: timeString) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "h:mm a"
            return outputFormatter.string(from: date)
        }
        return timeString
    }
    
    private func formatDuration(_ durationString: String) -> String {
        let components = durationString.split(separator: ":")
        if components.count == 3 {
            let hours = Int(components[0]) ?? 0
            let minutes = Int(components[1]) ?? 0
            return "\(hours)h \(minutes)m"
        }
        return durationString
    }
    
    private func configureCards() {
        guard let dummySession = dummySession else { return }
        
        sessionCard.configure(
            title: "Session Information",
            icon: "clock.fill",
            content: [
                DetailRow(title: "Status", value: dummySession.status.uppercased(), valueColor: dummySession.status == "active" ? .systemGreen : .systemGray),
                DetailRow(title: "Date", value: dummySession.date),
                DetailRow(title: "Start Time", value: formatTime(dummySession.startTime)),
                DetailRow(title: "End Time", value: DateFormatterUtility.shared.formatDate(dummySession.endTime, to: .time)),
                DetailRow(title: "Duration", value: formatDuration(dummySession.duration))
            ]
        )
        
        locationCard.configure(
            title: "Location",
            icon: "mappin.circle.fill",
            content: [
                DetailRow(title: "Area", value: dummySession.parkingSpot.street.area.areaName),
                DetailRow(title: "Street", value: dummySession.parkingSpot.street.streetName),
                DetailRow(title: "Spot", value: "#\(dummySession.parkingSpot.parkingSpotID)"),
                DetailRow(title: "Zone Type", value: dummySession.parkingSpot.type.capitalized)
            ]
        )
        
        vehicleCard.configure(
            title: "Vehicle Information",
            icon: "car.fill",
            content: [
                DetailRow(title: "Plate Number", value: dummySession.plateNumber)
            ]
        )
        
        paymentCard.configure(
            title: "Payment Information",
            icon: "creditcard.fill",
            content: [
                DetailRow(title: "Rate", value: dummySession.parkingSpot.type == "green" ? "RM 0.53/hour" : "RM 0.53/30min"),
                DetailRow(title: "Total Amount", value: String(format: "RM %.2f", dummySession.totalCost))
            ]
        )
    }
}

// MARK: - Extensions
extension ParkingSessionDetailViewController {
    func showErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func showSuccessAlert(message: String) {
        let alert = UIAlertController(
            title: "Success",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func updateSessionDetails() {
        guard let sessionId = dummySession?.id else { return }
        guard let sessionUUID = UUID(uuidString: sessionId) else {
            print("Invalid session ID format")
            return
        }
        parkingSessionManager.getSessionStart(sessionUUID)
    }
}

extension ParkingSessionDetailViewController: ParkingSessionManagerDelegate {
    func didFetchSession(_ parkingSession: ParkingSession) {
        dummySession = parkingSession
        DispatchQueue.main.async {
            self.configureCards()
            self.updateExtendButtonState()
        }
    }
}

extension ParkingSessionDetailViewController: SessionExtensionViewControllerDelegate {
    func didSelectExtension(duration: String, estimatedCost: Double) {
        guard let sessionId = dummySession?.id else { return }
        guard let sessionUUID = UUID(uuidString: sessionId) else {
            print("Invalid session ID format")
            return
        }
        sessionManager.extendSession(
            sessionId: sessionUUID,
            additionalTime: duration,
            estimatedCost: estimatedCost
        )
    }
}

extension ParkingSessionDetailViewController: SessionExtensionManagerDelegate {
    func failedToExtendSession(_ error: SessionExtensionError) {
        DispatchQueue.main.async {
            self.showErrorAlert(message: error.message)
        }
    }
    
    func didExtendSession(_ response: SessionExtensionResponse) {
        DispatchQueue.main.async {
            self.updateSessionDetails()
            self.showSuccessAlert(message: "Session extended successfully")
        }
    }
}

class DetailCard: UIView {
    private let titleStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .black
        imageView.widthAnchor.constraint(equalToConstant: 24).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 24).isActive = true
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .white
        layer.cornerRadius = 12
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowRadius = 5
        layer.shadowOffset = CGSize(width: 0, height: 2)
        translatesAutoresizingMaskIntoConstraints = false
        
        titleStack.addArrangedSubview(iconImageView)
        titleStack.addArrangedSubview(titleLabel)
        
        addSubview(titleStack)
        addSubview(contentStack)
        
        NSLayoutConstraint.activate([
            titleStack.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            titleStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            contentStack.topAnchor.constraint(equalTo: titleStack.bottomAnchor, constant: 16),
            contentStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            contentStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }
    
    func configure(title: String, icon: String, content: [DetailRow]) {
        titleLabel.text = title
        iconImageView.image = UIImage(systemName: icon)
        
        contentStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        content.forEach { row in
            let rowView = createDetailRow(row)
            contentStack.addArrangedSubview(rowView)
        }
    }
    
    private func createDetailRow(_ row: DetailRow) -> UIView {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        
        let titleLabel = UILabel()
        titleLabel.text = row.title
        titleLabel.font = row.isSecondary ? .systemFont(ofSize: 14) : .systemFont(ofSize: 16)
        titleLabel.textColor = row.isSecondary ? .systemGray : .label
        
        let valueLabel = UILabel()
        valueLabel.text = row.value
        valueLabel.textAlignment = .right
        valueLabel.font = .systemFont(ofSize: 16)
        valueLabel.textColor = row.valueColor ?? .label
        
        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(valueLabel)
        
        return stack
    }
}

struct DetailRow {
    let title: String
    let value: String
    let isSecondary: Bool
    let valueColor: UIColor?
    
    init(title: String, value: String, isSecondary: Bool = false, valueColor: UIColor? = nil) {
        self.title = title
        self.value = value
        self.isSecondary = isSecondary
        self.valueColor = valueColor
    }
}
