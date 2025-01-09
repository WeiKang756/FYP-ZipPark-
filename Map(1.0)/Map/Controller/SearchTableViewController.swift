import UIKit
import CoreLocation
import FloatingPanel

protocol SearchTextFieldDelegate {
    func searchTextFieldDidSelect()
    func nearestParkingSpotDidSelect(_ selectedParkingSpot: ParkingSpotModel)
}

class SearchTableViewController: UIViewController {
    
    // MARK: - Properties
    private var parkingSpots: [ParkingSpotModel] = []
    private var filteredParkingSpots: [ParkingSpotModel] = []
    var userLocation: UserLocation?
    let mapManager = MapManager()
    var targetViewController: MapViewController?
    var delegate: SearchTextFieldDelegate?
    weak var fpc: FloatingPanelController?
    
    // MARK: - UI Components
    let searchTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Search for Parking Lots"
        textField.borderStyle = .roundedRect
        textField.layer.cornerRadius = 30
        
        let imageView = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        imageView.tintColor = .gray
        imageView.contentMode = .scaleAspectFit
        imageView.frame = CGRect(x: 10, y: 0, width: 20, height: 20)
        
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 20))
        containerView.addSubview(imageView)
        
        textField.leftView = containerView
        textField.leftViewMode = .always
        textField.backgroundColor = UIColor.systemGray5
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UINib(nibName: "TableViewCell", bundle: nil),
                         forCellReuseIdentifier: "UserLocationCell")
        tableView.register(ParkingSpotCell.self, forCellReuseIdentifier: "ParkingSpotCell")
        return tableView
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        view.backgroundColor = .systemGray6
        
        view.addSubview(searchTextField)
        view.addSubview(tableView)
        
        searchTextField.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            searchTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            searchTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchTextField.heightAnchor.constraint(equalToConstant: 30),
            
            tableView.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - Public Methods
    func getUserLocation(userLocation: UserLocation) {
        self.userLocation = userLocation
        tableView.reloadData()
    }
    
    
    func updateParkingSpots(_ spots: [ParkingSpotModel]) {
        self.parkingSpots = spots.sorted { $0.distance ?? 0 < $1.distance ?? 0 }
        tableView.reloadData()
    }
}

// MARK: - UITextFieldDelegate
extension SearchTableViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        delegate?.searchTextFieldDidSelect()
        return false
    }
}

// MARK: - FloatingPanelControllerDelegate
extension SearchTableViewController: FloatingPanelControllerDelegate {
    func floatingPanelDidChangeState(_ fpc: FloatingPanelController) {
        self.fpc = fpc
        tableView.reloadData()
        
        if tableView.numberOfSections > 0 && tableView.numberOfRows(inSection: 0) > 0 {
            let topIndexPath = IndexPath(row: 0, section: 0)
            tableView.scrollToRow(at: topIndexPath, at: .top, animated: true)
        }
    }
}

// MARK: - UITableViewDataSource
extension SearchTableViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2 // User location and parking spots
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1 // User location cell
        } else {
            return parkingSpots.count // Parking spots
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "UserLocationCell",
                                                    for: indexPath) as! TableViewCell
            cell.userLocationLabel.text = userLocation?.streetName ?? "Not Found"
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ParkingSpotCell",
                                                    for: indexPath) as! ParkingSpotCell
            let parkingSpot = parkingSpots[indexPath.row]
            cell.configure(with: parkingSpot)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "User Location"
        case 1: return "Nearby Parking Spots"
        default: return nil
        }
    }
}

// MARK: - UITableViewDelegate
extension SearchTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 15
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        footerView.backgroundColor = .clear
        return footerView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            let selectedSpot = parkingSpots[indexPath.row]
            delegate?.nearestParkingSpotDidSelect(selectedSpot)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
