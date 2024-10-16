//
//  StartViewController.swift
//  Map(1.0)
//
//  Created by Wei Kang Tan on 13/11/2024.
//


import UIKit

class StartViewController: UIViewController {
    
    private let goToVehicleButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Go to Vehicles", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupButton()
    }
    
    private func setupButton() {
        view.addSubview(goToVehicleButton)
        goToVehicleButton.addTarget(self, action: #selector(goToVehicleViewController), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            goToVehicleButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            goToVehicleButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    @objc private func goToVehicleViewController() {
        let vehicleVC = VehicleViewController()
        navigationController?.pushViewController(vehicleVC, animated: true)
    }
}
