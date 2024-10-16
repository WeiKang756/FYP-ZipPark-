//
//  HistoryViewController.swift
//  Map(1.0)
//
//  Created by Wei Kang Tan on 18/12/2024.
//


import UIKit

class HistoryViewController: UIViewController {
    
    // MARK: - UI Components
    private let headerView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let segmentedControl: UISegmentedControl = {
        let items = ["Parking", "Reports"]
        let segmentedControl = UISegmentedControl(items: items)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.backgroundColor = .systemGray6
        segmentedControl.selectedSegmentTintColor = .black
        
        // Set title text attributes for normal state
        let normalTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        segmentedControl.setTitleTextAttributes(normalTextAttributes, for: .normal)
        
        // Set title text attributes for selected state
        let selectedTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        segmentedControl.setTitleTextAttributes(selectedTextAttributes, for: .selected)
        
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        return segmentedControl
    }()
    
    private let filterView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let dateRangeLabel: UILabel = {
        let label = UILabel()
        label.text = "Showing last 30 days"
        label.font = .systemFont(ofSize: 14)
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = .systemBackground
        table.separatorStyle = .none
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    // MARK: - Properties
    private var parkingHistoryData: [ParkingSession] = []
    private var reportHistoryData: [ReportData] = []
    
    private var historyManager = HistoryManager()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        historyManager.delegate = self
        historyManager.fetchParkingSessionHistory()
        historyManager.fetchReportHistory()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(headerView)
        headerView.addSubview(segmentedControl)
        
        view.addSubview(filterView)
        filterView.addSubview(dateRangeLabel)
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 60),
            
            segmentedControl.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            segmentedControl.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            segmentedControl.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            
            filterView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            filterView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            filterView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            filterView.heightAnchor.constraint(equalToConstant: 44),
            
            dateRangeLabel.leadingAnchor.constraint(equalTo: filterView.leadingAnchor, constant: 16),
            dateRangeLabel.centerYAnchor.constraint(equalTo: filterView.centerYAnchor),
            
            tableView.topAnchor.constraint(equalTo: filterView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        segmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .valueChanged)
    }
    
    private func setupNavigationBar() {
        navigationItem.title = "History"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        if let navigationBar = navigationController?.navigationBar {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .black
            appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
            
            navigationBar.standardAppearance = appearance
            navigationBar.scrollEdgeAppearance = appearance
            navigationBar.compactAppearance = appearance
        }
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ParkingHistoryCell.self, forCellReuseIdentifier: "ParkingHistoryCell")
        tableView.register(ReportHistoryCell.self, forCellReuseIdentifier: "ReportHistoryCell")
    }
    
    @objc private func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        tableView.reloadData()
    }
}

// MARK: - UITableViewDelegate & DataSource
extension HistoryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return segmentedControl.selectedSegmentIndex == 0 ? parkingHistoryData.count : reportHistoryData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if segmentedControl.selectedSegmentIndex == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ParkingHistoryCell", for: indexPath) as! ParkingHistoryCell
            let data = parkingHistoryData[indexPath.row]
            cell.configure(location: data.parkingSpot.street.area.areaName, plateNumber: data.plateNumber, duration: data.duration, cost: "RM \(data.totalCost)", status: data.status, date: data.date)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReportHistoryCell", for: indexPath) as! ReportHistoryCell
            let data = reportHistoryData[indexPath.row]
            guard let uuid = data.id, let date = data.date else {
                return cell
            }
            let stringId = String(uuid.uuidString.prefix(8))
            cell.configure(type: data.issueType, reportId: stringId, status: data.status, date: DateFormatterUtility.shared.formatDate(date, to: .date))
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if segmentedControl.selectedSegmentIndex == 0 {
            // Handle parking history selection
            let session = parkingHistoryData[indexPath.row]
            let detailVC = ParkingSessionDetailViewController(session: session)
            navigationController?.pushViewController(detailVC, animated: true)
        } else {
            // Handle report history selection
            // Implement report detail view controller if needed
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
}

extension HistoryViewController: HistoryManagerDelegate {
    func didFetchReportHistory(_ report: [ReportData]) {
        reportHistoryData = report
        DispatchQueue.main.async{
            self.tableView.reloadData()
        }
    }
    
    func didFetchParkingSessionHistory(_ parkingSession: [ParkingSession]) {
        parkingHistoryData = parkingSession
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}
