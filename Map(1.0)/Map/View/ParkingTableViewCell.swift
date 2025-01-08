//
//  ParkingTableViewCell.swift
//  Map(1.0)
//
//  Created by Wei Kang Tan on 19/12/2024.
//
import UIKit

class ParkingTableViewCell: UITableViewCell {
    
    // MARK: - UI Components
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.layer.shadowOpacity = 0.1
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let parkingTypeIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemBlue
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let parkingLotLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let locationLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .systemGray
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let distanceStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .trailing
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let distanceTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "DISTANCE"
        label.font = .systemFont(ofSize: 12)
        label.textColor = .systemGray
        return label
    }()
    
    let distanceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17)
        label.textColor = .systemBlue
        return label
    }()
    
    let parkingLotNumLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let parkingLotAvailabilityLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let parkingAvailabilityImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - Setup
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(containerView)
        
        containerView.addSubview(parkingTypeIcon)
        containerView.addSubview(parkingLotLabel)
        containerView.addSubview(locationLabel)
        containerView.addSubview(distanceStack)
        containerView.addSubview(parkingLotNumLabel)
        containerView.addSubview(parkingLotAvailabilityLabel)
        containerView.addSubview(parkingAvailabilityImageView)
        
        distanceStack.addArrangedSubview(distanceTitleLabel)
        distanceStack.addArrangedSubview(distanceLabel)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            parkingTypeIcon.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            parkingTypeIcon.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            parkingTypeIcon.widthAnchor.constraint(equalToConstant: 50),
            parkingTypeIcon.heightAnchor.constraint(equalToConstant: 50),
            
            parkingLotLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            parkingLotLabel.leadingAnchor.constraint(equalTo: parkingTypeIcon.trailingAnchor, constant: 12),
            
            locationLabel.topAnchor.constraint(equalTo: parkingLotLabel.bottomAnchor, constant: 4),
            locationLabel.leadingAnchor.constraint(equalTo: parkingTypeIcon.trailingAnchor, constant: 12),
            locationLabel.trailingAnchor.constraint(equalTo: distanceStack.leadingAnchor, constant: -8),
            locationLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
            
            distanceStack.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            distanceStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            parkingLotAvailabilityLabel.topAnchor.constraint(equalTo: distanceStack.bottomAnchor, constant: 8),
            parkingLotAvailabilityLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16)
        ])
    }
    
    func configure(with parkingSpot: ParkingSpotModel) {
        parkingLotLabel.text = "Parking Lot: \(parkingSpot.parkingSpotID)"
        locationLabel.text = "\(parkingSpot.areaName), \(parkingSpot.streetName)"
        distanceLabel.text = "\(parkingSpot.distance?.description ?? "N/A") KM"
        
        switch parkingSpot.type {
        case "yellow":
            parkingTypeIcon.image = UIImage(systemName: "parkingsign.circle.fill")
            parkingTypeIcon.tintColor = .systemYellow
        case "red":
            parkingTypeIcon.image = UIImage(systemName: "parkingsign.circle.fill")
            parkingTypeIcon.tintColor = .systemRed
        case "green":
            parkingTypeIcon.image = UIImage(systemName: "parkingsign.circle.fill")
            parkingTypeIcon.tintColor = .systemGreen
        case "disable":
            parkingTypeIcon.image = UIImage(systemName: "figure.roll")
            parkingTypeIcon.tintColor = .systemBlue
        default:
            parkingTypeIcon.image = UIImage(systemName: "parkingsign.circle.fill")
            parkingTypeIcon.tintColor = .systemGray
        }
    }
}
