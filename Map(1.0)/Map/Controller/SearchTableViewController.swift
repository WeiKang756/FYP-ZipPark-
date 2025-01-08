import UIKit
import CoreLocation
import FloatingPanel

protocol SearchTextFieldDelegate {
    func searchTextFieldDidSelect()
}

class SearchTableViewController: UIViewController {
    
    // MARK: - Properties
    var areaModel: [AreaModel]?
    var userLocation: UserLocation?
    let mapManager = MapManager()
    var targetViewController: MapViewController?
    var parkingFinderTableCellDelegate: ParkingFinderTableViewCellDelegate?
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
        tableView.register(UINib(nibName: "ParkingFinderTableViewCell", bundle: nil),
                         forCellReuseIdentifier: "ParkingFinderCell")
        tableView.register(UINib(nibName: "TableViewCell", bundle: nil),
                         forCellReuseIdentifier: "UserLocationCell")
        tableView.register(UINib(nibName: "AreaListTableViewCell", bundle: nil),
                         forCellReuseIdentifier: "AreaListCell")
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
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
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
    
    func getAreaData(areaModels: [AreaModel]) {
        self.areaModel = areaModels
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
    }
}

// MARK: - UITableViewDataSource
extension SearchTableViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return fpc?.state == .full ? 3 : 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 || section == 1 {
            return 1
        } else {
            if let areaModel = areaModel {
                return fpc?.state == .full ? areaModel.count : 0
            }
            return fpc?.state == .full ? 1 : 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "UserLocationCell",
                                                    for: indexPath) as! TableViewCell
            cell.userLocationLabel.text = userLocation?.streetName ?? "Not Found"
            return cell
            
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ParkingFinderCell",
                                                    for: indexPath) as! ParkingFinderTableViewCell
            cell.delegate = parkingFinderTableCellDelegate
            return cell
            
        default:
            if let areaModel = areaModel {
                let cell = tableView.dequeueReusableCell(withIdentifier: "AreaListCell",
                                                        for: indexPath) as! AreaListTableViewCell
                
                if let distance = areaModel[indexPath.row].distance {
                    let distanceString = distance > 1000 ?
                        String(format: "%.1f KM", distance/1000) :
                        String(format: "%.0f M", distance)
                    cell.distanceLabel.text = distanceString
                }
                
                cell.areaName.text = areaModel[indexPath.row].areaName
                cell.availableLabel.text = areaModel[indexPath.row].availableParkingString
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
                cell.textLabel?.text = "N/A"
                cell.alpha = 0.0
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "User Location"
        case 1: return "Parking Finder"
        default: return fpc?.state == .full ? "Area" : nil
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
}
