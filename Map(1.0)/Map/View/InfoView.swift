//
//  InfoView.swift
//  Map(1.0)
//
//  Created by Wei Kang Tan on 21/10/2024.
//

import UIKit


class InfoView: UIView {
    private let titleLabel = UILabel()
    private let iconImageView = UIImageView()
    private let valueLabel = UILabel()
    
    init(title: String, icon: UIImage?, value: String, iconColor: UIColor, valueColor: UIColor) {
        super.init(frame: .zero)
        setupView(title: title, icon: icon, value: value, iconColor: iconColor, valueColor: valueColor)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView(title: String, icon: UIImage?, value: String, iconColor: UIColor, valueColor: UIColor) {
        translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        titleLabel.textColor = .gray
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textAlignment = .center
        
        iconImageView.image = icon
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = iconColor
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        
        valueLabel.text = value
        valueLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        valueLabel.textColor = valueColor
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let iconValueStack = UIStackView(arrangedSubviews: [iconImageView, valueLabel])
        iconValueStack.axis = .horizontal
        iconValueStack.spacing = 4
        iconValueStack.alignment = .center
        iconValueStack.translatesAutoresizingMaskIntoConstraints = false
        
        let mainStack = UIStackView(arrangedSubviews: [titleLabel, iconValueStack])
        mainStack.axis = .vertical
        mainStack.spacing = 4
        mainStack.alignment = .center
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(mainStack)
        
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: topAnchor),
            mainStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            mainStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            mainStack.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            iconImageView.widthAnchor.constraint(equalToConstant: 20),
            iconImageView.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
}
