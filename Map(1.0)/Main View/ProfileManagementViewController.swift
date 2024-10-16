// Import necessary libraries
import UIKit

// Define a Profile Management View Controller
class ProfileManagementViewController: UIViewController {
    // MARK: - Properties
    
    private let supabase = SupabaseManager.shared
    private let profileImageView = UIImageView()
    private let nameLabel = UILabel()
    private let roleLabel = UILabel()
    private let phoneLabel = UILabel()
    private let emailLabel = UILabel()
    private let walletLabel = UILabel()
    private let ordersLabel = UILabel()
    private let optionsStackView = UIStackView()
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadUserProfile()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .white
        
//        // Profile Image Setup
//        profileImageView.contentMode = .scaleAspectFill
//        profileImageView.layer.cornerRadius = 40
//        profileImageView.clipsToBounds = true
//        profileImageView.translatesAutoresizingMaskIntoConstraints = false
//        profileImageView.image = UIImage(named: "profile_placeholder")
//        view.addSubview(profileImageView)
//        
//        // Name Label Setup
//        nameLabel.font = UIFont.boldSystemFont(ofSize: 24)
//        nameLabel.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(nameLabel)
//        
//        // Role Label Setup
//        roleLabel.font = UIFont.systemFont(ofSize: 16)
//        roleLabel.textColor = .gray
//        roleLabel.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(roleLabel)
//        
//        // Phone Label Setup
//        phoneLabel.font = UIFont.systemFont(ofSize: 16)
//        phoneLabel.textColor = .black
//        phoneLabel.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(phoneLabel)
//        
//        // Email Label Setup
//        emailLabel.font = UIFont.systemFont(ofSize: 16)
//        emailLabel.textColor = .black
//        emailLabel.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(emailLabel)
//        
//        // Wallet and Orders Labels Setup
//        walletLabel.font = UIFont.boldSystemFont(ofSize: 20)
//        walletLabel.textColor = .black
//        walletLabel.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(walletLabel)
//        
//        ordersLabel.font = UIFont.boldSystemFont(ofSize: 20)
//        ordersLabel.textColor = .black
//        ordersLabel.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(ordersLabel)
//        
//        // Options Stack View Setup
//        optionsStackView.axis = .vertical
//        optionsStackView.spacing = 20
//        optionsStackView.distribution = .fillEqually
//        optionsStackView.translatesAutoresizingMaskIntoConstraints = false
//        
//        let options = ["Your Favorites", "Payment", "Tell Your Friend", "Promotions", "Settings"]
//        for option in options {
//            let label = UILabel()
//            label.text = option
//            label.font = UIFont.systemFont(ofSize: 18)
//            label.textColor = .systemBlue
//            optionsStackView.addArrangedSubview(label)
//        }
//        view.addSubview(optionsStackView)
        
        // Log Out Button Setup
        let logoutButton = UIButton()
        logoutButton.setTitle("Log out", for: .normal)
        logoutButton.setTitleColor(.red, for: .normal)
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        logoutButton.addTarget(self, action: #selector(logout), for: .touchUpInside)
        view.addSubview(logoutButton)
        
        // Set Constraints
        NSLayoutConstraint.activate([
//            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
//            profileImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
//            profileImageView.widthAnchor.constraint(equalToConstant: 80),
//            profileImageView.heightAnchor.constraint(equalToConstant: 80),
//            
//            nameLabel.topAnchor.constraint(equalTo: profileImageView.topAnchor),
//            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 20),
//            nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
//            
//            roleLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 5),
//            roleLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
//            roleLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
//            
//            phoneLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 20),
//            phoneLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
//            phoneLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
//            
//            emailLabel.topAnchor.constraint(equalTo: phoneLabel.bottomAnchor, constant: 10),
//            emailLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
//            emailLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
//            
//            walletLabel.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 20),
//            walletLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
//            
//            ordersLabel.topAnchor.constraint(equalTo: walletLabel.topAnchor),
//            ordersLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
//            
//            optionsStackView.topAnchor.constraint(equalTo: walletLabel.bottomAnchor, constant: 30),
//            optionsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
//            optionsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            logoutButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            logoutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    @objc func logout() {
        supabase.signOut()
        // Create an instance of the Sign-In View Controller
    }

    // MARK: - Load User Profile
    
    private func loadUserProfile() {
        // Dummy data for demonstration purposes
        let dummyName = "TAN WEI KANG"
        let dummyRole = "USER"
        let dummyPhone = "+60164439702"
        let dummyEmail = "weikang756@gmail.com"
        let dummyWallet = "RM120.00"
        let dummyOrders = "12 Orders"
        
        DispatchQueue.main.async {
            self.nameLabel.text = dummyName
            self.roleLabel.text = dummyRole
            self.phoneLabel.text = dummyPhone
            self.emailLabel.text = dummyEmail
            self.walletLabel.text = dummyWallet
            self.ordersLabel.text = dummyOrders
        }
    }
}

#Preview {
    ProfileManagementViewController()
}
