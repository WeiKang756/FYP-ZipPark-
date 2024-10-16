//
//  ParkingSpotCell.swift
//  Map(1.0)
//
//  Created by Wei Kang Tan on 17/12/2024.
//
import UIKit

class ParkingSpotCell: UITableViewCell {
    
    // MARK: - UI Components
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowRadius = 5
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let spotIdLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let areaLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let streetLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let typeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .center
        label.layer.cornerRadius = 12
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        configureSelectionStyle()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func configureSelectionStyle() {
        // Enable selection
        selectionStyle = .default
        
        // Create selected background view
        let selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = .systemGray6
        self.selectedBackgroundView = selectedBackgroundView
        
        // Add tap highlight effect to container view
        containerView.layer.masksToBounds = false
        
        // Make sure the container view stays above the selection background
        contentView.sendSubviewToBack(selectedBackgroundView)
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
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if animated {
            UIView.animate(withDuration: 0.1) {
                self.containerView.transform = selected ? CGAffineTransform(scaleX: 0.98, y: 0.98) : .identity
                self.containerView.layer.shadowOpacity = selected ? 0.05 : 0.1
            }
        } else {
            containerView.transform = selected ? CGAffineTransform(scaleX: 0.98, y: 0.98) : .identity
            containerView.layer.shadowOpacity = selected ? 0.05 : 0.1
        }
    }
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(containerView)
        containerView.addSubview(spotIdLabel)
        containerView.addSubview(areaLabel)
        containerView.addSubview(streetLabel)
        containerView.addSubview(typeLabel)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            spotIdLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            spotIdLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            
            areaLabel.topAnchor.constraint(equalTo: spotIdLabel.bottomAnchor, constant: 8),
            areaLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            
            streetLabel.topAnchor.constraint(equalTo: areaLabel.bottomAnchor, constant: 4),
            streetLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            streetLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
            
            typeLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            typeLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            typeLabel.widthAnchor.constraint(equalToConstant: 100),
            typeLabel.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    // MARK: - Configuration
    func configure(with spot: ParkingSpotModel) {
        spotIdLabel.text = "Spot #\(spot.parkingSpotID)"
        areaLabel.text = spot.areaName
        streetLabel.text = spot.streetName
        
        switch spot.type {
        case "yellow":
            typeLabel.text = "Yellow Zone"
            typeLabel.backgroundColor = .systemYellow.withAlphaComponent(0.2)
            typeLabel.textColor = .systemYellow
        case "green":
            typeLabel.text = "Green Zone"
            typeLabel.backgroundColor = .systemGreen.withAlphaComponent(0.2)
            typeLabel.textColor = .systemGreen
        case "red":
            typeLabel.text = "Red Zone"
            typeLabel.backgroundColor = .systemRed.withAlphaComponent(0.2)
            typeLabel.textColor = .systemRed
        case "disable":
            typeLabel.text = "Disable Zone"
            typeLabel.backgroundColor = .systemBlue.withAlphaComponent(0.2)
            typeLabel.textColor = .systemBlue
        default:
            break
        }
    }
}
