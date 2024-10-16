import UIKit

class FloatingPanelViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        // Example content for the panel
        let label = UILabel()
        label.text = "This is a floating panel"
        label.textColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

class MainViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        let showPanelButton = UIButton(type: .system)
        showPanelButton.setTitle("Show Floating Panel", for: .normal)
        showPanelButton.addTarget(self, action: #selector(showFloatingPanel), for: .touchUpInside)
        showPanelButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(showPanelButton)
        
        NSLayoutConstraint.activate([
            showPanelButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            showPanelButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    @objc func showFloatingPanel() {
        let floatingPanelVC = AreaInformationViewController()
        
        // Set the modal presentation style
        floatingPanelVC.modalPresentationStyle = .fullScreen
    
        if let sheet = floatingPanelVC.sheetPresentationController {
            // Customize the sheet here
            sheet.detents = [
                .medium(), // The panel will snap to this medium height
                .large()   // And can be dragged up to full screen
            ]
            sheet.prefersGrabberVisible = true // Show the grabber handle
            sheet.prefersScrollingExpandsWhenScrolledToEdge = true// Disable auto-expand when scrolling content
        }
        // Present the floating panel
        present(floatingPanelVC, animated: true, completion: nil)
    }
}
