//
//  AresInfomationViewController.swift
//  Map(1.0)
//
//  Created by Wei Kang Tan on 21/10/2024.
//

import UIKit

class AreaInfomationViewController: UIViewController {
    
    let label: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        label.text = "Kingfisher Plaza"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
    }
    
    private func setupView() {
        let titleLabel = UILabel()
        titleLabel.text = "Kingfisher Plaza"
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let infoStackView = UIStackView()
        infoStackView.axis = .horizontal
        infoStackView.distribution = .equalSpacing
        infoStackView.alignment = .center
        infoStackView.translatesAutoresizingMaskIntoConstraints = false
        
        let availableView = InfoView(
            title: "Available",
            icon: UIImage(systemName: "car.fill"),
            value: "10",
            iconColor: .systemGreen,
            valueColor: .systemBlue
        )
        
        let distanceView = InfoView(
            title: "DISTANCE",
            icon: UIImage(systemName: "figure.walk"),
            value: "6.84 KM",
            iconColor: .gray,
            valueColor: .systemBlue
        )
        
        let totalView = InfoView(
            title: "Total",
            icon: UIImage(systemName: "car.fill"),
            value: "200",
            iconColor: .gray,
            valueColor: .systemBlue
        )
        
        infoStackView.addArrangedSubview(availableView)
        infoStackView.addArrangedSubview(distanceView)
        infoStackView.addArrangedSubview(totalView)
        
        view.addSubview(titleLabel)
        view.addSubview(infoStackView)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            infoStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            infoStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            infoStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            infoStackView.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
}


/*
 // MARK: - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
 // Get the new view controller using segue.destination.
 // Pass the selected object to the new view controller.
 }
 */

#Preview {
    AreaInfomationViewController()
}
