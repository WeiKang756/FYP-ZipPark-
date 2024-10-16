//
//  FilterButton.swift
//  Map(1.0)
//
//  Created by Wei Kang Tan on 24/10/2024.
//

import UIKit


class FilterButton: UIButton {
    // MARK: - Properties
    private let arrowImageView: UIImageView = {
        let imageView = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)
        imageView.image = UIImage(systemName: "chevron.down", withConfiguration: config)
        imageView.tintColor = .black
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // MARK: - Initialization
    init(title: String) {
        super.init(frame: .zero)
        setupButton(with: title)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupButton(with title: String) {
        // Basic button setup
        setTitle(title, for: .normal)
        setTitleColor(.black, for: .normal)
        titleLabel?.font = .systemFont(ofSize: 16)
        backgroundColor = .systemBackground
        
        // Pill shape
        layer.cornerRadius = 20  // Adjust for desired roundness
        layer.borderWidth = 1
        layer.borderColor = UIColor.systemGray5.cgColor
        
        // Add padding
        contentEdgeInsets = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 36)
        
        // Add arrow image
        addSubview(arrowImageView)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            arrowImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            arrowImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            arrowImageView.widthAnchor.constraint(equalToConstant: 12),
            arrowImageView.heightAnchor.constraint(equalToConstant: 12)
        ])
    }
}
