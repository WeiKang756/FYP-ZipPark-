//
//  FloatingPanel.swift
//  Map(1.0)
//
//  Created by Wei Kang Tan on 21/09/2024.
//

import UIKit

class InfomationPanel: UIView {
    
    // Labels for title and description
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    var button = UIButton()
    var onButtonTap: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    // Initial setup for the floating panel
    private func setupView() {
        self.backgroundColor = .white
        self.layer.cornerRadius = 15
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.3
        self.layer.shadowOffset = CGSize(width: 0, height: -2)
        self.layer.shadowRadius = 5
        self.isHidden = true
        self.translatesAutoresizingMaskIntoConstraints = false
        
        // Setup the title and description labels
        setupLabels()
    }
    
    private func setupLabels() {
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        
        descriptionLabel.font = UIFont.systemFont(ofSize: 14)
        descriptionLabel.textColor = .darkGray
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(descriptionLabel)
        
        button.setTitle("View", for: .normal)
        button.backgroundColor = UIColor.green
        button.layer.cornerRadius = 5
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        addSubview(button)
        
        // Set up constraints for labels
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            
            button.topAnchor.constraint(equalTo: self.bottomAnchor, constant: -50),
            button.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            button.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20)
        ])
    }
    
    // Method to update the content of the panel
    func updateContent(title: String?, description: String?) {
        titleLabel.text = title
        descriptionLabel.text = description ?? "No additional information"
    }
    
    // Show the panel with animation
    func show() {
        self.isHidden = false
        self.alpha = 0
        UIView.animate(withDuration: 0.4) {
            self.alpha = 1
        }
    }
    
    // Hide the panel with animation
    func hide() {
        UIView.animate(withDuration: 0.4, animations: {
            self.alpha = 0
        }) { _ in
            self.isHidden = true
        }
    }
    
    @objc private func buttonTapped() {
        onButtonTap?()
    }
}
