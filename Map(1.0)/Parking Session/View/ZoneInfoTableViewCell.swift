//
//  ZoneInfoTableViewCell.swift
//  Map(1.0)
//
//  Created by Wei Kang Tan on 17/11/2024.
//

import UIKit

class ZoneInfoTableViewCell: UITableViewCell {
    static let identifier = "ZoneInfoCell"
    
    // Yellow Zone Title Section
    private let zoneIndicator: UIView = {
        let view = UIView()
        view.backgroundColor = .systemYellow
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let zoneLabel: UILabel = {
        let label = UILabel()
        label.text = "Yellow"
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Rate Section
    let rateContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.1)
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let rateHeaderStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    let infoIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "info.circle.fill")
        imageView.tintColor = .systemGreen
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let rateLabel: UILabel = {
        let label = UILabel()
        label.text = "Rate"
        label.textColor = .systemGreen
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    
    private let rateContentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // Operating Hours and Status Section
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let operatingHoursLabel: UILabel = {
        let label = UILabel()
        label.text = "Parking Type"
        label.textColor = .systemGray
        label.font = .systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let hoursLabel: UILabel = {
        let label = UILabel()
        label.text = "8 AM - 6 PM"
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let statusContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let currentStatusLabel: UILabel = {
        let label = UILabel()
        label.text = "Current Status"
        label.textColor = .systemGray
        label.font = .systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let availableLabel: UILabel = {
        let label = UILabel()
        label.text = "Available"
        label.textColor = .systemGreen
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private func createRateRow(hours: String, rate: String) -> UIStackView {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        
        let hoursLabel = UILabel()
        hoursLabel.text = hours
        hoursLabel.font = .systemFont(ofSize: 17)
        
        let rateLabel = UILabel()
        rateLabel.text = rate
        rateLabel.font = .systemFont(ofSize: 17)
        rateLabel.textAlignment = .right
        
        stack.addArrangedSubview(hoursLabel)
        stack.addArrangedSubview(rateLabel)
        
        return stack
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.backgroundColor = .white
        
//        // Add zone title section
//        contentView.addSubview(zoneIndicator)
//        contentView.addSubview(zoneLabel)
//        
        // Add rate section
        contentView.addSubview(rateContainer)
        
        rateHeaderStack.addArrangedSubview(infoIcon)
        rateHeaderStack.addArrangedSubview(rateLabel)
        rateContainer.addSubview(rateHeaderStack)
        
        let firstRow = createRateRow(hours: "First 4 Hour", rate: "RM 0.53/30 min")
        let secondRow = createRateRow(hours: "First 4 Hour", rate: "RM 1.06/30 min")
        
        rateContentStack.addArrangedSubview(firstRow)
        rateContentStack.addArrangedSubview(secondRow)
        rateContainer.addSubview(rateContentStack)
        
        // Add hours and status section
        contentView.addSubview(containerView)
        contentView.addSubview(statusContainer)
        
        containerView.addSubview(operatingHoursLabel)
        containerView.addSubview(zoneLabel)
        
        statusContainer.addSubview(currentStatusLabel)
        statusContainer.addSubview(availableLabel)
        
        NSLayoutConstraint.activate([
            // Status container constraints
            statusContainer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            statusContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            statusContainer.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.45, constant: -24),
            statusContainer.heightAnchor.constraint(equalToConstant: 60),
            
            currentStatusLabel.topAnchor.constraint(equalTo: statusContainer.topAnchor, constant: 8),
            currentStatusLabel.leadingAnchor.constraint(equalTo: statusContainer.leadingAnchor, constant: 12),
            
            availableLabel.topAnchor.constraint(equalTo: currentStatusLabel.bottomAnchor, constant: 4),
            availableLabel.leadingAnchor.constraint(equalTo: statusContainer.leadingAnchor, constant: 12),
            
            //zone indicator
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.45, constant: -24),
            containerView.heightAnchor.constraint(equalToConstant: 60),
            
            operatingHoursLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            operatingHoursLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            
            // Fixed zoneIndicator constraints
            zoneLabel.topAnchor.constraint(equalTo: operatingHoursLabel.bottomAnchor, constant: 4),
            zoneLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),

            // Rate container constraints
            rateContainer.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 16),
            rateContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            rateContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            rateContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            
            rateHeaderStack.topAnchor.constraint(equalTo: rateContainer.topAnchor, constant: 16),
            rateHeaderStack.leadingAnchor.constraint(equalTo: rateContainer.leadingAnchor, constant: 16),
            
            infoIcon.widthAnchor.constraint(equalToConstant: 20),
            infoIcon.heightAnchor.constraint(equalToConstant: 20),
            
            // Fixed this constraint - changed from containerView to rateHeaderStack
            rateContentStack.topAnchor.constraint(equalTo: rateHeaderStack.bottomAnchor, constant: 16),
            rateContentStack.leadingAnchor.constraint(equalTo: rateContainer.leadingAnchor, constant: 16),
            rateContentStack.trailingAnchor.constraint(equalTo: rateContainer.trailingAnchor, constant: -16),
            rateContentStack.bottomAnchor.constraint(equalTo: rateContainer.bottomAnchor, constant: -16),
        ])
    }
    
    func configure(firstRate: String, firstHours: String, secondRate: String? = nil, secondHours: String? = nil) {
        // Clear existing rate rows
        rateContentStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        if let secondRate = secondRate, let secondHours = secondHours {
            // Two different rates - show both rows
            let firstRow = createRateRow(hours: firstHours, rate: firstRate)
            let secondRow = createRateRow(hours: secondHours, rate: secondRate)
            rateContentStack.addArrangedSubview(firstRow)
            rateContentStack.addArrangedSubview(secondRow)
        } else {
            // Single rate - show only one row
            let rateRow = createRateRow(hours: firstHours, rate: firstRate)
            rateContentStack.addArrangedSubview(rateRow)
        }
    }
}
