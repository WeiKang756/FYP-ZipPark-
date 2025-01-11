//
//  ProfileViewController.swift
//  Map(1.0)
//
//  Created by Wei Kang Tan on 11/01/2025.
//


import UIKit

class ProfileViewController: UIViewController {
    
    // MARK: - UI Components
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .systemGray5
        imageView.layer.cornerRadius = 30
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let initialsLabel: UILabel = {
        let label = UILabel()
        label.text = "TK"
        label.textColor = .systemGray
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Tan Wei Kang"
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.text = "tan@example.com"
        label.font = .systemFont(ofSize: 14)
        label.textColor = .systemGray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let walletCard: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let walletTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Wallet Balance"
        label.font = .systemFont(ofSize: 16)
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let balanceLabel: UILabel = {
        let label = UILabel()
        label.text = "RM 150.00"
        label.font = .systemFont(ofSize: 24, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let topUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Top up", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let menuCard: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var menuStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 0
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let signOutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign Out", for: .normal)
        button.setTitleColor(.systemRed, for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        createMenuItems()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemGray6
        navigationItem.title = "Profile"
        
        // Add subviews
        view.addSubview(profileImageView)
        profileImageView.addSubview(initialsLabel)
        view.addSubview(nameLabel)
        view.addSubview(emailLabel)
        
        view.addSubview(walletCard)
        walletCard.addSubview(walletTitleLabel)
        walletCard.addSubview(balanceLabel)
        walletCard.addSubview(topUpButton)
        
        view.addSubview(menuCard)
        menuCard.addSubview(menuStack)
        
        view.addSubview(signOutButton)
        
        NSLayoutConstraint.activate([
            // Profile Image
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 60),
            profileImageView.heightAnchor.constraint(equalToConstant: 60),
            
            initialsLabel.centerXAnchor.constraint(equalTo: profileImageView.centerXAnchor),
            initialsLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            
            // Name and Email
            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 16),
            nameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            emailLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Wallet Card
            walletCard.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 24),
            walletCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            walletCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            walletCard.heightAnchor.constraint(equalToConstant: 100),
            
            walletTitleLabel.topAnchor.constraint(equalTo: walletCard.topAnchor, constant: 20),
            walletTitleLabel.leadingAnchor.constraint(equalTo: walletCard.leadingAnchor, constant: 20),
            
            balanceLabel.topAnchor.constraint(equalTo: walletTitleLabel.bottomAnchor, constant: 4),
            balanceLabel.leadingAnchor.constraint(equalTo: walletCard.leadingAnchor, constant: 20),
            
            topUpButton.centerYAnchor.constraint(equalTo: walletCard.centerYAnchor),
            topUpButton.trailingAnchor.constraint(equalTo: walletCard.trailingAnchor, constant: -20),
            topUpButton.widthAnchor.constraint(equalToConstant: 74),
            topUpButton.heightAnchor.constraint(equalToConstant: 32),
            
            // Menu Card
            menuCard.topAnchor.constraint(equalTo: walletCard.bottomAnchor, constant: 16),
            menuCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            menuCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            menuStack.topAnchor.constraint(equalTo: menuCard.topAnchor),
            menuStack.leadingAnchor.constraint(equalTo: menuCard.leadingAnchor),
            menuStack.trailingAnchor.constraint(equalTo: menuCard.trailingAnchor),
            menuStack.bottomAnchor.constraint(equalTo: menuCard.bottomAnchor),
            
            // Sign Out Button
            signOutButton.topAnchor.constraint(equalTo: menuCard.bottomAnchor, constant: 16),
            signOutButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            signOutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            signOutButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }
    
    private func createMenuItems() {
        let menuItems = [
            ("Edit Profile", #selector(editProfileTapped)),
            ("Change Password", #selector(changePasswordTapped)),
            ("My Vehicles", #selector(myVehiclesTapped)),
            ("Parking History", #selector(parkingHistoryTapped))
        ]
        
        for (index, item) in menuItems.enumerated() {
            let menuItem = createMenuItem(title: item.0, action: item.1)
            menuStack.addArrangedSubview(menuItem)
            
            // Add separator if not the last item
            if index < menuItems.count - 1 {
                let separator = createSeparator()
                menuStack.addArrangedSubview(separator)
            }
        }
    }
    
    private func createMenuItem(title: String, action: Selector) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.heightAnchor.constraint(equalToConstant: 64).isActive = true
        
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.contentHorizontalAlignment = .left
        button.titleLabel?.font = .systemFont(ofSize: 17)
        button.addTarget(self, action: action, for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevron.tintColor = .systemGray3
        chevron.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(button)
        container.addSubview(chevron)
        
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            button.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            button.trailingAnchor.constraint(equalTo: chevron.leadingAnchor, constant: -8),
            
            chevron.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            chevron.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
            chevron.widthAnchor.constraint(equalToConstant: 13),
            chevron.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        return container
    }
    
    private func createSeparator() -> UIView {
        let separator = UIView()
        separator.backgroundColor = .systemGray5
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return separator
    }
    
    // MARK: - Actions
    @objc private func editProfileTapped() {
        // TODO: Handle edit profile
        print("Edit profile tapped")
    }
    
    @objc private func changePasswordTapped() {
        // TODO: Handle change password
        print("Change password tapped")
    }
    
    @objc private func myVehiclesTapped() {
        // TODO: Handle my vehicles
        print("My vehicles tapped")
    }
    
    @objc private func parkingHistoryTapped() {
        // TODO: Handle parking history
        print("Parking history tapped")
    }
    
    @objc private func topUpButtonTapped() {
        // TODO: Handle top up
        print("Top up tapped")
    }
    
    @objc private func signOutButtonTapped() {
        // TODO: Handle sign out
        print("Sign out tapped")
    }
}

#Preview {
    ProfileViewController()
}
