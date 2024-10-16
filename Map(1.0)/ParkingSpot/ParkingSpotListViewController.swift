//
//  ParkingSpotListViewController.swift
//  Map(1.0)
//
//  Created by Wei Kang Tan on 17/12/2024.
//
import UIKit

protocol ParkingSpotListViewControllerDelegate: AnyObject {
    func didSelectParkingSpot(_ parkingSpot: ParkingSpotModel)
}

class ParkingSpotListViewController: UIViewController {
    
    // MARK: - Properties
    private let searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.obscuresBackgroundDuringPresentation = false
        controller.searchBar.placeholder = "Search for parking spots..."
        return controller
    }()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = .systemGray6
        table.separatorStyle = .none
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    private var parkingSpots: [ParkingSpotModel] = []
    private var filteredData: [ParkingSpotModel] = []
    private var parkingManager = ParkingListManager()
    weak var delegate: ParkingSpotListViewControllerDelegate?

    
    private var isSearching: Bool {
        return searchController.isActive && !searchBarIsEmpty
    }
    
    private var searchBarIsEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        setupSearchController()
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .never
        parkingManager.delegate = self
        parkingManager.fetchAllParkingSpot()
    }
    
    // MARK: - Setup
    private func setupUI() {
        title = "Parking Spots"
        view.backgroundColor = .systemBackground
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
        
        // Optional: Customize search bar appearance
        searchController.searchBar.searchTextField.backgroundColor = .systemGray6
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ParkingSpotCell.self, forCellReuseIdentifier: "ParkingSpotCell")
    }
    
    private func filterContentForSearchText(_ searchText: String) {
        filteredData = parkingSpots.filter { spot in
            return String(spot.parkingSpotID).lowercased().contains(searchText.lowercased()) ||
                spot.areaName.lowercased().contains(searchText.lowercased()) ||
                spot.streetName.lowercased().contains(searchText.lowercased()) ||
                spot.type.lowercased().contains(searchText.lowercased())
        }
        tableView.reloadData()
    }
}

// MARK: - UITableViewDelegate & DataSource
extension ParkingSpotListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearching ? filteredData.count : parkingSpots.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Get the selected parking spot
        let parkingSpot = isSearching ? filteredData[indexPath.row] : parkingSpots[indexPath.row]
        
        // Provide visual feedback
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Notify delegate
        delegate?.didSelectParkingSpot(parkingSpot)
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ParkingSpotCell", for: indexPath) as! ParkingSpotCell
        let parkingSpot = isSearching ? filteredData[indexPath.row] : parkingSpots[indexPath.row]
        cell.configure(with: parkingSpot)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
}

// MARK: - UISearchResultsUpdating
extension ParkingSpotListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        filterContentForSearchText(searchText)
    }
}

// MARK: - UISearchBarDelegate
extension ParkingSpotListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text ?? "")
    }
}

// MARK: - ParkingListManagerDelegate
extension ParkingSpotListViewController: ParkingListManagerDelegate {
    func didFetchAllParkingSpot(_ parkingSpotModels: [ParkingSpotModel]) {
        parkingSpots = parkingSpotModels
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

#Preview {
    ParkingSpotListViewController()
}
