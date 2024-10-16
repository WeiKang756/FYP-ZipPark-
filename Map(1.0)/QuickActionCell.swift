//
//  QuickActionCell.swift
//  Map(1.0)
//
//  Created by Wei Kang Tan on 22/11/2024.
//
import UIKit

protocol QuickActionCellDelegate: AnyObject {
    func didTapQuickAction(at index: Int)
}

class QuickActionCell: UITableViewCell {
    
    var delegate: QuickActionCellDelegate?
    
    private let gridView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
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
        contentView.addSubview(gridView)
        
        NSLayoutConstraint.activate([
            gridView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            gridView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            gridView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            gridView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    private func createActionButton(title: String, subtitle: String, iconName: String, index: Int) -> UIView {
        // Create the container as before
        let container = UIView()
        container.backgroundColor = .white
        container.layer.cornerRadius = 12
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOffset = CGSize(width: 0, height: 2)
        container.layer.shadowRadius = 4
        container.layer.shadowOpacity = 0.1
        container.translatesAutoresizingMaskIntoConstraints = false
        
        // Add tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(actionTapped(_:)))
        container.addGestureRecognizer(tapGesture)
        container.isUserInteractionEnabled = true
        
        // Store the index in the container's tag
        container.tag = index
        
        // Add visual feedback for taps
        let feedbackView = UIView()
        feedbackView.backgroundColor = .clear
        feedbackView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(feedbackView)
        
        // Rest of your existing UI setup...
        let imageView = UIImageView(image: UIImage(systemName: iconName))
        imageView.tintColor = .black
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitle
        subtitleLabel.font = .systemFont(ofSize: 12)
        subtitleLabel.textColor = .systemGray
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(feedbackView)
        container.addSubview(imageView)
        container.addSubview(titleLabel)
        container.addSubview(subtitleLabel)
        
        NSLayoutConstraint.activate([
            feedbackView.topAnchor.constraint(equalTo: container.topAnchor),
            feedbackView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            feedbackView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            feedbackView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            
            imageView.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            imageView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            imageView.widthAnchor.constraint(equalToConstant: 24),
            imageView.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            subtitleLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16)
        ])
        
        return container
    }
    
    @objc private func actionTapped(_ gesture: UITapGestureRecognizer) {
        guard let view = gesture.view else { return }
        
        // Animate the tap
        UIView.animate(withDuration: 0.1, animations: {
            view.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            view.alpha = 0.7
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                view.transform = .identity
                view.alpha = 1.0
            }
        }
        
        // Add haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        // Notify delegate
        delegate?.didTapQuickAction(at: view.tag)
    }
    
    func configure(with actions: [(String, String, String)]) {
        // Remove existing subviews
        gridView.subviews.forEach { $0.removeFromSuperview() }
        
        // Create grid layout
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        gridView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: gridView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: gridView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: gridView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: gridView.bottomAnchor)
        ])
        
        // Create rows
        for row in 0...1 {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.distribution = .fillEqually
            rowStack.spacing = 16
            
            for col in 0...2 {
                let index = row * 3 + col
                if index < actions.count {
                    let action = actions[index]
                    let button = createActionButton(
                        title: action.0,
                        subtitle: action.1,
                        iconName: action.2,
                        index: index
                    )
                    rowStack.addArrangedSubview(button)
                }
            }
            
            stackView.addArrangedSubview(rowStack)
        }
    }
}
