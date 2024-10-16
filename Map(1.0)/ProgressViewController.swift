import UIKit

class ProgressViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.systemGray6
        
        // Set up the main container view for the progress indicator
        let progressContainerView = UIView()
        progressContainerView.backgroundColor = .white
        progressContainerView.layer.cornerRadius = 20
        progressContainerView.layer.shadowColor = UIColor.black.cgColor
        progressContainerView.layer.shadowOpacity = 0.1
        progressContainerView.layer.shadowOffset = CGSize(width: 0, height: 4)
        progressContainerView.layer.shadowRadius = 8
        progressContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(progressContainerView)
        
        NSLayoutConstraint.activate([
            progressContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            progressContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            progressContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            progressContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            progressContainerView.heightAnchor.constraint(equalToConstant: 150)
        ])
        
        // Create the stack view to hold step views
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        progressContainerView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: progressContainerView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: progressContainerView.trailingAnchor, constant: -20),
            stackView.topAnchor.constraint(equalTo: progressContainerView.topAnchor, constant: 20),
            stackView.bottomAnchor.constraint(equalTo: progressContainerView.bottomAnchor, constant: -20)
        ])
        
        // Create steps for the progress view
        for index in 0..<4 {
            let stepView = UIView()
            
            // Create step circle view
            let circleView = StepCircleView()
            circleView.status = index == 0 ? .completed : (index == 1 ? .inProgress : .pending)
            stepView.addSubview(circleView)
            
            // Create step label
            let stepLabel = UILabel()
            stepLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
            stepLabel.textColor = .darkGray
            stepLabel.numberOfLines = 0
            stepLabel.textAlignment = .center
            
            // Set label text based on status
            switch circleView.status {
            case .completed:
                stepLabel.text = "Step \(index + 1)\nCompleted"
                stepLabel.textColor = .systemGreen
            case .inProgress:
                stepLabel.text = "Step \(index + 1)\nIn Progress"
                stepLabel.textColor = .systemBlue
            case .pending:
                stepLabel.text = "Step \(index + 1)\nPending"
            }
            
            stepLabel.translatesAutoresizingMaskIntoConstraints = false
            stepView.addSubview(stepLabel)
            
            // Add step view to stack view
            stackView.addArrangedSubview(stepView)
            
            // Layout constraints for the subviews in each stepView
            NSLayoutConstraint.activate([
                circleView.centerXAnchor.constraint(equalTo: stepView.centerXAnchor),
                circleView.topAnchor.constraint(equalTo: stepView.topAnchor),
                
                stepLabel.topAnchor.constraint(equalTo: circleView.bottomAnchor, constant: 8),
                stepLabel.centerXAnchor.constraint(equalTo: stepView.centerXAnchor)
            ])
        }
        
        // Add connecting lines between steps
        for index in 0..<3 {
            let lineView = UIView()
            lineView.backgroundColor = .systemGray3
            lineView.translatesAutoresizingMaskIntoConstraints = false
            progressContainerView.addSubview(lineView)
            
            NSLayoutConstraint.activate([
                lineView.heightAnchor.constraint(equalToConstant: 4),
                lineView.centerYAnchor.constraint(equalTo: stackView.arrangedSubviews[index].centerYAnchor),
                lineView.leadingAnchor.constraint(equalTo: stackView.arrangedSubviews[index].trailingAnchor, constant: -15),
                lineView.trailingAnchor.constraint(equalTo: stackView.arrangedSubviews[index + 1].leadingAnchor, constant: 15)
            ])
        }
    }
}

// MARK: - StepCircleView Implementation

class StepCircleView: UIView {
    enum StepStatus {
        case completed
        case inProgress
        case pending
    }

    var status: StepStatus = .pending {
        didSet {
            switch status {
            case .completed:
                backgroundColor = .systemGreen
                layer.borderColor = UIColor.clear.cgColor
                layer.borderWidth = 0
            case .inProgress:
                backgroundColor = .white
                layer.borderColor = UIColor.systemBlue.cgColor
                layer.borderWidth = 3
            case .pending:
                backgroundColor = .systemGray4
                layer.borderColor = UIColor.clear.cgColor
                layer.borderWidth = 0
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        layer.cornerRadius = 15
        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(equalToConstant: 30).isActive = true
        heightAnchor.constraint(equalToConstant: 30).isActive = true
    }
}
