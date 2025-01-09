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
    
    // MARK: - Loading State
    private var isLoading: Bool = false {
        didSet {
            DispatchQueue.main.async {
                if self.isLoading {
                    self.loadingIndicator.startAnimating()
                    self.loadingView.isHidden = false
                } else {
                    self.loadingIndicator.stopAnimating()
                    self.loadingView.isHidden = true
                }
            }
        }
    }
    
    // MARK: - UI Components
    private lazy var loadingView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground.withAlphaComponent(0.7)
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.color = .systemBlue
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private lazy var loadingLabel: UILabel = {
        let label = UILabel()
        label.text = "Finding nearest parking spots..."
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
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
        
        // Add subviews
        view.addSubview(searchTextField)
        view.addSubview(tableView)
        view.addSubview(loadingView)
        loadingView.addSubview(loadingIndicator)
        loadingView.addSubview(loadingLabel)
        
        // Setup delegates
        searchTextField.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Search TextField
            searchTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            searchTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchTextField.heightAnchor.constraint(equalToConstant: 30),
            
            // Table View
            tableView.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Loading View
            loadingView.topAnchor.constraint(equalTo: tableView.topAnchor),
            loadingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Loading Indicator
            loadingIndicator.centerXAnchor.constraint(equalTo: loadingView.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: loadingView.centerYAnchor),
            
            // Loading Label
            loadingLabel.topAnchor.constraint(equalTo: loadingIndicator.bottomAnchor, constant: 12),
            loadingLabel.centerXAnchor.constraint(equalTo: loadingView.centerXAnchor)
        ])
    }
    
    // MARK: - Public Methods
    func getUserLocation(userLocation: UserLocation) {
        self.userLocation = userLocation
        tableView.reloadData()
    }
    
    func updateParkingSpots(_ spots: [ParkingSpotModel]) {
        isLoading = false
        self.parkingSpots = spots
        tableView.reloadData()
    }
    
    func showLoading() {
        isLoading = true
    }
    
    func hideLoading() {
        isLoading = false
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
