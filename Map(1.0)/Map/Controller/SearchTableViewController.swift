import UIKit
import CoreLocation
import FloatingPanel

protocol SearchTextFieldDelegate {
    func searchTextFieldDidSelect()
}
class SearchTableViewController: UIViewController, UITextFieldDelegate, FloatingPanelControllerDelegate {
    
    var areaModel: [AreaModel]?
    var userLocation: UserLocation?
    let mapManager = MapManager()
    var targetViewController: MapViewController?
    var parkingFinderTableCellDelegate: ParkingFinderTableViewCellDelegate?
    var delegate: SearchTextFieldDelegate?
    // Create search text field
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
    
    // Create table view
    let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UINib(nibName: "ParkingFinderTableViewCell", bundle: nil), forCellReuseIdentifier: "ParkingFinderCell")
        tableView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "UserLocationCell")
        tableView.register(UINib(nibName: "AreaListTableViewCell", bundle: nil), forCellReuseIdentifier: "AreaListCell")
        
        return tableView
    }()
    
    // Reference to the FloatingPanelController
    weak var fpc: FloatingPanelController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemGray6
        view.addSubview(searchTextField)
        view.addSubview(tableView)
        
        // Set up delegates
        searchTextField.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
        // Register a default UITableViewCell
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        // Set up constraints
        setupConstraints()
    }
    
    func setupConstraints() {
        // Search Text Field Constraints
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
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        // Prevent keyboard appearance
        textField.resignFirstResponder()
        delegate?.searchTextFieldDidSelect()
        return false // Prevent keyboard from showing
    }
    
    // MARK: - FloatingPanelControllerDelegate Methods
    func floatingPanelDidChangeState(_ fpc: FloatingPanelController) {
        self.fpc = fpc
        // Reload table view to reflect state change
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource Methods

extension SearchTableViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // Show all sections if the panel is in the full state, otherwise exclude the "Area" section
        if fpc?.state == .full {
            return 3
        } else {
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            return 1
        } else {
            let numOfRow: Int
            if let areaModel = areaModel {
                numOfRow = areaModel.count
            }else{
                numOfRow = 1
            }
            return fpc?.state == .full ? numOfRow : 0
        }
    }
    
    func getUserLocation(userLocation: UserLocation) {
        self.userLocation = userLocation
        tableView.reloadData()
    }
    
    func getAreaData(areaModels : [AreaModel]) {
        self.areaModel = areaModels
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "UserLocationCell", for: indexPath) as! TableViewCell
            var street: String
            if let userLocation = userLocation {
                street = userLocation.streetName
            }else{
                street = "Not Found"
            }
            cell.userLocationLabel.text = street
            return cell
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ParkingFinderCell", for: indexPath) as! ParkingFinderTableViewCell
            cell.delegate = parkingFinderTableCellDelegate
            return cell
        } else {
            guard let areaModel = areaModel else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
                cell.textLabel?.text = "N/A"
                cell.alpha = 0.0
                return cell
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "AreaListCell", for: indexPath) as! AreaListTableViewCell
            let distanceString: String
            guard var distance = areaModel[indexPath.row].distance else {
                print("Fail to get user location")
                return cell
            }
            
            if distance > 1000{
                distance = distance/1000
                distanceString = String(format: "%.1f KM", distance)
            }else {
                distanceString = String(format: "%.0f M", distance)
            }
            cell.areaName.text = areaModel[indexPath.row].areaName
            cell.distanceLabel.text = distanceString
            cell.availableLabel.text = areaModel[indexPath.row].availableParkingString
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "User Location"
        } else if section == 1 {
            return "Parking Finder"
        } else {
            return fpc?.state == .full ? "Area" : nil
        }
    }
}

// MARK: - UITableViewDelegate Methods

extension SearchTableViewController: UITableViewDelegate {
    
    // Set height for header to create space between sections
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30 // Height for the gap between sections
    }
    
    // Set height for footer to create additional space if needed
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 15 // Height for the gap between sections
    }
    
    // Optional: Set custom view for footer if needed
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        footerView.backgroundColor = .clear
        return footerView
    }
}
