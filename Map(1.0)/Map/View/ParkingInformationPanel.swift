//
//  ParkingInformationPanel.swift
//  Map(1.0)
//
//  Created by Wei Kang Tan on 29/09/2024.
//

import UIKit
import MapKit

class ParkingInformationPanel: UIView {
    // MARK: - UI Elements
    var onStartParkingTapped: (() -> Void)?
    var onNavigateTapped: (() -> Void)?
    
    private let parkingIconView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.1)
        view.layer.cornerRadius = 20
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let parkingIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "parkingsign.square.fill")
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemGreen
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.text = "Parking Lot: 105"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let zoneContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemYellow.withAlphaComponent(0.1)
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let zoneLabel: UILabel = {
        let label = UILabel()
        label.text = "Yellow Zone"
        label.font = .systemFont(ofSize: 14)
        label.textColor = .systemYellow
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let locationLabel: UILabel = {
        let label = UILabel()
        label.text = "• Suria Sabah"
        label.font = .systemFont(ofSize: 14)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let infoStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // Status section
    private let statusSection: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        return stack
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.text = "Status"
        label.font = .systemFont(ofSize: 14)
        label.textColor = .gray
        return label
    }()
    
    private let availabilityLabel: UILabel = {
        let label = UILabel()
        label.text = "Available"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .systemGreen
        return label
    }()
    
    // Distance section
    private let distanceSection: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        return stack
    }()
    
    private let distanceHeaderLabel: UILabel = {
        let label = UILabel()
        label.text = "Distance"
        label.font = .systemFont(ofSize: 14)
        label.textColor = .gray
        return label
    }()
    
    private let distanceValueLabel: UILabel = {
        let label = UILabel()
        label.text = "2.7 KM"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    // Time section
    private let timeSection: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        return stack
    }()
    
    private let rateHeaderLabel: UILabel = {
        let label = UILabel()
        label.text = "Rate"
        label.font = .systemFont(ofSize: 14)
        label.textColor = .gray
        return label
    }()
    
    private let rateValueLabel: UILabel = {
        let label = UILabel()
        label.text = "~8 mins"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    // Buttons
    private let buttonStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 12
        stack.distribution = .fillProportionally
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let startParkingButton: UIButton = {
        let button = UIButton()
        button.setTitle("Start Parking", for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 25
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.addTarget(self, action: #selector(startParkingButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let navigateButton: UIButton = {
        let button = UIButton()
        button.setTitle("Navigate", for: .normal)
        button.backgroundColor = .systemGray6
        button.setTitleColor(.darkText, for: .normal)
        button.layer.cornerRadius = 25
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.addTarget(self, action: #selector(navigateButtonTapped), for: .touchUpInside)
        
        // Add navigation icon
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        let image = UIImage(systemName: "location.fill", withConfiguration: imageConfig)
        button.setImage(image, for: .normal)
        button.tintColor = .darkText
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 8)
        
        return button
    }()
    
    // MARK: - Button Actions
    @objc private func startParkingButtonTapped() {
        onStartParkingTapped?()
    }
    
    @objc private func navigateButtonTapped() {
        onNavigateTapped?()
    }
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    // MARK: - Setup
    private func setupView() {
        backgroundColor = .white
        layer.cornerRadius = 20
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        // Add shadow
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowRadius = 10
        layer.shadowOffset = CGSize(width: 0, height: -5)
        
        setupSubviews()
        setupConstraints()
    }
    
    private func setupSubviews() {
        // Add parking icon
        addSubview(parkingIconView)
        parkingIconView.addSubview(parkingIcon)
        
        // Add title and location info
        addSubview(titleLabel)
        addSubview(zoneContainer)
        zoneContainer.addSubview(zoneLabel)
        addSubview(locationLabel)
        
        // Setup info sections
        statusSection.addArrangedSubview(statusLabel)
        statusSection.addArrangedSubview(availabilityLabel)
        
        distanceSection.addArrangedSubview(distanceHeaderLabel)
        distanceSection.addArrangedSubview(distanceValueLabel)
        
        timeSection.addArrangedSubview(rateHeaderLabel)
        timeSection.addArrangedSubview(rateValueLabel)
        
        infoStackView.addArrangedSubview(statusSection)
        infoStackView.addArrangedSubview(distanceSection)
        infoStackView.addArrangedSubview(timeSection)
        addSubview(infoStackView)
        
        // Setup buttons
        buttonStack.addArrangedSubview(startParkingButton)
        buttonStack.addArrangedSubview(navigateButton)
        addSubview(buttonStack)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Parking icon
            parkingIconView.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            parkingIconView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            parkingIconView.widthAnchor.constraint(equalToConstant: 40),
            parkingIconView.heightAnchor.constraint(equalToConstant: 40),
            
            parkingIcon.centerXAnchor.constraint(equalTo: parkingIconView.centerXAnchor),
            parkingIcon.centerYAnchor.constraint(equalTo: parkingIconView.centerYAnchor),
            
            // Title and location
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: parkingIconView.trailingAnchor, constant: 12),
            
            zoneContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            zoneContainer.leadingAnchor.constraint(equalTo: parkingIconView.trailingAnchor, constant: 12),
            
            zoneLabel.topAnchor.constraint(equalTo: zoneContainer.topAnchor, constant: 4),
            zoneLabel.bottomAnchor.constraint(equalTo: zoneContainer.bottomAnchor, constant: -4),
            zoneLabel.leadingAnchor.constraint(equalTo: zoneContainer.leadingAnchor, constant: 8),
            zoneLabel.trailingAnchor.constraint(equalTo: zoneContainer.trailingAnchor, constant: -8),
            
            locationLabel.centerYAnchor.constraint(equalTo: zoneContainer.centerYAnchor),
            locationLabel.leadingAnchor.constraint(equalTo: zoneContainer.trailingAnchor, constant: 8),
            
            // Info stack
            infoStackView.topAnchor.constraint(equalTo: zoneContainer.bottomAnchor, constant: 24),
            infoStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            infoStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            // Buttons
            buttonStack.topAnchor.constraint(equalTo: infoStackView.bottomAnchor, constant: 24),
            buttonStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            buttonStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            buttonStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
            buttonStack.heightAnchor.constraint(equalToConstant: 50),
            
            startParkingButton.widthAnchor.constraint(equalTo: buttonStack.widthAnchor, multiplier: 0.65),
        ])
    }
    
    // MARK: - Public Methods
    func configure(parkingLot: String, zone: String, location: String, isAvailable: Bool, distance: String) {
        titleLabel.text = "Parking Lot: \(parkingLot)"
        locationLabel.text = "• \(location)"
        availabilityLabel.text = isAvailable ? "Available" : "Occupied"
        availabilityLabel.textColor = isAvailable ? .systemGreen : .systemRed
        distanceValueLabel.text = distance
        switch zone {
        case "green":
            parkingIconView.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.1)
            parkingIcon.image = UIImage(systemName: "parkingsign")
            parkingIcon.tintColor = .systemGreen
            zoneLabel.text = "Green Zone"
            zoneLabel.textColor = .systemGreen
            zoneContainer.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.1)
            rateValueLabel.text = "RM 0.53/hour"
        case "red":
            parkingIconView.backgroundColor = UIColor.systemRed.withAlphaComponent(0.1)
            parkingIcon.image = UIImage(systemName: "parkingsign")
            parkingIcon.tintColor = .systemRed
            zoneLabel.text = "Red Zone"
            zoneLabel.textColor = .systemRed
            zoneContainer.backgroundColor = UIColor.systemRed.withAlphaComponent(0.1)
            rateValueLabel.text = "1-2x30 min: RM1.06"
        case "yellow":
            parkingIconView.backgroundColor = UIColor.systemYellow.withAlphaComponent(0.1)
            parkingIcon.image = UIImage(systemName: "parkingsign")
            parkingIcon.tintColor = .systemYellow
            zoneLabel.text = "Yellow Zone"
            zoneLabel.textColor = .systemYellow
            zoneContainer.backgroundColor = UIColor.systemYellow.withAlphaComponent(0.1)
            rateValueLabel.text = "1-8x30 min: RM0.53"
        case "disable":
            parkingIconView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
            parkingIcon.image = UIImage(systemName: "figure.roll")
            parkingIcon.tintColor = .systemBlue
            zoneLabel.text = "Disable"
            zoneLabel.textColor = .systemBlue
            zoneContainer.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
            rateValueLabel.text = "FOC"
        default:
            break
        }
    }
}
