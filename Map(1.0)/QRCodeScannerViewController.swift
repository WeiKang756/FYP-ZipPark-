import UIKit
import AVFoundation

protocol QRCodeScannerViewControllerDelegate: AnyObject {
    func didScanQR(_ parkingSpotModel: ParkingSpotModel)
    func didFailToScanQR(_ error: Error)
}

class QRCodeScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    // MARK: - Properties
    private var captureSession: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private var isFlashOn = false
    private let qrManager = QRManager()
    weak var delegate: QRCodeScannerViewControllerDelegate?
    
    // MARK: - UI Components
    private let focusView: UIView = {
        let view = UIView()
        view.layer.borderColor = UIColor.systemYellow.cgColor
        view.layer.borderWidth = 4
        view.layer.cornerRadius = 20
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.7
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 10
        view.backgroundColor = UIColor(white: 1.0, alpha: 0.1)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let instructionLabel: UILabel = {
        let label = UILabel()
        label.text = "Align QR code within the frame"
        label.textColor = .white
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let flashButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "bolt.slash.fill"), for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let scannerAnimation: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemYellow.withAlphaComponent(0.5)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .white
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        checkCameraPermission()
        setupUI()
        startScanLineAnimation()
        qrManager.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if captureSession?.isRunning == false {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.captureSession?.startRunning()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if captureSession?.isRunning == true {
            captureSession.stopRunning()
        }
        scannerAnimation.layer.removeAllAnimations()
    }
    
    // MARK: - Setup
    private func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupCaptureSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if granted {
                    DispatchQueue.main.async {
                        self?.setupCaptureSession()
                    }
                } else {
                    self?.handleCameraDenied()
                }
            }
        case .denied, .restricted:
            handleCameraDenied()
        @unknown default:
            break
        }
    }
    
    private func handleCameraDenied() {
        DispatchQueue.main.async { [weak self] in
            self?.showAlert(
                title: "Camera Access Required",
                message: "Please enable camera access in Settings to scan QR codes."
            ) {
                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsURL)
                }
                self?.dismiss(animated: true)
            }
        }
    }
    
    private func setupCaptureSession() {
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            showAlert(title: "Error", message: "Your device does not support scanning a code from an item.")
            return
        }
        
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            showAlert(title: "Error", message: error.localizedDescription)
            return
        }
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            showAlert(title: "Error", message: "Unable to add input to the session")
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            showAlert(title: "Error", message: "Unable to add output to the session")
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession.startRunning()
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .black
        
        [focusView, instructionLabel, cancelButton, flashButton, scannerAnimation, loadingIndicator].forEach {
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            focusView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            focusView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            focusView.widthAnchor.constraint(equalToConstant: 250),
            focusView.heightAnchor.constraint(equalToConstant: 250),
            
            instructionLabel.bottomAnchor.constraint(equalTo: focusView.topAnchor, constant: -20),
            instructionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            instructionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            cancelButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cancelButton.widthAnchor.constraint(equalToConstant: 44),
            cancelButton.heightAnchor.constraint(equalToConstant: 44),
            
            flashButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            flashButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            flashButton.widthAnchor.constraint(equalToConstant: 44),
            flashButton.heightAnchor.constraint(equalToConstant: 44),
            
            scannerAnimation.leadingAnchor.constraint(equalTo: focusView.leadingAnchor),
            scannerAnimation.trailingAnchor.constraint(equalTo: focusView.trailingAnchor),
            scannerAnimation.heightAnchor.constraint(equalToConstant: 2),
            scannerAnimation.topAnchor.constraint(equalTo: focusView.topAnchor),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        flashButton.addTarget(self, action: #selector(flashButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Animation
    private func startScanLineAnimation() {
        let animationDuration: TimeInterval = 2.0
        
        UIView.animate(withDuration: animationDuration, delay: 0, options: [.repeat, .autoreverse, .curveEaseInOut], animations: {
            self.scannerAnimation.transform = CGAffineTransform(translationX: 0, y: self.focusView.bounds.height)
        })
    }
    
    // MARK: - Actions
    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc private func flashButtonTapped() {
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        
        if device.hasTorch {
            do {
                try device.lockForConfiguration()
                
                if device.torchMode == .off {
                    try device.setTorchModeOn(level: 1.0)
                    flashButton.setImage(UIImage(systemName: "bolt.fill"), for: .normal)
                    isFlashOn = true
                } else {
                    device.torchMode = .off
                    flashButton.setImage(UIImage(systemName: "bolt.slash.fill"), for: .normal)
                    isFlashOn = false
                }
                
                device.unlockForConfiguration()
            } catch {
                showAlert(title: "Error", message: "Unable to toggle flash")
            }
        }
    }
    
    // MARK: - QR Code Processing
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
                  let stringValue = readableObject.stringValue else { return }
            
            if let barCodeObject = previewLayer.transformedMetadataObject(for: readableObject) as? AVMetadataMachineReadableCodeObject {
                if focusView.frame.contains(barCodeObject.bounds) {
                    AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                    found(code: stringValue)
                }
            }
        }
    }
    
    private func found(code: String) {
        // Stop scanning temporarily
        captureSession.stopRunning()
        
        // First, check if the string is not empty and has valid format
        guard !code.isEmpty else {
            showAlert(title: "Invalid QR Code", message: "The QR code is empty.") { [weak self] in
                self?.resumeScanning()
            }
            return
        }
        
        guard code.hasPrefix("PARKING_SPOT:") else {
            showAlert(title: "Invalid QR Code", message: "This is not a valid parking QR code.") { [weak self] in
                self?.resumeScanning()
            }
            return
        }
        
        let spotID = String(code.dropFirst(13))
        loadingIndicator.startAnimating()
        instructionLabel.text = "Fetching parking spot details..."
        qrManager.fetchParkingSpot(parkingLotID: spotID)
    }
    
    private func resumeScanning() {
        instructionLabel.text = "Align QR code within the frame"
        loadingIndicator.stopAnimating()
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession.startRunning()
        }
    }
    
    // MARK: - Helpers
    private func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        DispatchQueue.main.async { [weak self] in
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                completion?()
            })
            self?.present(alert, animated: true)
        }
    }
    
    // MARK: - Orientation
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

// MARK: - QRManagerDelegate
extension QRCodeScannerViewController: QRManagerDelegate {
    func didFetchParkingSpot(_ parkingSpot: ParkingSpotModel) {
        DispatchQueue.main.async { [weak self] in
            self?.dismiss(animated: true) {
                self?.loadingIndicator.stopAnimating()
                self?.delegate?.didScanQR(parkingSpot)
            }
        }
    }
    
    func didFailToFetchParkingSpot(_ error: Error) {
        loadingIndicator.stopAnimating()
        showAlert(title: "Error", message: error.localizedDescription) { [weak self] in
            self?.resumeScanning()
        }
    }
}
