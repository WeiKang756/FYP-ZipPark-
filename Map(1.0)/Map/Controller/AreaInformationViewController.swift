import UIKit

protocol AreaInformationViewControllerDelegate {
    func areaTableRowDidSelected (_ streetModel: StreetModel)
}
// Model for Parking Spot
class AreaInformationViewController: UIViewController {
    
    // UI elements
    let label: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        label.text = "Kingfisher Plaza"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let table: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    var streetModels: [StreetModel]?
    var areaModel: AreaModel?
    var distance: Double?
    var delegate: AreaInformationViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray6
        
        // Register the custom cell using the NIB file
        table.register(UINib(nibName: "StreetTableViewCell", bundle: nil), forCellReuseIdentifier: "StreetCell")
        table.register(UINib(nibName: "AreaDetailTableViewCell", bundle: nil), forCellReuseIdentifier: "AreaCell")
        // Set table's data source and delegate
        table.dataSource = self
        table.delegate = self
        setupView()
    }
    
    private func setupView() {
        guard let areaModel = areaModel else {
            return
        }
        
        let titleLabel = UILabel()
        titleLabel.text = areaModel.areaName
        titleLabel.font = UIFont.systemFont(ofSize: 25, weight: .bold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .white
        
        let infoStackView = UIStackView()
        infoStackView.axis = .horizontal
        infoStackView.distribution = .equalSpacing
        infoStackView.alignment = .center
        infoStackView.translatesAutoresizingMaskIntoConstraints = false
        
        let totalView = InfoView(
            title: "Total",
            icon: UIImage(systemName: "car.fill"),
            value: String(areaModel.totalParking),
            iconColor: .systemBlue,
            valueColor: .systemBlue
        )
        
        let availableView = InfoView(
            title: "Available",
            icon: UIImage(systemName: "car.fill"),
            value: String(areaModel.availableParking),
            iconColor: .systemGreen,
            valueColor: .systemBlue
        )
    
        guard var distance = distance else {
            return
        }
        
        let distanceString: String
        if distance > 1000{
            distance = distance/1000
            distanceString = String(format: "%.1f KM", distance)
        }else {
            distanceString = String(format: "%.0f M", distance)
        }
        
        let distanceView = InfoView(
            title: "Distance",
            icon: UIImage(systemName: "figure.walk"),
            value: distanceString,
            iconColor: .systemBlue,
            valueColor: .systemBlue
        )
        
        let separatorTop = createSeparator(isVertical: false)
        let separatorBottom = createSeparator(isVertical: false)
        let separatorVertical1 = createSeparator(isVertical: true)
        let separatorVertical2 = createSeparator(isVertical: true)
        
        infoStackView.addArrangedSubview(totalView)
        infoStackView.addArrangedSubview(separatorVertical1)
        infoStackView.addArrangedSubview(availableView)
        infoStackView.addArrangedSubview(separatorVertical2)
        infoStackView.addArrangedSubview(distanceView)
        
        view.addSubview(titleLabel)
        view.addSubview(containerView)
        view.addSubview(table)
        containerView.addSubview(separatorTop)
        containerView.addSubview(infoStackView)
        containerView.addSubview(separatorBottom)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            containerView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 60),
            
            separatorTop.topAnchor.constraint(equalTo: containerView.topAnchor),
            separatorTop.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            separatorTop.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            
            separatorBottom.topAnchor.constraint(equalTo: containerView.bottomAnchor),
            separatorBottom.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            separatorBottom.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            
            infoStackView.topAnchor.constraint(equalTo: separatorTop.bottomAnchor, constant: 10),
            infoStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            infoStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            infoStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10),
            
            totalView.widthAnchor.constraint(equalTo: availableView.widthAnchor),
            availableView.widthAnchor.constraint(equalTo: distanceView.widthAnchor),
            
            separatorVertical1.heightAnchor.constraint(equalTo: infoStackView.heightAnchor, multiplier: 0.6),
            separatorVertical2.heightAnchor.constraint(equalTo: infoStackView.heightAnchor, multiplier: 0.6),
            
            table.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 10),
            table.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            table.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            table.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 20),
        ])
    }
    
    private func createSeparator(isVertical: Bool = true) -> UIView {
        let separator = UIView()
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.backgroundColor = .systemGray5
        
        if isVertical {
            NSLayoutConstraint.activate([
                separator.widthAnchor.constraint(equalToConstant: 1)
            ])
        } else {
            NSLayoutConstraint.activate([
                separator.heightAnchor.constraint(equalToConstant: 1)
            ])
        }
        
        return separator
    }
}

//MARK: - UITableViewDataSource

extension AreaInformationViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2  // Number of sections based on section titles
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }else {
            guard let streetModels = streetModels else {
                return 0
            }
            return streetModels.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AreaCell", for: indexPath) as! AreaDetailTableViewCell
            guard let areaModel = areaModel else {
                return cell
            }
            cell.numYellowParkingLabel.text = String(areaModel.numYellow)
            cell.numRedParkingLabel.text = String(areaModel.numRed)
            cell.numGreenParkingLabel.text = String(areaModel.numGreen)
            cell.numDisableParkingLabel.text = String(areaModel.numDisable)
            return cell
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "StreetCell", for: indexPath) as! StreetTableViewCell
            
            guard let streetModels = streetModels else {
                return cell
            }
            cell.numRedParkingLabel.text = String(streetModels[indexPath.row].numRed)
            cell.numGreenParkingLabel.text = String(streetModels[indexPath.row].numGreen)
            cell.numYellowParkingLabel.text = String(streetModels[indexPath.row].numYellow)
            cell.numDisableParkingLabel.text = String(streetModels[indexPath.row].numDisable)
            cell.numTotalAvailableParkingLabel.text = String(streetModels[indexPath.row].numAvailable)
            cell.streetNameLabel.text = streetModels[indexPath.row].streetName
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "PARKING TYPE" : "STREET"
    }
}

//MARK: - UITableViewDelegate

extension AreaInformationViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Street row have been selected")
        guard let streetModels else {return}
        let streetModel = streetModels[indexPath.row]
        delegate?.areaTableRowDidSelected(streetModel)
    }
}

