//
//  SimplifiedParkingStartViewController.swift
//  Map(1.0)
//
//  Created by Wei Kang Tan on 18/11/2024.
//


import UIKit

class ParkingStartViewController: UIViewController {

    // MARK: - UI Components
    private lazy var headerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBlue
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Start Parking"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Spot #123 • Api-Api Center"
        label.font = .systemFont(ofSize: 14)
        label.textColor = .white.withAlphaComponent(0.8)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var vehicleSelectionView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(vehicleSelectionTapped))
        view.addGestureRecognizer(tapGesture)
        return view
    }()
    
    private lazy var vehicleIconContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBlue.withAlphaComponent(0.1)
        view.layer.cornerRadius = 20
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var vehicleIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "car.fill")
        imageView.tintColor = .systemBlue
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var vehicleLabel: UILabel = {
        let label = UILabel()
        label.text = "Select Vehicle"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var vehicleSubtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Tap to choose"
        label.font = .systemFont(ofSize: 14)
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var chevronIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "chevron.right")
        imageView.tintColor = .systemGray3
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var durationLabel: UILabel = {
        let label = UILabel()
        label.text = "Duration"
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var durationValueLabel: UILabel = {
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
        // Add both continuous and end-of-slide handlers
        slider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        slider.addTarget(self, action: #selector(sliderDidEndSliding), for: [.touchUpInside, .touchUpOutside])
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()
    
    private lazy var minDurationLabel: UILabel = {
        let label = UILabel()
        label.text = "30min"
        label.font = .systemFont(ofSize: 12)
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var maxDurationLabel: UILabel = {
        let label = UILabel()
        label.text = "8h"
        label.font = .systemFont(ofSize: 12)
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var continueButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Continue", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(continueButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private func updateContinueButtonState() {
        let isEnabled = hasSetupVehicle
        continueButton.isEnabled = isEnabled
        continueButton.backgroundColor = isEnabled ? .systemBlue : .systemGray3
    }
    
    private let sessionManager = SessionManager()
    private let parkingSpotModel: ParkingSpotModel
    private var selectedVehicle: VehicleModel?
    private var hasSetupVehicle: Bool = false
    
    init(parkingSpotModel: ParkingSpotModel) {
        self.parkingSpotModel = parkingSpotModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateContinueButtonState()
        navigationItem.title = "Start Session"
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .never
        let parkingSpotID = parkingSpotModel.parkingSpotID
        let areaName = parkingSpotModel.areaName
        subtitleLabel.text = "Spot: \(parkingSpotID) • \(areaName)"
        sessionManager.delegate = self
        switch parkingSpotModel.type {
        case "green":
            headerView.backgroundColor = .systemGreen
            durationSlider.maximumValue = 720
            maxDurationLabel.text = "12h"
        case "yellow":
            headerView.backgroundColor = .systemYellow
            durationSlider.maximumValue = 480
            maxDurationLabel.text = "8h"
        case "red":
            headerView.backgroundColor = .systemRed
            durationSlider.maximumValue = 120
            maxDurationLabel.text = "2h"
        case "disable":
            headerView.backgroundColor = .systemBlue
            durationSlider.maximumValue = 720
            maxDurationLabel.text = "12h"
        default:
            break
        }
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .white
        
        // Add subviews
        view.addSubview(headerView)
        headerView.addSubview(titleLabel)
        headerView.addSubview(subtitleLabel)
        view.addSubview(continueButton)
        
        view.addSubview(vehicleSelectionView)
        vehicleSelectionView.addSubview(vehicleIconContainer)
        vehicleIconContainer.addSubview(vehicleIcon)
        vehicleSelectionView.addSubview(vehicleLabel)
        vehicleSelectionView.addSubview(vehicleSubtitleLabel)
        vehicleSelectionView.addSubview(chevronIcon)
        
        view.addSubview(durationLabel)
        view.addSubview(durationValueLabel)
        view.addSubview(durationSlider)
        view.addSubview(minDurationLabel)
        view.addSubview(maxDurationLabel)
        
        NSLayoutConstraint.activate([
            // Header
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 80),
            
            titleLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 24),
            titleLabel.bottomAnchor.constraint(equalTo: subtitleLabel.topAnchor, constant: -4),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            subtitleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 24),
            subtitleLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -24),
            
            // Vehicle Selection
            vehicleSelectionView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 24),
            vehicleSelectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            vehicleSelectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            vehicleSelectionView.heightAnchor.constraint(equalToConstant: 80),
            
            vehicleIconContainer.leadingAnchor.constraint(equalTo: vehicleSelectionView.leadingAnchor, constant: 16),
            vehicleIconContainer.centerYAnchor.constraint(equalTo: vehicleSelectionView.centerYAnchor),
            vehicleIconContainer.widthAnchor.constraint(equalToConstant: 40),
            vehicleIconContainer.heightAnchor.constraint(equalToConstant: 40),
            
            vehicleIcon.centerXAnchor.constraint(equalTo: vehicleIconContainer.centerXAnchor),
            vehicleIcon.centerYAnchor.constraint(equalTo: vehicleIconContainer.centerYAnchor),
            vehicleIcon.widthAnchor.constraint(equalToConstant: 24),
            vehicleIcon.heightAnchor.constraint(equalToConstant: 24),
            
            vehicleLabel.leadingAnchor.constraint(equalTo: vehicleIconContainer.trailingAnchor, constant: 12),
            vehicleLabel.topAnchor.constraint(equalTo: vehicleIconContainer.topAnchor),
            
            vehicleSubtitleLabel.leadingAnchor.constraint(equalTo: vehicleIconContainer.trailingAnchor, constant: 12),
            vehicleSubtitleLabel.bottomAnchor.constraint(equalTo: vehicleIconContainer.bottomAnchor),
            
            chevronIcon.trailingAnchor.constraint(equalTo: vehicleSelectionView.trailingAnchor, constant: -16),
            chevronIcon.centerYAnchor.constraint(equalTo: vehicleSelectionView.centerYAnchor),
            chevronIcon.widthAnchor.constraint(equalToConstant: 20),
            chevronIcon.heightAnchor.constraint(equalToConstant: 20),
            
            // Duration Controls
            durationLabel.topAnchor.constraint(equalTo: vehicleSelectionView.bottomAnchor, constant: 32),
            durationLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            
            durationValueLabel.centerYAnchor.constraint(equalTo: durationLabel.centerYAnchor),
            durationValueLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            
            durationSlider.topAnchor.constraint(equalTo: durationLabel.bottomAnchor, constant: 16),
            durationSlider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            durationSlider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            
            minDurationLabel.topAnchor.constraint(equalTo: durationSlider.bottomAnchor, constant: 8),
            minDurationLabel.leadingAnchor.constraint(equalTo: durationSlider.leadingAnchor),
            
            maxDurationLabel.topAnchor.constraint(equalTo: durationSlider.bottomAnchor, constant: 8),
            maxDurationLabel.trailingAnchor.constraint(equalTo: durationSlider.trailingAnchor),
            
            continueButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            continueButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            continueButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            continueButton.heightAnchor.constraint(equalToConstant: 46)
        ])
    }
    
    // MARK: - Actions
    
    @objc private func vehicleSelectionTouchDown() {
        UIView.animate(withDuration: 0.1) {
            self.vehicleSelectionView.backgroundColor = .systemGray5
        }
    }
    
    @objc private func vehicleSelectionTouchUp() {
        UIView.animate(withDuration: 0.1) {
            self.vehicleSelectionView.backgroundColor = .systemGray6
        }
    }
    
    @objc private func vehicleSelectionTapped() {
        let vehicleVC = VehicleViewController()
        vehicleVC.delegate = self
        navigationController?.pushViewController(vehicleVC, animated: true)
        print("Vehicle selection tapped")
    }
    
    @objc private func sliderValueChanged(_ sender: UISlider) {
        // Round to nearest 30 minutes while sliding
        let step: Float = 30
        let roundedValue = round(sender.value / step) * step
        
        // Update label with current value
        updateDurationLabel(minutes: Int(roundedValue))
    }
    
    @objc private func sliderDidEndSliding(_ sender: UISlider) {
        // Round to nearest 30 minutes when sliding ends
        let step: Float = 30
        let roundedValue = round(sender.value / step) * step
        
        // Animate slider to rounded value
        UIView.animate(withDuration: 0.2) {
            sender.setValue(roundedValue, animated: true)
        }
        
        // Update label with final value
        updateDurationLabel(minutes: Int(roundedValue))
    }
    
    private func updateDurationLabel(minutes: Int) {
        let hours = minutes / 60
        let remainingMinutes = minutes % 60
        
        if hours > 0 {
            durationValueLabel.text = remainingMinutes > 0 ?
            "\(hours)h \(remainingMinutes)min" :
            "\(hours)h"
        } else {
            durationValueLabel.text = "\(minutes)min"
        }
    }
    
    @objc private func continueButtonTapped() {
        print("Continue button tapped")
        guard let duration = durationValueLabel.text else {return}
        sessionManager.calculateParkingCost(parkingSpotModel: parkingSpotModel, duration: duration)
    }
    
    private func updateVehicleSelectionAppearance() {
        if hasSetupVehicle, let vehicle = selectedVehicle {
            vehicleLabel.text = vehicle.plateNumber
            vehicleSubtitleLabel.text = "\(vehicle.description) (\(vehicle.color))"
            vehicleLabel.textColor = .label
            vehicleIconContainer.backgroundColor = .systemBlue.withAlphaComponent(0.2)
            vehicleIcon.tintColor = .systemBlue
        } else {
            vehicleLabel.text = "Select Vehicle"
            vehicleSubtitleLabel.text = "Tap to choose"
            vehicleLabel.textColor = .systemGray
            vehicleIconContainer.backgroundColor = .systemGray6
            vehicleIcon.tintColor = .systemGray
        }
    }
}

extension ParkingStartViewController: VehicleViewControllerDelegate {
    func didSelectedVehicleRow(_ vehicleModel: VehicleModel) {
        selectedVehicle = vehicleModel
        hasSetupVehicle = true
        updateVehicleSelectionAppearance()
        updateContinueButtonState()
        
        // Pop back to the previous view controller since we used push
        navigationController?.popViewController(animated: true)
        
        // Add selection feedback
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5) {
            self.vehicleSelectionView.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
        } completion: { _ in
            UIView.animate(withDuration: 0.2) {
                self.vehicleSelectionView.transform = .identity
            }
        }
    }
}

extension ParkingStartViewController: SessionManagerDelegate {
    func didStartSession(_ session: SessionResponse) {
        print("hello")
    }
    
    func didCalculatedParkingCost(_ parkingCostModel: ParkingCostModel) {
        guard let selectedVehicle = self.selectedVehicle else { return }
        DispatchQueue.main.async {
            let vc = CheckoutViewController(parkingSpotModel: self.parkingSpotModel, selectedVehicle: selectedVehicle, parkingCostModel: parkingCostModel)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

//#Preview {
//    let parkingSpotModel = ParkingSpotModel(parkingSpotID: 32, isAvailable: true, type: "red", latitude: 3.2342, longitude: 104.232, streetName: "Jalan 1", areaName: "Kingfisher", distance: 10.3)
//    ParkingStartViewController(parkingSpotModel: parkingSpotModel)
//}
