import UIKit

protocol VehicleViewControllerDelegate: AnyObject {
    func didSelectedVehicleRow(_ vehicleModel: VehicleModel)
}

class VehicleViewController: UIViewController {
    
    // MARK: - Properties
    private let vehicleManager = VehicleManager()
    private var vehiclesModel: [VehicleModel] = []
    weak var delegate: VehicleViewControllerDelegate?
    private var defaultNavBarAppearance: UINavigationBarAppearance?
    private var defaultTintColor: UIColor?
    
    // MARK: - UI Components
    private let tableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = .systemGroupedBackground
        table.separatorStyle = .none
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    private let emptyStateView: UIView = {
        let view = UIView()
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let emptyStateImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "car")
        imageView.tintColor = .systemGray3
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "No vehicles added yet"
        label.font = .systemFont(ofSize: 16)
        label.textColor = .systemGray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
        private let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add New Vehicle", for: .normal)
        button.setTitleColor(.white, for: .normal)
            button.backgroundColor = .black
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        title = "My Vehicles"
        configureNavigationBar()
        navigationItem.largeTitleDisplayMode = .always
        vehicleManager.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar()
        vehicleManager.fetchVehicle()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        restoreDefaultNavigationBar()
    }
    
    // MARK: - Setup
    private func configureLargeTitleDisplay() {
        navigationItem.largeTitleDisplayMode = .always
        title = "My Vehicles"
    }
    
    private func configureNavigationBar() {
        guard let navigationBar = navigationController?.navigationBar else { return }
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .black
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
        navigationBar.compactAppearance = appearance
        
        navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        
        let addBarButton = UIBarButtonItem(
            image: UIImage(systemName: "plus"),
            style: .plain,
            target: self,
            action: #selector(addVehicle)
        )
        addBarButton.tintColor = .white
        navigationItem.rightBarButtonItem = addBarButton
    }
    
    private func restoreDefaultNavigationBar() {
        guard let navigationBar = navigationController?.navigationBar,
              let defaultAppearance = defaultNavBarAppearance else { return }
        
//        navigationBar.scrollEdgeAppearance = defaultAppearance
//        navigationBar.standardAppearance = defaultAppearance
//        navigationBar.compactAppearance = defaultAppearance
//        navigationBar.tintColor = defaultTintColor
        navigationBar.prefersLargeTitles = false
    }
    
    private func setupUI() {
        view.backgroundColor = .systemGroupedBackground
        
        view.addSubview(tableView)
        view.addSubview(emptyStateView)
        emptyStateView.addSubview(emptyStateImageView)
        emptyStateView.addSubview(emptyStateLabel)
        view.addSubview(addButton)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: addButton.topAnchor, constant: -20),
            
            emptyStateView.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: tableView.centerYAnchor),
            emptyStateView.widthAnchor.constraint(equalToConstant: 200),
            
            emptyStateImageView.topAnchor.constraint(equalTo: emptyStateView.topAnchor),
            emptyStateImageView.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            emptyStateImageView.widthAnchor.constraint(equalToConstant: 60),
            emptyStateImageView.heightAnchor.constraint(equalToConstant: 60),
            
            emptyStateLabel.topAnchor.constraint(equalTo: emptyStateImageView.bottomAnchor, constant: 16),
            emptyStateLabel.leadingAnchor.constraint(equalTo: emptyStateView.leadingAnchor),
            emptyStateLabel.trailingAnchor.constraint(equalTo: emptyStateView.trailingAnchor),
            emptyStateLabel.bottomAnchor.constraint(equalTo: emptyStateView.bottomAnchor),
            
            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            addButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        addButton.addTarget(self, action: #selector(addVehicle), for: .touchUpInside)
    }
    
    private func setupTableView() {
        tableView.register(VehicleCell.self, forCellReuseIdentifier: "VehicleCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
    }
    
    @objc private func addVehicle() {
        let addVehicleVC = AddVehicleViewController()
        navigationController?.pushViewController(addVehicleVC, animated: true)
    }
    
    private func updateEmptyState() {
        emptyStateView.isHidden = !vehiclesModel.isEmpty
        tableView.isHidden = vehiclesModel.isEmpty
    }
}

// MARK: - UITableViewDataSource
extension VehicleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vehiclesModel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VehicleCell", for: indexPath) as! VehicleCell
        let vehicle = vehiclesModel[indexPath.row]
        cell.configure(with: vehicle)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension VehicleViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didSelectedVehicleRow(vehiclesModel[indexPath.row])
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (_, _, completion) in
            guard let self = self else { return }
            let vehicle = self.vehiclesModel[indexPath.row]
            self.vehicleManager.deleteVehicle(vehicle)
            completion(true)
        }
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") { [weak self] (_, _, completion) in
            guard let self = self else { return }
            let vehicle = self.vehiclesModel[indexPath.row]
            let editVC = EditVehicleViewController()
            editVC.vehicleModel = vehicle
            self.navigationController?.pushViewController(editVC, animated: true)
            completion(true)
        }
        
        editAction.backgroundColor = .systemBlue
        return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
    }
}

// MARK: - VehicleManagerDelegate
extension VehicleViewController: VehicleManagerDelegate {
    func didFetchVehicle(_ vehiclesModel: [VehicleModel]) {
        self.vehiclesModel = vehiclesModel
        DispatchQueue.main.async {
            self.updateEmptyState()
            self.tableView.reloadData()
        }
    }
    
    func didDeleteVehicle() {
        DispatchQueue.main.async {
            self.vehicleManager.fetchVehicle()
        }
    }
}

// MARK: - Vehicle Cell
class VehicleCell: UITableViewCell {
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowRadius = 5
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let carImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "car.fill")
        imageView.tintColor = .black
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let plateNumberLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
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
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(containerView)
        containerView.addSubview(carImageView)
        containerView.addSubview(plateNumberLabel)
        containerView.addSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            carImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            carImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            carImageView.widthAnchor.constraint(equalToConstant: 40),
            carImageView.heightAnchor.constraint(equalToConstant: 40),
            
            plateNumberLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            plateNumberLabel.leadingAnchor.constraint(equalTo: carImageView.trailingAnchor, constant: 16),
            plateNumberLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            descriptionLabel.topAnchor.constraint(equalTo: plateNumberLabel.bottomAnchor, constant: 4),
            descriptionLabel.leadingAnchor.constraint(equalTo: carImageView.trailingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16)
        ])
    }
    
    func configure(with vehicle: VehicleModel) {
        plateNumberLabel.text = vehicle.plateNumber
        descriptionLabel.text = "\(vehicle.description) • \(vehicle.color)"
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        plateNumberLabel.text = nil
        descriptionLabel.text = nil
    }
}
