//
//  ParkingHistoryCell.swift
//  Map(1.0)
//
//  Created by Wei Kang Tan on 18/12/2024.
//
import UIKit

// MARK: - Custom Cells
class ParkingHistoryCell: UITableViewCell {
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.05
        view.layer.shadowRadius = 4
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let carIcon: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(systemName: "car.fill")
        image.tintColor = .black
        image.contentMode = .scaleAspectFit
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    private let locationLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let infoStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 4
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let plateNumberLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let timeAndCostLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.textColor = .systemGray
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.textColor = .systemGreen
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        
        contentView.addSubview(containerView)
        containerView.addSubview(carIcon)
        containerView.addSubview(locationLabel)
        containerView.addSubview(plateNumberLabel)
        containerView.addSubview(timeAndCostLabel)
        containerView.addSubview(dateLabel)
        containerView.addSubview(statusLabel)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            
            carIcon.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            carIcon.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            carIcon.widthAnchor.constraint(equalToConstant: 20),
            carIcon.heightAnchor.constraint(equalToConstant: 20),
            
            dateLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            dateLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            locationLabel.topAnchor.constraint(equalTo: carIcon.bottomAnchor, constant: 12),
            locationLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            
            plateNumberLabel.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 4),
            plateNumberLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            
            timeAndCostLabel.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 4),
            timeAndCostLabel.leadingAnchor.constraint(equalTo: plateNumberLabel.trailingAnchor, constant: 8),
            timeAndCostLabel.trailingAnchor.constraint(lessThanOrEqualTo: statusLabel.leadingAnchor, constant: -8),
            timeAndCostLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
            
            statusLabel.centerYAnchor.constraint(equalTo: timeAndCostLabel.centerYAnchor),
            statusLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
        ])
    }
    
    func configure(location: String, plateNumber: String, duration: String, cost: String, status: String, date: String) {
        locationLabel.text = location
        plateNumberLabel.text = plateNumber
        timeAndCostLabel.text = "• RM \(cost)"
        dateLabel.text = date
        statusLabel.text = status
        statusLabel.textColor = status.lowercased() == "completed" ? .systemGreen : .systemGray
    }
}
