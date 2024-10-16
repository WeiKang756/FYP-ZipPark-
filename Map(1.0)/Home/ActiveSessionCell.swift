//
//  ActiveSessionCell.swift
//  Map(1.0)
//
//  Created by Wei Kang Tan on 22/11/2024.
//
import UIKit

class ActiveSessionCell: UITableViewCell {
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
    
    private let statusIndicator: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGreen
        view.layer.cornerRadius = 4
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let locationLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let detailsLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let timeLeftLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .systemGreen
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let chevronImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "chevron.right")
        imageView.tintColor = .systemGray3
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(containerView)
        containerView.addSubview(statusIndicator)
        containerView.addSubview(locationLabel)
        containerView.addSubview(detailsLabel)
        containerView.addSubview(timeLeftLabel)
        containerView.addSubview(chevronImageView)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            statusIndicator.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            statusIndicator.centerYAnchor.constraint(equalTo: locationLabel.centerYAnchor),
            statusIndicator.widthAnchor.constraint(equalToConstant: 8),
            statusIndicator.heightAnchor.constraint(equalToConstant: 8),
            
            locationLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            locationLabel.leadingAnchor.constraint(equalTo: statusIndicator.trailingAnchor, constant: 12),
            locationLabel.trailingAnchor.constraint(equalTo: chevronImageView.leadingAnchor, constant: -12),
            
            detailsLabel.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 4),
            detailsLabel.leadingAnchor.constraint(equalTo: locationLabel.leadingAnchor),
            detailsLabel.trailingAnchor.constraint(equalTo: timeLeftLabel.leadingAnchor, constant: -8),
            detailsLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
            
            timeLeftLabel.centerYAnchor.constraint(equalTo: detailsLabel.centerYAnchor),
            timeLeftLabel.trailingAnchor.constraint(equalTo: chevronImageView.leadingAnchor, constant: -16),
            
            chevronImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            chevronImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            chevronImageView.widthAnchor.constraint(equalToConstant: 20),
            chevronImageView.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    func configure(parkingSession: ParkingSession) {
        let location = parkingSession.parkingSpot.street.area.areaName
        locationLabel.text = location
        detailsLabel.text = "\(parkingSession.plateNumber) • Spot #\(parkingSession.parkingSpot.parkingSpotID)"
        timeLeftLabel.text = parkingSession.calculateTimeLeft()
    }
    
    private func configureForInteraction() {
        // Add disclosure indicator
        accessoryType = .disclosureIndicator
        
        // Configure selection style
        selectionStyle = .default
        
        // Add highlight effect
        let backgroundView = UIView()
        backgroundView.backgroundColor = .systemGray6
        selectedBackgroundView = backgroundView
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        if animated {
            UIView.animate(withDuration: 0.1) {
                self.containerView.transform = highlighted ? CGAffineTransform(scaleX: 0.98, y: 0.98) : .identity
                self.containerView.layer.shadowOpacity = highlighted ? 0.05 : 0.1
            }
        } else {
            containerView.transform = highlighted ? CGAffineTransform(scaleX: 0.98, y: 0.98) : .identity
            containerView.layer.shadowOpacity = highlighted ? 0.05 : 0.1
        }
    }
}
