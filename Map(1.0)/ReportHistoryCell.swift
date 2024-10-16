import UIKit

class ReportHistoryCell: UITableViewCell {
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
    
    private let warningIcon: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(systemName: "exclamationmark.triangle.fill")
        image.tintColor = .systemRed
        image.contentMode = .scaleAspectFit
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    private let typeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let infoStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .leading
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let reportIdLabel: UILabel = {
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
    
    private let statusLabel: PaddedLabel = {
        let label = PaddedLabel()
        label.font = .systemFont(ofSize: 15)
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = UIColor.systemGray6
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
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
        containerView.addSubview(warningIcon)
        containerView.addSubview(typeLabel)
        containerView.addSubview(infoStack)
        containerView.addSubview(dateLabel)
        containerView.addSubview(statusLabel)
        
        // Add items to info stack
        infoStack.addArrangedSubview(reportIdLabel)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            
            warningIcon.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            warningIcon.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            warningIcon.widthAnchor.constraint(equalToConstant: 20),
            warningIcon.heightAnchor.constraint(equalToConstant: 20),
            
            dateLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            dateLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            typeLabel.topAnchor.constraint(equalTo: warningIcon.bottomAnchor, constant: 12),
            typeLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            
            infoStack.topAnchor.constraint(equalTo: typeLabel.bottomAnchor, constant: 4),
            infoStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            infoStack.trailingAnchor.constraint(lessThanOrEqualTo: statusLabel.leadingAnchor, constant: -8),
            infoStack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
            
            statusLabel.centerYAnchor.constraint(equalTo: reportIdLabel.centerYAnchor),
            statusLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
        ])
    }
    
    func configure(type: String, reportId: String, status: String, date: String) {
        typeLabel.text = type
        reportIdLabel.text = "#" + reportId
        dateLabel.text = date
        statusLabel.text = status
        
        // Configure status color and style based on status type
        switch status.lowercased() {
        case "in progress":
            statusLabel.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
            statusLabel.textColor = .systemBlue
        case "resolved":
            statusLabel.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.1)
            statusLabel.textColor = .systemGreen
        case "under review":
            statusLabel.backgroundColor = UIColor.orange.withAlphaComponent(0.1)
            statusLabel.textColor = .orange
        default:
            statusLabel.backgroundColor = UIColor.systemGray.withAlphaComponent(0.1)
            statusLabel.textColor = .systemGray
        }
    }
}

// Custom label with padding for status
class PaddedLabel: UILabel {
    private var padding = UIEdgeInsets(top: 4, left: 12, bottom: 4, right: 12)
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: padding))
    }
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + padding.left + padding.right,
                     height: size.height + padding.top + padding.bottom)
    }
}
