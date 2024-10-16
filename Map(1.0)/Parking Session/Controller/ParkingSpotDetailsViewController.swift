
import UIKit
import MapKit

class ParkingSpotDetailsViewController: UIViewController {
    
    // MARK: - Properties
    var parkingSpotModel: ParkingSpotModel?
    
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.separatorStyle = .none
        table.backgroundColor = .systemGray6
        return table
    }()
    
    private let headerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGreen
        return view
    }()
    
    private let locationLabel: UILabel = {
        let label = UILabel()
        label.text = "Kota Kinabalu"
        label.textColor = .white
        label.font = .systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let spotNumberLabel: UILabel = {
        let label = UILabel()
        label.text = "Spot #123"
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: 24)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let availabilityLabel: UILabel = {
        let label = UILabel()
        label.text = "Available Now"
        label.textColor = .white
        label.font = .systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let rateLabel: UILabel = {
        let label = UILabel()
        label.text = "RM 0.53"
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: 24)
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let rateDescriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "/30 min"
        label.textColor = .white
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let startParkingButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Start Parking", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 25
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.layer.shadowOpacity = 0.2
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let directionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "map"), for: .normal)
        button.backgroundColor = .white.withAlphaComponent(0.3)
        button.tintColor = .white
        button.layer.cornerRadius = 25
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.layer.shadowOpacity = 0.2
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let warningView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.2) // Semi-transparent white
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let warningIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "exclamationmark.triangle.fill")
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let warningLabel: UILabel = {
        let label = UILabel()
        label.text = "Maximum parking duration: 2 hours"
        label.textColor = .white
        label.font = .systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        guard let parkingSpotModel = parkingSpotModel else {
            print("fail to get parking spot data")
            return
        }
        
        navigationItem.title = "Spot Detail"
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .never
        
        locationLabel.text = parkingSpotModel.areaName
        
        if parkingSpotModel.isAvailable {
            availabilityLabel.text = "Available Now"
            availabilityLabel.textColor = .white
            updateStartParkingButtonState(isAvailable: true)
        } else {
            availabilityLabel.text = "Occupied"
            availabilityLabel.textColor = .white
            updateStartParkingButtonState(isAvailable: false)
        }
        
        switch parkingSpotModel.type {
        case "green":
            setupHeaderViewGreen()
            rateLabel.text = "RM 0.53"
            rateDescriptionLabel.text = "/ hour"
            startParkingButton.setTitleColor(.systemGreen, for: .normal)
            headerView.backgroundColor = .systemGreen
        case "red":
            setupHeaderView()
            showMaxParkingDurationWarning("2 hours")
            rateLabel.text = "RM 1.06"
            rateDescriptionLabel.text = "/1-2 30 min"
            startParkingButton.setTitleColor(.systemRed, for: .normal)
            headerView.backgroundColor = .systemRed
        case "yellow":
            setupHeaderView()
            showMaxParkingDurationWarning("8 hours")
            rateLabel.text = "RM 0.53"
            rateDescriptionLabel.text = "/1-8 30 min"
            startParkingButton.setTitleColor(.systemOrange, for: .normal)
            headerView.backgroundColor = .systemOrange
        case "disable":
            setupHeaderViewGreen()
            rateLabel.text = "FOC"
            rateDescriptionLabel.text = ""
            startParkingButton.setTitleColor(.systemBlue, for: .normal)
            headerView.backgroundColor = .systemBlue
        default:
            break
        }
        spotNumberLabel.text = "Parking Spot: \(parkingSpotModel.parkingSpotID)"
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemGray6
        view.addSubview(tableView)
        setupConstraints()
        startParkingButton.addTarget(self, action: #selector(startParkingTapped), for: .touchUpInside)
        directionButton.addTarget(self, action: #selector(directionButtonTapped), for: .touchUpInside)
    }
    
    @objc private func startParkingTapped() {
        guard let parkingSpotModel = self.parkingSpotModel, 
              parkingSpotModel.isAvailable else { return }
        
        // Scale down animation
        UIView.animate(withDuration: 0.1, animations: {
            self.startParkingButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            self.startParkingButton.alpha = 0.9
        }) { _ in
            // Scale back up
            UIView.animate(withDuration: 0.1) {
                self.startParkingButton.transform = .identity
                self.startParkingButton.alpha = 1.0
            }
            
            // Add haptic feedback
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            
            let vc = ParkingStartViewController(parkingSpotModel: parkingSpotModel)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    @objc private func directionButtonTapped() {
        // Scale down animation
        UIView.animate(withDuration: 0.1, animations: {
            self.directionButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            self.directionButton.alpha = 0.8
        }) { _ in
            // Scale back up
            UIView.animate(withDuration: 0.1) {
                self.directionButton.transform = .identity
                self.directionButton.alpha = 1.0
            }
            
            // Add haptic feedback
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            
            guard let parkingSpotModel = self.parkingSpotModel else {
                return
            }
            
            let location = CLLocationCoordinate2D(latitude: parkingSpotModel.latitude, longitude: parkingSpotModel.longitude)
            
            let placemark = MKPlacemark(coordinate: location)
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.openInMaps()
        }
    }
    
    private func setupHeaderViewGreen() {
        headerView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 180)
        
        headerView.addSubview(locationLabel)
        headerView.addSubview(spotNumberLabel)
        headerView.addSubview(availabilityLabel)
        headerView.addSubview(rateLabel)
        headerView.addSubview(rateDescriptionLabel)
        headerView.addSubview(startParkingButton)
        headerView.addSubview(directionButton)
        
        NSLayoutConstraint.activate([
            locationLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 16),
            locationLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            
            spotNumberLabel.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 8),
            spotNumberLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            
            availabilityLabel.topAnchor.constraint(equalTo: spotNumberLabel.bottomAnchor, constant: 8),
            availabilityLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            
            rateLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 16),
            rateLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            
            rateDescriptionLabel.topAnchor.constraint(equalTo: rateLabel.bottomAnchor, constant: 4),
            rateDescriptionLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            
            startParkingButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            startParkingButton.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -16),
            startParkingButton.heightAnchor.constraint(equalToConstant: 50),
            startParkingButton.trailingAnchor.constraint(equalTo: directionButton.leadingAnchor, constant: -16),
            
            directionButton.centerYAnchor.constraint(equalTo: startParkingButton.centerYAnchor),
            directionButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            directionButton.heightAnchor.constraint(equalToConstant: 50),
            directionButton.widthAnchor.constraint(equalToConstant: 50)
        ])
        
        tableView.tableHeaderView = headerView
    }
    
    // Add a method to show/hide the warning
    func showMaxParkingDurationWarning(_ duration: String) {
        warningLabel.text = "Maximum parking duration: \(duration)"
        warningView.isHidden = false
    }
    
    private func setupHeaderView() {
        headerView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 240)
        
        headerView.addSubview(locationLabel)
        headerView.addSubview(spotNumberLabel)
        headerView.addSubview(availabilityLabel)
        headerView.addSubview(rateLabel)
        headerView.addSubview(rateDescriptionLabel)
        headerView.addSubview(warningView)
        warningView.addSubview(warningIcon)
        warningView.addSubview(warningLabel)
        headerView.addSubview(startParkingButton)
        headerView.addSubview(directionButton)
        
        NSLayoutConstraint.activate([
            locationLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 16),
            locationLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            
            spotNumberLabel.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 8),
            spotNumberLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            
            availabilityLabel.topAnchor.constraint(equalTo: spotNumberLabel.bottomAnchor, constant: 8),
            availabilityLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            
            rateLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 16),
            rateLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            
            rateDescriptionLabel.topAnchor.constraint(equalTo: rateLabel.bottomAnchor, constant: 4),
            rateDescriptionLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            
            // Warning view constraints
            warningView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            warningView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            warningView.topAnchor.constraint(equalTo: availabilityLabel.bottomAnchor, constant: 16),
            warningView.heightAnchor.constraint(equalToConstant: 44),
            
            warningIcon.leadingAnchor.constraint(equalTo: warningView.leadingAnchor, constant: 12),
            warningIcon.centerYAnchor.constraint(equalTo: warningView.centerYAnchor),
            warningIcon.widthAnchor.constraint(equalToConstant: 20),
            warningIcon.heightAnchor.constraint(equalToConstant: 20),
            
            warningLabel.leadingAnchor.constraint(equalTo: warningIcon.trailingAnchor, constant: 8),
            warningLabel.trailingAnchor.constraint(equalTo: warningView.trailingAnchor, constant: -12),
            warningLabel.centerYAnchor.constraint(equalTo: warningView.centerYAnchor),
            
            // Adjust start parking button to be below warning view
            startParkingButton.topAnchor.constraint(equalTo: warningView.bottomAnchor, constant: 16),
            startParkingButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            startParkingButton.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -16),
            startParkingButton.heightAnchor.constraint(equalToConstant: 50),
            startParkingButton.trailingAnchor.constraint(equalTo: directionButton.leadingAnchor, constant: -16),
            
            directionButton.centerYAnchor.constraint(equalTo: startParkingButton.centerYAnchor),
            directionButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            directionButton.heightAnchor.constraint(equalToConstant: 50),
            directionButton.widthAnchor.constraint(equalToConstant: 50)
        ])
        
        tableView.tableHeaderView = headerView
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "locationCell")
        tableView.register(ZoneInfoTableViewCell.self, forCellReuseIdentifier: ZoneInfoTableViewCell.identifier)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func updateStartParkingButtonState(isAvailable: Bool) {
        startParkingButton.isEnabled = isAvailable
        
        // Update visual appearance
        if isAvailable {
            startParkingButton.alpha = 1.0
            startParkingButton.backgroundColor = .white
        } else {
            startParkingButton.alpha = 0.5
            startParkingButton.backgroundColor = .systemGray5
        }
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension ParkingSpotDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Location"
        case 1: return "Zone Information"
        default: return nil
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let parkingSpotModel = parkingSpotModel else {
            print("Fail to get parking spot model")
            let cell = UITableViewCell(style: .default, reuseIdentifier: "NoParkingCell")
            cell.textLabel?.text = "Error"
            return cell
        }
        
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "locationCell", for: indexPath)
            var content = cell.defaultContentConfiguration()
            content.text = parkingSpotModel.areaName
            content.secondaryText = parkingSpotModel.streetName
            content.secondaryTextProperties.color = .systemGray
            cell.contentConfiguration = content
            return cell
            
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: ZoneInfoTableViewCell.identifier, for: indexPath) as! ZoneInfoTableViewCell
            if parkingSpotModel.isAvailable {
                cell.availableLabel.text = "Available"
                cell.availableLabel.textColor = UIColor.systemGreen
            }else{
                cell.availableLabel.text = "Occuiped"
                cell.availableLabel.textColor = UIColor.systemRed
            }
            
            switch parkingSpotModel.type {
            case "green":
                cell.zoneLabel.text = "Green"
                cell.rateLabel.textColor = .systemGreen
                cell.infoIcon.tintColor = .systemGreen
                cell.rateContainer.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.1)
                cell.configure(firstRate: "RM 0.53/ hour", firstHours: "All Hours")
            case "yellow":
                cell.zoneLabel.text = "Yellow"
                cell.rateLabel.textColor = .systemOrange
                cell.infoIcon.tintColor = .systemOrange
                cell.rateContainer.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.1)
                cell.configure(firstRate: "RM 0.53/ 30min", firstHours: "First 4 Hours:", secondRate: "RM 1.06/ 30min", secondHours: "After 4 Hours:")
            case "red":
                cell.zoneLabel.text = "Red"
                cell.rateLabel.textColor = .systemRed
                cell.infoIcon.tintColor = .systemRed
                cell.rateContainer.backgroundColor = UIColor.systemRed.withAlphaComponent(0.1)
                cell.configure(firstRate: "RM 1.06/ 30min", firstHours: "First Hours:", secondRate: "RM 2.12/ 30min", secondHours: "Second Hours:")
            case "disable":
                cell.infoIcon.tintColor = .systemBlue
                cell.rateContainer.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
                cell.configure(firstRate: "FOC", firstHours: "All Hours")
            default:
                break
            }
            
            return cell
            
        default:
            return UITableViewCell()
        }
    }
}

#Preview{
    ParkingSpotDetailsViewController()
}
