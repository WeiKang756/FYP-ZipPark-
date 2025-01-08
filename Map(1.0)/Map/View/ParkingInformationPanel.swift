//
//  ParkingInformationPanel.swift
//  Map(1.0)
//
//  Created by Wei Kang Tan on 29/09/2024.
//

import UIKit
import MapKit

// In ParkingInformationPanel.swift
class ParkingInformationPanel: UIView {
    // UI Components
    private let containerStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let parkingInfoView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let locationLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let zoneLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let startParkingButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Start Parking", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let navigateButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "location.fill"), for: .normal)
        button.backgroundColor = .systemBlue.withAlphaComponent(0.1)
        button.tintColor = .systemBlue
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var onStartParkingTapped: (() -> Void)?
    var onNavigateTapped: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .white
        layer.cornerRadius = 16
        layer.masksToBounds = true
        
        addSubview(containerStackView)
        containerStackView.addArrangedSubview(parkingInfoView)
        
        parkingInfoView.addSubview(titleLabel)
        parkingInfoView.addSubview(locationLabel)
        parkingInfoView.addSubview(zoneLabel)
        parkingInfoView.addSubview(startParkingButton)
        parkingInfoView.addSubview(navigateButton)
        
        NSLayoutConstraint.activate([
            containerStackView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            containerStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            containerStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            containerStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            
            titleLabel.topAnchor.constraint(equalTo: parkingInfoView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: parkingInfoView.leadingAnchor, constant: 16),
            
            locationLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            locationLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            
            zoneLabel.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 4),
            zoneLabel.leadingAnchor.constraint(equalTo: locationLabel.leadingAnchor),
            
            navigateButton.centerYAnchor.constraint(equalTo: startParkingButton.centerYAnchor),
            navigateButton.trailingAnchor.constraint(equalTo: parkingInfoView.trailingAnchor, constant: -16),
            navigateButton.widthAnchor.constraint(equalToConstant: 50),
            navigateButton.heightAnchor.constraint(equalToConstant: 50),
            
            startParkingButton.topAnchor.constraint(equalTo: zoneLabel.bottomAnchor, constant: 16),
            startParkingButton.leadingAnchor.constraint(equalTo: parkingInfoView.leadingAnchor, constant: 16),
            startParkingButton.trailingAnchor.constraint(equalTo: navigateButton.leadingAnchor, constant: -16),
            startParkingButton.bottomAnchor.constraint(equalTo: parkingInfoView.bottomAnchor, constant: -16),
            startParkingButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        startParkingButton.addTarget(self, action: #selector(startParkingTapped), for: .touchUpInside)
        navigateButton.addTarget(self, action: #selector(navigateTapped), for: .touchUpInside)
    }
    
    func configure(parkingLot: String, zone: String, location: String, isAvailable: Bool) {
        titleLabel.text = "Parking Lot #\(parkingLot)"
        locationLabel.text = location
        
        switch zone {
        case "yellow":
            zoneLabel.text = "Yellow Zone"
            zoneLabel.textColor = .systemYellow
        case "green":
            zoneLabel.text = "Green Zone"
            zoneLabel.textColor = .systemGreen
        case "red":
            zoneLabel.text = "Red Zone"
            zoneLabel.textColor = .systemRed
        case "disable":
            zoneLabel.text = "Disable Zone"
            zoneLabel.textColor = .systemBlue
        default:
            break
        }
        
        startParkingButton.isEnabled = isAvailable
        startParkingButton.backgroundColor = isAvailable ? .systemBlue : .systemGray3
    }
    
    @objc private func startParkingTapped() {
        onStartParkingTapped?()
    }
    
    @objc private func navigateTapped() {
        onNavigateTapped?()
    }
}
