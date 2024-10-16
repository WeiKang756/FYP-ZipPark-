//
//  CardView.swift
//  Map(1.0)
//
//  Created by Wei Kang Tan on 19/11/2024.
//

import UIKit

class CardView: UIView {
    // MARK: - UI Components
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = .systemBackground
        layer.cornerRadius = 12
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 6
        layer.shadowOpacity = 0.1
        
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }
    
    // MARK: - Configuration
    func configureCard(title: String, iconName: String, content: [CardContent]) {
        // Clear existing content
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Add title
        let titleStack = createTitleStack(title: title, iconName: iconName)
        stackView.addArrangedSubview(titleStack)
        
        // Add content
        content.forEach { content in
            switch content {
            case let row as InfoRow:
                stackView.addArrangedSubview(createInfoRow(row))
            case let grid as GridRow:
                stackView.addArrangedSubview(createGridRow(grid))
            case let section as Section:
                stackView.addArrangedSubview(createSection(section))
            case is Divider:
                stackView.addArrangedSubview(createDivider())
            default:
                break
            }
        }
    }
    
    private func createTitleStack(title: String, iconName: String) -> UIStackView {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        
        let imageView = UIImageView(image: UIImage(systemName: iconName))
        imageView.tintColor = .systemYellow
        imageView.contentMode = .scaleAspectFit
        imageView.widthAnchor.constraint(equalToConstant: 24).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 24).isActive = true
        
        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        
        stack.addArrangedSubview(imageView)
        stack.addArrangedSubview(label)
        
        return stack
    }
    
    private func createInfoRow(_ row: InfoRow) -> UIView {
            let stack = UIStackView()
            stack.axis = .horizontal
            stack.distribution = .equalSpacing
            
            let titleLabel = UILabel()
            titleLabel.text = row.title
            
            switch row.style {
            case .normal:
                titleLabel.font = .systemFont(ofSize: 14)
                titleLabel.textColor = .systemGray
            case .subtitle:
                titleLabel.font = .systemFont(ofSize: 14)
                titleLabel.textColor = .systemGray2
            case .total:
                titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
            case .balance:
                titleLabel.font = .systemFont(ofSize: 20, weight: .semibold)
                titleLabel.textColor = .systemGreen
            case .title:
                titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
            }
            
            stack.addArrangedSubview(titleLabel)
            
            if let value = row.value {
                let valueLabel = UILabel()
                valueLabel.text = value
                valueLabel.textAlignment = .right
                
                switch row.style {
                case .total:
                    valueLabel.font = .systemFont(ofSize: 16, weight: .semibold)
                    valueLabel.textColor = .systemYellow
                default:
                    valueLabel.font = .systemFont(ofSize: 14)
                }
                
                stack.addArrangedSubview(valueLabel)
            }
            
            return stack
        }
        
        private func createGridRow(_ grid: GridRow) -> UIView {
            let stack = UIStackView()
            stack.axis = .horizontal
            stack.distribution = .fillEqually
            stack.spacing = 20
            
            let leftStack = createDetailStack(title: grid.left.title, value: grid.left.value ?? "")
            let rightStack = createDetailStack(title: grid.right.title, value: grid.right.value ?? "")
            
            stack.addArrangedSubview(leftStack)
            stack.addArrangedSubview(rightStack)
            
            return stack
        }
        
        private func createDetailStack(title: String, value: String) -> UIStackView {
            let stack = UIStackView()
            stack.axis = .vertical
            stack.spacing = 4
            
            let titleLabel = UILabel()
            titleLabel.text = title
            titleLabel.font = .systemFont(ofSize: 14)
            titleLabel.textColor = .systemGray
            
            let valueLabel = UILabel()
            valueLabel.text = value
            valueLabel.font = .systemFont(ofSize: 16, weight: .medium)
            
            stack.addArrangedSubview(titleLabel)
            stack.addArrangedSubview(valueLabel)
            
            return stack
        }
        
        private func createSection(_ section: Section) -> UIView {
            let stack = UIStackView()
            stack.axis = .vertical
            stack.spacing = 8
            
            let titleLabel = UILabel()
            titleLabel.text = section.title
            titleLabel.font = .systemFont(ofSize: 14, weight: .medium)
            titleLabel.textColor = .systemGray
            stack.addArrangedSubview(titleLabel)
            
            section.rows.forEach { row in
                stack.addArrangedSubview(createInfoRow(row))
            }
            
            return stack
        }
        
        private func createDivider() -> UIView {
            let divider = UIView()
            divider.backgroundColor = .systemGray5
            divider.heightAnchor.constraint(equalToConstant: 1).isActive = true
            return divider
        }
    }

    // MARK: - Supporting Types
    enum RowStyle {
        case normal
        case subtitle
        case total
        case balance
        case title
    }

    protocol CardContent { }

    struct InfoRow: CardContent {
        let title: String
        let value: String?
        let style: RowStyle
        
        init(title: String, value: String? = nil, style: RowStyle = .normal) {
            self.title = title
            self.value = value
            self.style = style
        }
    }

    struct GridRow: CardContent {
        let left: InfoRow
        let right: InfoRow
    }

    struct Section: CardContent {
        let title: String
        let rows: [InfoRow]
    }

    struct Divider: CardContent { }
