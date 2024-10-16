//
//  ReportSystemViewController.swift
//  Map(1.0)
//
//  Created by Wei Kang Tan on 15/12/2024.
//


import UIKit

class ReportSystemViewController: UIViewController {
    // MARK: - UI Components
    private let headerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemRed
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Report Issue"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Help us improve by reporting problems"
        label.font = .systemFont(ofSize: 16)
        label.textColor = .white.withAlphaComponent(0.8)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .systemGray6
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Location Card
    private let locationCard: UIView = {
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
    
    private let locationIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "mappin.circle.fill")
        imageView.tintColor = .systemGray
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let locationTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Location"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let locationDetailLabel: UILabel = {
        let label = UILabel()
        label.text = "Select a Parking Spot"
        label.font = .systemFont(ofSize: 14)
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let chevronIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "chevron.right")
        imageView.tintColor = .systemGray3
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // Issue Type Section
    private let issueTypeCard: UIView = {
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
    
    private let issueTypeLabel: UILabel = {
        let label = UILabel()
        label.text = "Issue Type"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let issueTypeStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 10
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // Description Box
    private let descriptionCard: UIView = {
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
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Description"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 14)
        textView.textColor = .black
        textView.backgroundColor = .systemGray6
        textView.layer.cornerRadius = 8
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 8)
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    // Photo Upload Section
    private let photoCard: UIView = {
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
    
    private let photoLabel: UILabel = {
        let label = UILabel()
        label.text = "Add Photos"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let photoSubLabel: UILabel = {
        let label = UILabel()
        label.text = "Add up to 4 photos"
        label.font = .systemFont(ofSize: 12)
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let photoCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        layout.itemSize = CGSize(width: 80, height: 80)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private let imagePicker = UIImagePickerController()
    private var issueDescription: String? {
        return descriptionTextView.text == placeholderText ? nil : descriptionTextView.text
    }
    private let placeholderText = "Please describe the issue..."
    
    // Submit Button
    private let submitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Submit Report", for: .normal)
        button.setImage(UIImage(systemName: "paperplane.fill"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = .systemRed
        button.layer.cornerRadius = 12
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.addTarget(self, action: #selector(submitButtonTapped(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    
    //MARK: Selected Information
    private var reportManager = ReportManager()
    private var selectedParkingLot: ParkingSpotModel?
    private var selectedPhotos: [UIImage] = []
    private var selectedIssueType: String? {
        didSet {
            updateIssueButtonsAppearance()
        }
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupIssueTypeButtons()
        setupPhotoCollectionView()
        setupImagePicker()
        setupDescriptionTextView()
        navigationItem.title = "Report"
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .never
        reportManager.delegate = self
    }
    
    //MARK: - handler method
    @objc private func issueButtonTapped(_ sender: UIButton) {
        guard let issueType = sender.title(for: .normal) else { return }
        
        // If tapping the same button again, deselect it
        if selectedIssueType == issueType {
            selectedIssueType = nil
        } else {
            selectedIssueType = issueType
        }
    }
    
    @objc private func submitButtonTapped(_ sender: UIButton) {
        guard validateForm() else {
            return
        }
        
        guard let selectedParkingLot = selectedParkingLot,
              let selectedIssueType = selectedIssueType,
              let description = descriptionTextView.text,
              description != placeholderText else {
            return
        }
        
        reportManager.submitReport(
            parkingSpot: selectedParkingLot,
            issueType: selectedIssueType,
            description: description,
            images: selectedPhotos
        )
    }
    
    private func updateIssueButtonsAppearance() {
        // Iterate through all stacks in issueTypeStack
        issueTypeStack.arrangedSubviews.forEach { stackView in
            guard let horizontalStack = stackView as? UIStackView else { return }
            
            horizontalStack.arrangedSubviews.forEach { view in
                guard let button = view as? UIButton else { return }
                
                if button.title(for: .normal) == selectedIssueType {
                    // Selected button appearance
                    button.backgroundColor = .systemRed
                    button.setTitleColor(.white, for: .normal)
                } else {
                    // Unselected button appearance
                    button.backgroundColor = .systemGray6
                    button.setTitleColor(.black, for: .normal)
                }
            }
        }
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func locationCardTapped() {
        // Create visual feedback animation
        UIView.animate(withDuration: 0.1, animations: {
            self.locationCard.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
            self.locationCard.alpha = 0.8
        }) { _ in
            UIView.animate(withDuration: 0.1, animations: {
                self.locationCard.transform = .identity
                self.locationCard.alpha = 1.0
            }) { _ in
                // Navigate to ParkingSpotListViewController
                let parkingSpotListVC = ParkingSpotListViewController()
                parkingSpotListVC.delegate = self
                self.navigationController?.pushViewController(parkingSpotListVC, animated: true)
            }
        }
    }
     
    private func validateForm() -> Bool {
        // Check if issue type is selected
        guard let issueType = selectedIssueType else {
            DispatchQueue.main.async {
                self.showAlert(title: "Error", message: "Please select an issue type")
            }
            return false
        }
        
        // Check description
        let descriptionText = descriptionTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        let isPlaceholder = descriptionTextView.text == placeholderText
        
        if isPlaceholder || descriptionText.isEmpty {
            descriptionTextView.layer.borderColor = UIColor.systemRed.cgColor
            descriptionTextView.layer.borderWidth = 1
            DispatchQueue.main.async {
                self.showAlert(title: "Error", message: "Please provide a description of the issue")
            }
            return false
        }
        
        // Check if photos are added
        if selectedPhotos.isEmpty {
            DispatchQueue.main.async {
                self.showAlert(title: "Error", message: "Please add at least one photo")
            }
            return false
        }
        
        
        // If all validations pass
        return true
    }

    //MARK: Alert
    func showAlert(title: String = "Error", message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true)
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(headerView)
        headerView.addSubview(titleLabel)
        headerView.addSubview(subtitleLabel)
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Add description and photo sections
        setupLocationCard()
        setupIssueTypeSection()
        setupDescriptionSection()
        setupPhotoSection()
        view.addSubview(submitButton)
    
        
        NSLayoutConstraint.activate([
            // Header
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 100),
            
            titleLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            
            // ScrollView constraints
            scrollView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: submitButton.topAnchor, constant: -16),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Description card constraints
            descriptionCard.topAnchor.constraint(equalTo: issueTypeCard.bottomAnchor, constant: 16),
            descriptionCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            descriptionCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // Photo card constraints
            photoCard.topAnchor.constraint(equalTo: descriptionCard.bottomAnchor, constant: 16),
            photoCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            photoCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            photoCard.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            
            // Submit Button
            submitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            submitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            submitButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            submitButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupLocationCard() {
        contentView.addSubview(locationCard)
        locationCard.addSubview(locationIcon)
        locationCard.addSubview(locationTitleLabel)
        locationCard.addSubview(locationDetailLabel)
        locationCard.addSubview(chevronIcon)
        
        // Add tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(locationCardTapped))
        locationCard.addGestureRecognizer(tapGesture)
        locationCard.isUserInteractionEnabled = true // Make sure this is enabled
        
        NSLayoutConstraint.activate([
            locationCard.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            locationCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            locationCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            locationIcon.leadingAnchor.constraint(equalTo: locationCard.leadingAnchor, constant: 16),
            locationIcon.centerYAnchor.constraint(equalTo: locationCard.centerYAnchor),
            locationIcon.widthAnchor.constraint(equalToConstant: 24),
            locationIcon.heightAnchor.constraint(equalToConstant: 24),
            
            locationTitleLabel.leadingAnchor.constraint(equalTo: locationIcon.trailingAnchor, constant: 12),
            locationTitleLabel.topAnchor.constraint(equalTo: locationCard.topAnchor, constant: 16),
            
            locationDetailLabel.leadingAnchor.constraint(equalTo: locationTitleLabel.leadingAnchor),
            locationDetailLabel.topAnchor.constraint(equalTo: locationTitleLabel.bottomAnchor, constant: 4),
            locationDetailLabel.bottomAnchor.constraint(equalTo: locationCard.bottomAnchor, constant: -16),
            
            chevronIcon.trailingAnchor.constraint(equalTo: locationCard.trailingAnchor, constant: -16),
            chevronIcon.centerYAnchor.constraint(equalTo: locationCard.centerYAnchor),
            chevronIcon.widthAnchor.constraint(equalToConstant: 20),
            chevronIcon.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    private func setupIssueTypeSection() {
        contentView.addSubview(issueTypeCard)
        issueTypeCard.addSubview(issueTypeLabel)
        issueTypeCard.addSubview(issueTypeStack)
        
        NSLayoutConstraint.activate([
            issueTypeCard.topAnchor.constraint(equalTo: locationCard.bottomAnchor, constant: 16),
            issueTypeCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            issueTypeCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            issueTypeLabel.topAnchor.constraint(equalTo: issueTypeCard.topAnchor, constant: 16),
            issueTypeLabel.leadingAnchor.constraint(equalTo: issueTypeCard.leadingAnchor, constant: 16),
            
            issueTypeStack.topAnchor.constraint(equalTo: issueTypeLabel.bottomAnchor, constant: 16),
            issueTypeStack.leadingAnchor.constraint(equalTo: issueTypeCard.leadingAnchor, constant: 16),
            issueTypeStack.trailingAnchor.constraint(equalTo: issueTypeCard.trailingAnchor, constant: -16),
            issueTypeStack.bottomAnchor.constraint(equalTo: issueTypeCard.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupIssueTypeButtons() {
        let issues = [
            "Illegal Parking",
            "Payment Issue",
            "Parking Spot Issue",
            "Others"
        ]
        
        let horizontalStack1 = UIStackView()
        horizontalStack1.axis = .horizontal
        horizontalStack1.distribution = .fillEqually
        horizontalStack1.spacing = 10
        
        let horizontalStack2 = UIStackView()
        horizontalStack2.axis = .horizontal
        horizontalStack2.distribution = .fillEqually
        horizontalStack2.spacing = 10
        
        let horizontalStack3 = UIStackView()
        horizontalStack3.axis = .horizontal
        horizontalStack3.distribution = .fillEqually
        horizontalStack3.spacing = 10
        
        for (index, issue) in issues.enumerated() {
            let button = createIssueButton(with: issue)
            
            if index < 2 {
                horizontalStack1.addArrangedSubview(button)
            } else {
                horizontalStack2.addArrangedSubview(button)
            }
        }
        
        issueTypeStack.addArrangedSubview(horizontalStack1)
        issueTypeStack.addArrangedSubview(horizontalStack2)
    }
    
    private func createIssueButton(with title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14)
        button.backgroundColor = .systemGray6
        button.layer.cornerRadius = 8
        button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        button.addTarget(self, action: #selector(issueButtonTapped(_:)), for: .touchUpInside)
        return button
    }
    
    private func setupDescriptionTextView() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        descriptionTextView.delegate = self
        descriptionTextView.text = placeholderText
        descriptionTextView.textColor = .systemGray
    }
    
    private func setupDescriptionSection() {
        contentView.addSubview(descriptionCard)
        descriptionCard.addSubview(descriptionLabel)
        descriptionCard.addSubview(descriptionTextView)
        
        NSLayoutConstraint.activate([
            descriptionCard.topAnchor.constraint(equalTo: issueTypeCard.bottomAnchor, constant: 16),
            descriptionCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            descriptionCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            descriptionLabel.topAnchor.constraint(equalTo: descriptionCard.topAnchor, constant: 16),
            descriptionLabel.leadingAnchor.constraint(equalTo: descriptionCard.leadingAnchor, constant: 16),
            
            descriptionTextView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 12),
            descriptionTextView.leadingAnchor.constraint(equalTo: descriptionCard.leadingAnchor, constant: 16),
            descriptionTextView.trailingAnchor.constraint(equalTo: descriptionCard.trailingAnchor, constant: -16),
            descriptionTextView.heightAnchor.constraint(equalToConstant: 120),
            descriptionTextView.bottomAnchor.constraint(equalTo: descriptionCard.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupPhotoSection() {
        contentView.addSubview(photoCard)
        photoCard.addSubview(photoLabel)
        photoCard.addSubview(photoSubLabel)
        photoCard.addSubview(photoCollectionView)
        
        NSLayoutConstraint.activate([
            photoCard.topAnchor.constraint(equalTo: descriptionCard.bottomAnchor, constant: 16),
            photoCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            photoCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            photoCard.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            
            photoLabel.topAnchor.constraint(equalTo: photoCard.topAnchor, constant: 16),
            photoLabel.leadingAnchor.constraint(equalTo: photoCard.leadingAnchor, constant: 16),
            
            photoSubLabel.topAnchor.constraint(equalTo: photoLabel.bottomAnchor, constant: 4),
            photoSubLabel.leadingAnchor.constraint(equalTo: photoCard.leadingAnchor, constant: 16),
            
            photoCollectionView.topAnchor.constraint(equalTo: photoSubLabel.bottomAnchor, constant: 12),
            photoCollectionView.leadingAnchor.constraint(equalTo: photoCard.leadingAnchor, constant: 16),
            photoCollectionView.trailingAnchor.constraint(equalTo: photoCard.trailingAnchor, constant: -16),
            photoCollectionView.heightAnchor.constraint(equalToConstant: 80),
            photoCollectionView.bottomAnchor.constraint(equalTo: photoCard.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupPhotoCollectionView() {
        photoCollectionView.delegate = self
        photoCollectionView.dataSource = self
        photoCollectionView.register(PhotoCell.self, forCellWithReuseIdentifier: "PhotoCell")
    }
    
    private func setupImagePicker() {
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .camera
    }
}

// MARK: - UICollectionViewDelegate & DataSource
extension ReportSystemViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return min(selectedPhotos.count + 1, 4) // Add button + selected photos, max 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
        
        if indexPath.item == selectedPhotos.count {
            // Add photo button
            cell.configure(with: nil)
        } else {
            // Show selected photo
            cell.configure(with: selectedPhotos[indexPath.item])
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == selectedPhotos.count {
            // Show action sheet to choose camera or photo library
            let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let cameraAction = UIAlertAction(title: "Take Photo", style: .default) { [weak self] _ in
                self?.imagePicker.sourceType = .camera
                self?.present(self?.imagePicker ?? UIImagePickerController(), animated: true)
            }
            
            let libraryAction = UIAlertAction(title: "Choose from Library", style: .default) { [weak self] _ in
                self?.imagePicker.sourceType = .photoLibrary
                self?.present(self?.imagePicker ?? UIImagePickerController(), animated: true)
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            
            actionSheet.addAction(cameraAction)
            actionSheet.addAction(libraryAction)
            actionSheet.addAction(cancelAction)
            
            present(actionSheet, animated: true)
        } else {
            // Remove photo option
            let actionSheet = UIAlertController(title: nil, message: "What would you like to do with this photo?", preferredStyle: .actionSheet)
            
            let removeAction = UIAlertAction(title: "Remove Photo", style: .destructive) { [weak self] _ in
                self?.selectedPhotos.remove(at: indexPath.item)
                self?.photoCollectionView.reloadData()
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            
            actionSheet.addAction(removeAction)
            actionSheet.addAction(cancelAction)
            
            present(actionSheet, animated: true)
        }
    }
}

// MARK: - UIImagePickerControllerDelegate
extension ReportSystemViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage, selectedPhotos.count < 4 {
            selectedPhotos.append(image)
            photoCollectionView.reloadData()
        }
        
        picker.dismiss(animated: true)
    }
}

// MARK: - UITextViewDelegate
extension ReportSystemViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == placeholderText {
            textView.text = ""
            textView.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = placeholderText
            textView.textColor = .systemGray
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // Optional: Limit the text length
        let currentText = textView.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
        return updatedText.count <= 500 // Maximum 500 characters
    }
}

extension ReportSystemViewController: ParkingSpotListViewControllerDelegate {
    func didSelectParkingSpot(_ parkingSpot: ParkingSpotModel) {
        selectedParkingLot = parkingSpot
        navigationController?.popViewController(animated: true)
        DispatchQueue.main.async {
            self.locationDetailLabel.text = "\(parkingSpot.areaName), Spot: \(parkingSpot.parkingSpotID)"
        }
    }
}

// MARK: - Photo Cell
class PhotoCell: UICollectionViewCell {
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.backgroundColor = .systemGray6
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let plusIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "plus.circle.fill")
        imageView.tintColor = .systemGray3
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(imageView)
        contentView.addSubview(plusIcon)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            plusIcon.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            plusIcon.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            plusIcon.widthAnchor.constraint(equalToConstant: 24),
            plusIcon.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    func configure(with image: UIImage?) {
        if let image = image {
            imageView.image = image
            plusIcon.isHidden = true
        } else {
            imageView.image = nil
            plusIcon.isHidden = false
        }
    }
}

extension ReportSystemViewController: ReportManagerDelegate {
    func didSubmitReport() {
        DispatchQueue.main.async { [weak self] in
            let alert = UIAlertController(
                title: "Success",
                message: "Your report has been submitted successfully",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                self?.navigationController?.popViewController(animated: true)
            })
            self?.present(alert, animated: true)
        }
    }
    
    func failToSubmitReport(_ error: String) {
        DispatchQueue.main.async { [weak self] in
            let alert = UIAlertController(
                title: "Error",
                message: "Failed to submit report: \(error)",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self?.present(alert, animated: true)
        }
    }
}

#Preview {
    ReportSystemViewController()
}
