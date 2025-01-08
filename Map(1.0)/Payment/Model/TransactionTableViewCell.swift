//
//  TransactionTableViewCell.swift
//  Map(1.0)
//
//  Created by Wei Kang Tan on 19/12/2024.
//
import UIKit

class TransactionTableViewCell: UITableViewCell {
    
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
    
    private let transactionIconContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBlue.withAlphaComponent(0.1)
        view.layer.cornerRadius = 20
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let transactionIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemBlue
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let transactionDateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let transactionTypeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let amountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
        containerView.addSubview(transactionIconContainer)
        transactionIconContainer.addSubview(transactionIcon)
        containerView.addSubview(transactionDateLabel)
        containerView.addSubview(transactionTypeLabel)
        containerView.addSubview(amountLabel)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            transactionIconContainer.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            transactionIconContainer.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            transactionIconContainer.widthAnchor.constraint(equalToConstant: 40),
            transactionIconContainer.heightAnchor.constraint(equalToConstant: 40),
            
            transactionIcon.centerXAnchor.constraint(equalTo: transactionIconContainer.centerXAnchor),
            transactionIcon.centerYAnchor.constraint(equalTo: transactionIconContainer.centerYAnchor),
            transactionIcon.widthAnchor.constraint(equalToConstant: 20),
            transactionIcon.heightAnchor.constraint(equalToConstant: 20),
            
            transactionTypeLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            transactionTypeLabel.leadingAnchor.constraint(equalTo: transactionIconContainer.trailingAnchor, constant: 12),
            
            transactionDateLabel.topAnchor.constraint(equalTo: transactionTypeLabel.bottomAnchor, constant: 4),
            transactionDateLabel.leadingAnchor.constraint(equalTo: transactionIconContainer.trailingAnchor, constant: 12),
            transactionDateLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
            
            amountLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            amountLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            amountLabel.leadingAnchor.constraint(greaterThanOrEqualTo: transactionTypeLabel.trailingAnchor, constant: 16)
        ])
    }
    
    // MARK: - Configuration
    func configure(with transaction: TransactionModel) {
        transactionDateLabel.text = transaction.date
        transactionTypeLabel.text = transaction.type
        
        let amount = transaction.amount
        // Configure amount label
        amountLabel.text = "RM \(amount)"
        
        // Configure transaction icon
        switch transaction.type.lowercased() {
        case "parking":
            transactionIcon.image = UIImage(systemName: "car.fill")
            transactionIconContainer.backgroundColor = .systemBlue.withAlphaComponent(0.1)
            transactionIcon.tintColor = .systemBlue
        case "topup":
            transactionIcon.image = UIImage(systemName: "plus.circle.fill")
            transactionIconContainer.backgroundColor = .systemGreen.withAlphaComponent(0.1)
            transactionIcon.tintColor = .systemGreen
        case "refund":
            transactionIcon.image = UIImage(systemName: "arrow.triangle.2.circlepath")
            transactionIconContainer.backgroundColor = .systemOrange.withAlphaComponent(0.1)
            transactionIcon.tintColor = .systemOrange
        default:
            transactionIcon.image = UIImage(systemName: "creditcard.fill")
            transactionIconContainer.backgroundColor = .systemGray.withAlphaComponent(0.1)
            transactionIcon.tintColor = .systemGray
        }
    }
}
