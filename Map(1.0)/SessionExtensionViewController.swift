//
//  SessionExtensionViewControllerDelegate.swift
//  Map(1.0)
//
//  Created by Wei Kang Tan on 09/01/2025.
//
import UIKit

protocol SessionExtensionViewControllerDelegate: AnyObject {
    func didSelectExtension(duration: String, estimatedCost: Double)
}

class SessionExtensionViewController: UIViewController {
    // MARK: - UI Components
    private let headerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBlue
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Extend Session"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Select additional time"
        label.font = .systemFont(ofSize: 16)
        label.textColor = .white.withAlphaComponent(0.8)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let durationLabel: UILabel = {
        let label = UILabel()
        label.text = "Duration"
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let durationValueLabel: UILabel = {
        let label = UILabel()
        label.text = "2h selected"
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .systemBlue
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var durationSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 30
        slider.maximumValue = 480
        slider.value = 120 // 2 hours default
        slider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        slider.addTarget(self, action: #selector(sliderDidEndSliding), for: [.touchUpInside, .touchUpOutside])
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()
    
    private let minDurationLabel: UILabel = {
        let label = UILabel()
        label.text = "30min"
        label.font = .systemFont(ofSize: 12)
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let maxDurationLabel: UILabel = {
        let label = UILabel()
        label.text = "8h"
        label.font = .systemFont(ofSize: 12)
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let costLabel: UILabel = {
        let label = UILabel()
        label.text = "Estimated Cost"
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let costValueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .label
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var confirmButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Confirm Extension", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.layer.cornerRadius = 12
        button.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Properties
    private let parkingType: String
    weak var delegate: SessionExtensionViewControllerDelegate?
    private var selectedDuration: String = "PT2H"
    private var estimatedCost: Double = 0.0
    
    init(parkingType: String) {
        self.parkingType = parkingType
        super.init(nibName: nil, bundle: nil)
        setupMaxDuration()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateCostEstimate()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(headerView)
        headerView.addSubview(titleLabel)
        headerView.addSubview(subtitleLabel)
        
        view.addSubview(durationLabel)
        view.addSubview(durationValueLabel)
        view.addSubview(durationSlider)
        view.addSubview(minDurationLabel)
        view.addSubview(maxDurationLabel)
        
        view.addSubview(costLabel)
        view.addSubview(costValueLabel)
        view.addSubview(confirmButton)
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 100),
            
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            titleLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 20),
            
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            
            durationLabel.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 32),
            durationLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            durationValueLabel.centerYAnchor.constraint(equalTo: durationLabel.centerYAnchor),
            durationValueLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            durationSlider.topAnchor.constraint(equalTo: durationLabel.bottomAnchor, constant: 16),
            durationSlider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            durationSlider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            minDurationLabel.topAnchor.constraint(equalTo: durationSlider.bottomAnchor, constant: 8),
            minDurationLabel.leadingAnchor.constraint(equalTo: durationSlider.leadingAnchor),
            
            maxDurationLabel.topAnchor.constraint(equalTo: durationSlider.bottomAnchor, constant: 8),
            maxDurationLabel.trailingAnchor.constraint(equalTo: durationSlider.trailingAnchor),
            
            costLabel.topAnchor.constraint(equalTo: maxDurationLabel.bottomAnchor, constant: 32),
            costLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            costValueLabel.topAnchor.constraint(equalTo: costLabel.bottomAnchor, constant: 8),
            costValueLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            confirmButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            confirmButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            confirmButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            confirmButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // Set initial cost value
        updateCostEstimate()
    }
    
    private func setupMaxDuration() {
        switch parkingType {
        case "red":
            durationSlider.maximumValue = 60 // 1 hour max extension for red zone
            maxDurationLabel.text = "1h"
        case "yellow":
            durationSlider.maximumValue = 240 // 4 hours max extension for yellow zone
            maxDurationLabel.text = "4h"
        case "green", "disable":
            durationSlider.maximumValue = 720 // 12 hours max extension for green/disable zone
            maxDurationLabel.text = "12h"
        default:
            break
        }
        
        // Set header color based on parking type
        switch parkingType {
        case "yellow":
            headerView.backgroundColor = .systemYellow
        case "green":
            headerView.backgroundColor = .systemGreen
        case "red":
            headerView.backgroundColor = .systemRed
        case "disable":
            headerView.backgroundColor = .systemBlue
        default:
            break
        }
    }
    
    // MARK: - Actions
    @objc private func sliderValueChanged(_ sender: UISlider) {
        let step: Float = 30
        let roundedValue = round(sender.value / step) * step
        updateDurationLabel(minutes: Int(roundedValue))
        selectedDuration = formatDuration(minutes: Int(roundedValue))
        updateCostEstimate()
    }
    
    @objc private func sliderDidEndSliding(_ sender: UISlider) {
        let step: Float = 30
        let roundedValue = round(sender.value / step) * step
        
        UIView.animate(withDuration: 0.2) {
            sender.setValue(roundedValue, animated: true)
        }
        
        updateDurationLabel(minutes: Int(roundedValue))
        selectedDuration = formatDuration(minutes: Int(roundedValue))
        updateCostEstimate()
    }
    
    @objc private func confirmButtonTapped() {
        delegate?.didSelectExtension(duration: selectedDuration, estimatedCost: estimatedCost)
        dismiss(animated: true)
    }
    
    // MARK: - Helpers
    private func updateDurationLabel(minutes: Int) {
        let hours = minutes / 60
        let remainingMinutes = minutes % 60
        
        if hours > 0 {
            durationValueLabel.text = remainingMinutes > 0 ?
                "\(hours)h \(remainingMinutes)min selected" :
                "\(hours)h selected"
        } else {
            durationValueLabel.text = "\(minutes)min selected"
        }
    }
    
    private func formatDuration(minutes: Int) -> String {
        let hours = minutes / 60
        let remainingMinutes = minutes % 60
        return "PT\(hours)H\(remainingMinutes)M"
    }
    
    private func updateCostEstimate() {
        let minutes = Int(durationSlider.value)
        let cost = calculateCost(minutes: minutes)
        estimatedCost = cost
        costValueLabel.text = String(format: "RM %.2f", cost)
    }
    
    private func calculateCost(minutes: Int) -> Double {
        let thirtyMinuteBlocks = Int(ceil(Double(minutes) / 30.0))
        
        switch parkingType {
        case "green":
            // RM 0.53 per hour
            return Double(minutes) / 60.0 * 0.53
        case "yellow":
            // RM 0.53 per 30 minutes for first 4 hours
            // RM 1.06 per 30 minutes after 4 hours
            if minutes <= 240 { // 4 hours
                return Double(thirtyMinuteBlocks) * 0.53
            } else {
                let firstFourHoursBlocks = 8 // 4 hours = 8 blocks of 30 minutes
                let remainingBlocks = thirtyMinuteBlocks - firstFourHoursBlocks
                return (Double(firstFourHoursBlocks) * 0.53) + (Double(remainingBlocks) * 1.06)
            }
        case "red":
            // RM 1.06 per 30 minutes for first hour
            // RM 2.12 per 30 minutes for second hour
            if minutes <= 60 { // 1 hour
                return Double(thirtyMinuteBlocks) * 1.06
            } else {
                let firstHourBlocks = 2 // 1 hour = 2 blocks of 30 minutes
                let remainingBlocks = thirtyMinuteBlocks - firstHourBlocks
                return (Double(firstHourBlocks) * 1.06) + (Double(remainingBlocks) * 2.12)
            }
        case "disable":
            return 0.0 // Free parking for disabled spots
        default:
            return 0.0
        }
    }
}
