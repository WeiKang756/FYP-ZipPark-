import UIKit

class EditVehicleViewController: UIViewController {
   
   // MARK: - Properties
   var vehicleModel: VehicleModel?
   private let vehicleManager = VehicleManager()
   
   // MARK: - UI Components
   private let headerView: UIView = {
       let view = UIView()
       view.backgroundColor = .black
       view.translatesAutoresizingMaskIntoConstraints = false
       return view
   }()
   
   private let subtitleLabel: UILabel = {
       let label = UILabel()
       label.text = "Update your vehicle details"
       label.font = .systemFont(ofSize: 16)
       label.textColor = .white.withAlphaComponent(0.8)
       label.translatesAutoresizingMaskIntoConstraints = false
       return label
   }()
   
   private let formContainer: UIView = {
       let view = UIView()
       view.backgroundColor = .white
       view.layer.cornerRadius = 12
       view.layer.shadowColor = UIColor.black.cgColor
       view.layer.shadowOpacity = 0.1
       view.layer.shadowOffset = CGSize(width: 0, height: 2)
       view.layer.shadowRadius = 6
       view.translatesAutoresizingMaskIntoConstraints = false
       return view
   }()
   
   private let plateNumberField: FormFieldView = {
       let field = FormFieldView(title: "PLATE NUMBER", placeholder: "Enter plate number")
       field.textField.font = .systemFont(ofSize: 17, weight: .regular)
       return field
   }()
   
   private let modelField: FormFieldView = {
       let field = FormFieldView(title: "VEHICLE MODEL", placeholder: "Enter make and model")
       field.textField.font = .systemFont(ofSize: 17, weight: .regular)
       return field
   }()
   
   private let colorField: FormFieldView = {
       let field = FormFieldView(title: "COLOR", placeholder: "Enter vehicle color")
       field.textField.font = .systemFont(ofSize: 17, weight: .regular)
       return field
   }()
   
   private let saveButton: UIButton = {
       let button = UIButton(type: .system)
       button.setTitle("Save Changes", for: .normal)
       button.setTitleColor(.white, for: .normal)
       button.backgroundColor = .black
       button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
       button.layer.cornerRadius = 12
       button.translatesAutoresizingMaskIntoConstraints = false
       return button
   }()
   
   // MARK: - Lifecycle
   override func viewDidLoad() {
       super.viewDidLoad()
       setupUI()
       setupDelegates()
       setupActions()
       loadVehicleData()
       vehicleManager.delegate = self
       // Navigation setup
       navigationItem.title = "Edit Vehicle"
       navigationController?.navigationBar.prefersLargeTitles = false
       navigationItem.largeTitleDisplayMode = .never
   }
   
   // MARK: - Setup
   private func setupUI() {
       view.backgroundColor = .systemBackground
       
       view.addSubview(headerView)
       headerView.addSubview(subtitleLabel)
       
       view.addSubview(formContainer)
       formContainer.addSubview(plateNumberField)
       formContainer.addSubview(modelField)
       formContainer.addSubview(colorField)
       
       view.addSubview(saveButton)
       
       NSLayoutConstraint.activate([
           headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
           headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
           headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
           headerView.heightAnchor.constraint(equalToConstant: 20),
           
           subtitleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
           subtitleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
           
           formContainer.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 20),
           formContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
           formContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
           
           plateNumberField.topAnchor.constraint(equalTo: formContainer.topAnchor, constant: 20),
           plateNumberField.leadingAnchor.constraint(equalTo: formContainer.leadingAnchor, constant: 16),
           plateNumberField.trailingAnchor.constraint(equalTo: formContainer.trailingAnchor, constant: -16),
           
           modelField.topAnchor.constraint(equalTo: plateNumberField.bottomAnchor, constant: 20),
           modelField.leadingAnchor.constraint(equalTo: formContainer.leadingAnchor, constant: 16),
           modelField.trailingAnchor.constraint(equalTo: formContainer.trailingAnchor, constant: -16),
           
           colorField.topAnchor.constraint(equalTo: modelField.bottomAnchor, constant: 20),
           colorField.leadingAnchor.constraint(equalTo: formContainer.leadingAnchor, constant: 16),
           colorField.trailingAnchor.constraint(equalTo: formContainer.trailingAnchor, constant: -16),
           colorField.bottomAnchor.constraint(equalTo: formContainer.bottomAnchor, constant: -20),
           
           saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
           saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
           saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
           saveButton.heightAnchor.constraint(equalToConstant: 50)
       ])
   }
   
   private func setupDelegates() {
       plateNumberField.textField.delegate = self
       modelField.textField.delegate = self
       colorField.textField.delegate = self
       
       let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
       view.addGestureRecognizer(tapGesture)
   }
   
   private func setupActions() {
       saveButton.addTarget(self, action: #selector(saveChanges), for: .touchUpInside)
   }
   
   private func loadVehicleData() {
       guard let vehicle = vehicleModel else { return }
       plateNumberField.textField.text = vehicle.plateNumber
       modelField.textField.text = vehicle.description
       colorField.textField.text = vehicle.color
   }
   
   // MARK: - Actions
   @objc private func viewTapped() {
       view.endEditing(true)
   }
   
   @objc private func saveChanges() {
       if validateAllFields() {
           guard let vehicle = vehicleModel,
                 var plateNumber = plateNumberField.textField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                 let description = modelField.textField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                 let color = colorField.textField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
           else { return }
           
           plateNumber = plateNumber.replacingOccurrences(of: " ", with: "").uppercased()
           vehicleManager.updateVehicle(oldVehicleModel: vehicle, plateNumber: plateNumber, color: color, description: description)
       } else {
           let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
           animation.timingFunction = CAMediaTimingFunction(name: .linear)
           animation.duration = 0.6
           animation.values = [-20.0, 20.0, -20.0, 20.0, -10.0, 10.0, -5.0, 5.0, 0.0]
           saveButton.layer.add(animation, forKey: "shake")
       }
   }
   
   private func validateAllFields() -> Bool {
       let isPlateNumberValid = !plateNumberField.textField.text!.isEmpty
       let isModelValid = !modelField.textField.text!.isEmpty
       let isColorValid = !colorField.textField.text!.isEmpty
       
       plateNumberField.showError(!isPlateNumberValid)
       modelField.showError(!isModelValid)
       colorField.showError(!isColorValid)
       
       return isPlateNumberValid && isModelValid && isColorValid
   }
}

// MARK: - UITextFieldDelegate
extension EditVehicleViewController: UITextFieldDelegate {
   func textFieldShouldReturn(_ textField: UITextField) -> Bool {
       switch textField {
       case plateNumberField.textField:
           modelField.textField.becomeFirstResponder()
       case modelField.textField:
           colorField.textField.becomeFirstResponder()
       default:
           textField.resignFirstResponder()
       }
       return true
   }
   
   func textFieldDidBeginEditing(_ textField: UITextField) {
       if textField == plateNumberField.textField {
           plateNumberField.hideError()
       } else if textField == modelField.textField {
           modelField.hideError()
       } else if textField == colorField.textField {
           colorField.hideError()
       }
   }
}

// MARK: - VehicleManagerDelegate
extension EditVehicleViewController: VehicleManagerDelegate {
   func didUpdateVehicle() {
       DispatchQueue.main.async {
           self.navigationController?.popViewController(animated: true)
       }
   }
   
   func failToUpdateVehicle() {
       DispatchQueue.main.async {
           let alert = UIAlertController(
               title: "Failed to Update Vehicle",
               message: "An error occurred while updating the vehicle. Please try again.",
               preferredStyle: .alert
           )
           alert.addAction(UIAlertAction(title: "OK", style: .default))
           self.present(alert, animated: true)
       }
   }
}
