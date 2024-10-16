//
//  ViewController.swift
//  Map(1.0)
//
//  Created by Wei Kang Tan on 24/10/2024.
//

import UIKit
import CoreLocation

protocol StreetInformationViewControllerDelegate {
    
    func parkingSpotRowDidSelected (_ parkingSpotModel: ParkingSpotModel)
}

class StreetInformationViewController: UIViewController {
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.text = streetModel?.streetName ?? "No Street Information"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var typeButton: FilterButton = {
        let button = FilterButton(title: "Type")
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var availabilityButton: FilterButton = {
        let button = FilterButton(title: "Availability")
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let table: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    private let mapManager = MapManager()
    var streetModel: StreetModel?
    var delegate: StreetInformationViewControllerDelegate?
    private var filteredParkingSpots: [ParkingSpotModel] = []
    private var distance: Double?
    private var selectedType: String = "All Types"
    private var selectedAvailability: Bool? = nil
    var userLocation: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        table.dataSource = self
        table.delegate = self
        table.register(UINib(nibName: "ParkingSpotInfoCell", bundle: nil), forCellReuseIdentifier: "ParkingSpotInfoCell")
        setupFilterMenus() // Add this line
        filterParkingSpots(type: selectedType, isAvailable: selectedAvailability)
        setupUI()
    }
    
    private func setupUI() {
        // Create a stack view to hold the buttons
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add buttons to stack view
        stackView.addArrangedSubview(typeButton)
        stackView.addArrangedSubview(availabilityButton)
        
        view.addSubview(label)
        view.addSubview(stackView)
        view.addSubview(table)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            
            stackView.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 10),
            stackView.leadingAnchor.constraint(equalTo: label.leadingAnchor, constant: 10),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: label.trailingAnchor, constant: -16),
            stackView.heightAnchor.constraint(equalToConstant: 30),
            
            table.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 10),
            table.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            table.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            table.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 20),
        ])
    }
    
    private func setupFilterMenus() {
        // Setup Type Menu
        setupTypeMenu()
        // Setup Availability Menu
        setupAvailabilityMenu()
    }
    
    private func setupTypeMenu() {
        let allTypes = UIAction(title: "All Types", image: nil) { [weak self] _ in
            self?.typeButton.setTitle("All Types", for: .normal)
            self?.selectedType = "All Types"
            self?.filterParkingSpots(type: self?.selectedType ?? "All Types", isAvailable: self?.selectedAvailability)
        }
        
        let redType = UIAction(title: "Red", image: UIImage(systemName: "circle.fill")?.withTintColor(.red, renderingMode: .alwaysOriginal)) { [weak self] _ in
            self?.typeButton.setTitle("Red", for: .normal)
            self?.selectedType = "red"
            self?.filterParkingSpots(type: self?.selectedType ?? "All Types", isAvailable: self?.selectedAvailability)
        }
        
        let greenType = UIAction(title: "Green", image: UIImage(systemName: "circle.fill")?.withTintColor(.green, renderingMode: .alwaysOriginal)) { [weak self] _ in
            self?.typeButton.setTitle("Green", for: .normal)
            self?.selectedType = "green"
            self?.filterParkingSpots(type: self?.selectedType ?? "All Types", isAvailable: self?.selectedAvailability)
        }
        
        let yellowType = UIAction(title: "Yellow", image: UIImage(systemName: "circle.fill")?.withTintColor(.yellow, renderingMode: .alwaysOriginal)) { [weak self] _ in
            self?.typeButton.setTitle("Yellow", for: .normal)
            self?.selectedType = "yellow"
            self?.filterParkingSpots(type: self?.selectedType ?? "All Types", isAvailable: self?.selectedAvailability)
        }
        
        let disableType = UIAction(title: "Disable", image: UIImage(systemName: "figure.roll")) { [weak self] _ in
            self?.typeButton.setTitle("Disable", for: .normal)
            self?.selectedType = "disable"
            self?.filterParkingSpots(type: self?.selectedType ?? "All Types", isAvailable: self?.selectedAvailability)
        }
        
        let menu = UIMenu(title: "", options: .displayInline, children: [
            allTypes,
            redType,
            greenType,
            yellowType,
            disableType
        ])
        
        typeButton.menu = menu
        typeButton.showsMenuAsPrimaryAction = true
    }
    
    private func setupAvailabilityMenu() {
        let allStatus = UIAction(title: "All", image: nil) { [weak self] _ in
            self?.availabilityButton.setTitle("All", for: .normal)
            self?.selectedAvailability = nil
            self?.filterParkingSpots(type: self?.selectedType ?? "All Types", isAvailable: self?.selectedAvailability)
        }
        
        let available = UIAction(title: "Available", image: nil) { [weak self] _ in
            self?.availabilityButton.setTitle("Available", for: .normal)
            self?.selectedAvailability = true
            self?.filterParkingSpots(type: self?.selectedType ?? "All Types", isAvailable: self?.selectedAvailability)
        }
        
        let menu = UIMenu(title: "", options: .displayInline, children: [
            available,
            allStatus
        ])
        
        availabilityButton.menu = menu
        availabilityButton.showsMenuAsPrimaryAction = true
    }
    
    func filterParkingSpots(type: String, isAvailable: Bool?) {
        guard let parkingSpotModels = streetModel?.parkingSpots else {return}
        
        if type == "All Types" && isAvailable == nil {
            // Show all parking spots (no filtering)
            filteredParkingSpots = parkingSpotModels
        } else {
            filteredParkingSpots = parkingSpotModels.filter { spot in
                let typeMatch = (type == "All Types" || spot.type == type)
                let availabilityMatch = (isAvailable == nil || spot.isAvailable == isAvailable)
                return typeMatch && availabilityMatch
            }
        }
        
        table.reloadData()
    }
}

extension StreetInformationViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numOfParkingSpots = filteredParkingSpots.count
        return numOfParkingSpots
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ParkingSpotInfoCell", for: indexPath) as! ParkingSpotInfoCell
        let parkingSpotModel = filteredParkingSpots[indexPath.row]
        let parkingSpotLocation = CLLocation(latitude: parkingSpotModel.latitude, longitude: parkingSpotModel.longitude)
        guard let userLocation = userLocation else { return cell }
        var distance = mapManager.calculateDistance(userLocation, parkingSpotLocation)
        let distanceString: String
        
        if distance > 1000{
            distance = distance/1000
            distanceString = String(format: "%.1f KM", distance)
        }else {
            distanceString = String(format: "%.0f M", distance)
        }
        cell.distanceValueLabel.text = distanceString
        
        let isAvailable = parkingSpotModel.isAvailable
        
        if isAvailable {
            cell.isAvailableLabel.text = "Available"
            cell.isAvailableLabel.textColor = UIColor.systemGreen
        }else {
            cell.isAvailableLabel.text = "Occuiped"
            cell.isAvailableLabel.textColor = UIColor.systemRed
        }
        
        let parkingType = parkingSpotModel.type
        
        if parkingType == "green" {
            cell.parkingTypeImage.image = UIImage(systemName: "parkingsign.square.fill")
            cell.parkingTypeImage.tintColor = UIColor.systemGreen
            cell.parkingTypeLabel.text = "Green"
            cell.parkingTypeLabel.textColor = UIColor.systemGreen
            
        }else if parkingType == "red" {
            cell.parkingTypeImage.image = UIImage(systemName: "parkingsign.square.fill")
            cell.parkingTypeImage.tintColor = UIColor.systemRed
            cell.parkingTypeLabel.text = "Red"
            cell.parkingTypeLabel.textColor = UIColor.systemRed
            
        }else if parkingType == "yellow"{
            cell.parkingTypeImage.image = UIImage(systemName: "parkingsign.square.fill")
            cell.parkingTypeImage.tintColor = UIColor.systemYellow
            cell.parkingTypeLabel.text = "Yellow"
            cell.parkingTypeLabel.textColor = UIColor.systemYellow
            
        }else if parkingType == "disable"{
            cell.parkingTypeImage.image = UIImage(systemName: "figure.roll")
            cell.parkingTypeImage.tintColor = UIColor.black
            cell.parkingTypeLabel.text = "Disable"
            cell.parkingTypeLabel.textColor = UIColor.black
        }
        let parkingSpotID = String(parkingSpotModel.parkingSpotID)
        cell.parkingSpotLabel.text = "Parking: \(parkingSpotID)"
        return cell
    }
}

extension StreetInformationViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let parkingSpotModel = filteredParkingSpots[indexPath.row]
        delegate?.parkingSpotRowDidSelected(parkingSpotModel)
    }
}
