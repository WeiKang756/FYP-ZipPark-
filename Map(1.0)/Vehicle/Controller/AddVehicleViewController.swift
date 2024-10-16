import UIKit

class AddVehicleViewController: UIViewController {
    
    // MARK: - UI Components
    private let headerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBlue
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Enter your vehicle details"
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
    
    private let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save Vehicle", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let vehicleManger = VehicleManager.shared
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupDelegates()
        setupActions()
        navigationItem.title = "Add Vehicle"
        navigationItem.largeTitleDisplayMode = .never
        vehicleManger.delegate = self
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
        
        view.addSubview(addButton)
        
        NSLayoutConstraint.activate([
            // Header
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 100),
            
            subtitleLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            
            // Form Container
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
            
            // Add Button
            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            addButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupDelegates() {
        plateNumberField.textField.delegate = self
        modelField.textField.delegate = self
        colorField.textField.delegate = self
        
        // Add tap gesture to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupActions() {
        addButton.addTarget(self, action: #selector(addVehicle), for: .touchUpInside)
    }
    
    // MARK: - Actions
    @objc private func viewTapped() {
        view.endEditing(true)
    }
    
    @objc private func addVehicle() {
        if validateAllFields() {
            guard var plateNumber = plateNumberField.textField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                  let description = modelField.textField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                  let color = colorField.textField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            else { return }
            
            plateNumber = plateNumber.replacingOccurrences(of: " ", with: "").uppercased()
            vehicleManger.addVehicle(plateNumber: plateNumber, color: color, description: description)
        } else {
            let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
            animation.timingFunction = CAMediaTimingFunction(name: .linear)
            animation.duration = 0.6
            animation.values = [-20.0, 20.0, -20.0, 20.0, -10.0, 10.0, -5.0, 5.0, 0.0]
            addButton.layer.add(animation, forKey: "shake")
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
extension AddVehicleViewController: UITextFieldDelegate {
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
extension AddVehicleViewController: VehicleManagerDelegate {
    func didAddVehicle() {
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func failToAddVehicle(_ error: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(
                title: "Failed to Add Vehicle",
                message: "A vehicle with this plate number already exists or there was an error. Please try again.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }
}

// MARK: - Form Field View
class FormFieldView: UIView {
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let textField: UITextField = {
        let field = UITextField()
        field.borderStyle = .roundedRect
        field.backgroundColor = .secondarySystemBackground
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    let errorLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .systemRed
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    init(title: String, placeholder: String) {
        super.init(frame: .zero)
        titleLabel.text = title
        textField.placeholder = placeholder
        errorLabel.text = "This field is required"
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(titleLabel)
        addSubview(textField)
        addSubview(errorLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            
            textField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            textField.leadingAnchor.constraint(equalTo: leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            errorLabel.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 4),
            errorLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            errorLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    func showError(_ show: Bool) {
        errorLabel.isHidden = !show
        textField.layer.borderColor = show ? UIColor.systemRed.cgColor : nil
        textField.layer.borderWidth = show ? 1 : 0
    }
    
    func hideError() {
        showError(false)
    }
}
