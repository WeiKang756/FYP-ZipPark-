import UIKit


protocol NearestParkingViewControllerDelegate {
    func didDismissViewController()
    func didSelectedNearestParking(_ nearestParkingModel: ParkingSpotModel)
}

class NearestParkingViewController: UIViewController {
    
    var availableParkingSpotModel :[ParkingSpotModel]?
    var mapManager: MapManager?
    var delegate: NearestParkingViewControllerDelegate?
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.text = "Nearest Parking"
        titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }()
    
    private lazy var closeButton: UIButton = {
        let closeButton = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold)
        let closeButtonImage = UIImage(systemName: "xmark.circle.fill", withConfiguration: config)?.withTintColor(.systemGray4, renderingMode: .alwaysOriginal)
        closeButton.setImage(closeButtonImage, for: .normal)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        return closeButton
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UINib(nibName: "ParkingTableViewCell", bundle: nil), forCellReuseIdentifier: "ParkingCell")
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func setupUI() {
        view.addSubview(titleLabel)
        view.addSubview(closeButton)
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: closeButton.leadingAnchor, constant: -10),
            
            closeButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    @objc func closeButtonTapped() {
        self.dismiss(animated: true, completion: nil)
        delegate?.didDismissViewController()
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

extension NearestParkingViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        availableParkingSpotModel?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ParkingCell") as! ParkingTableViewCell
        
        guard let availableParkingSpotModel = availableParkingSpotModel else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
            cell.textLabel?.text = "No Parking Spot Found"
            return cell
        }
        
        let distance =  availableParkingSpotModel[indexPath.row].distance
        let distanceString = mapManager?.distanceToDistanceString(distance: distance ?? 0.0)
        cell.distanceLabel.text = distanceString
        
        let area = availableParkingSpotModel[indexPath.row].areaName
        let street = availableParkingSpotModel[indexPath.row].streetName
        cell.locationLabel.text = ("\(area),\(street)")
        
        let parkingLotId = availableParkingSpotModel[indexPath.row].parkingSpotID
        cell.parkingLotLabel.text = "Parking Spot: \(parkingLotId)"
        
        let parkingType = availableParkingSpotModel[indexPath.row].type
        switch parkingType {
        case "red":
            cell.parkingTypeIcon.image = UIImage(systemName: "parkingsign.square.fill")
            cell.parkingTypeIcon.tintColor = UIColor.systemRed
        case "green":
            cell.parkingTypeIcon.image = UIImage(systemName: "parkingsign.square.fill")
            cell.parkingTypeIcon.tintColor = UIColor.systemGreen
        case "yellow":
            cell.parkingTypeIcon.image = UIImage(systemName: "parkingsign.square.fill")
            cell.parkingTypeIcon.tintColor = UIColor.systemYellow
        case "disable":
            cell.parkingTypeIcon.image = UIImage(systemName: "figure.roll")
            cell.parkingTypeIcon.tintColor = UIColor.systemBlue
        default:
            break
        }
        return cell
    }
}

extension NearestParkingViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let availableParkingSpotModel = availableParkingSpotModel else { return }
        let selectedParkingSpot = availableParkingSpotModel[indexPath.row]
        delegate?.didSelectedNearestParking(selectedParkingSpot)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
