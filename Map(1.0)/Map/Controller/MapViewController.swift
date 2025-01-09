import UIKit
import MapKit
import FloatingPanel

class MapViewController: UIViewController {
    private var locationManager: CLLocationManager?
    private var hideTimer: Timer?
    private var userLocation: UserLocation?
    lazy var areaAnnotations: [MKAnnotation] = []
    var selectedAreaAnnotation: MKAnnotation?
    var mapManager = MapManager()
    var areas: [AreaModel]? = nil
    lazy var deselectFromTableCell = false

    private lazy var floatingPanelController: FloatingPanelController = {
        let panelController = FloatingPanelController()
        panelController.isRemovalInteractionEnabled = false
        return panelController
    }()

    let nearestParkingfloatingPanel = FloatingPanelController()

    private lazy var infomationPanelView: InfomationPanel =  {
        let floatingPanel = InfomationPanel()
        return floatingPanel
    }()

    private lazy var parkingInformationPanel: ParkingInformationPanel = {
        let parkingInformationPanel = ParkingInformationPanel()
        return parkingInformationPanel
    }()

    //map view
    private lazy var mapView:MKMapView = {
        let map = MKMapView()
        map.showsUserLocation = true
        map.translatesAutoresizingMaskIntoConstraints = false
        return map
    }()

    var areaDetailFloatingPanel: AreaInformationViewController?
    var streetFloatingPanel: StreetInformationViewController?
    //Floating Panel View Controller
    let contentViewController = SearchTableViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        if let tabBar = self.tabBarController?.tabBar {
            // Set the background color of the tab bar
            tabBar.backgroundColor = .white
            tabBar.isTranslucent = false
        }
        navigationItem.title = "Map"
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .never
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.requestLocation()
        mapView.delegate = self
        setupMap()
        setupInfomationPanel()
        floatingPanelController.delegate = contentViewController
        contentViewController.delegate = self
        floatingPanelController.set(contentViewController: contentViewController)
        floatingPanelController.layout = CustomFloatingPanelLayout()
        floatingPanelController.track(scrollView: contentViewController.tableView)
        floatingPanelController.addPanel(toParent: self)
        mapManager.delegate = self
    }

    func addAreaAnnotation(title: String, availableParking: String, latitude: Double, longtitude: Double, area: AreaModel) {
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longtitude)
        let annotation = AreaAnnotation(title: title, availableParking: availableParking, coordinate: coordinate, area: area)
        mapView.addAnnotation(annotation)
    }

    func setupInfomationPanel() {
        // Initialize the floating panel view
        view.addSubview(infomationPanelView)

        // Constraints for the floating panel to position it at the bottom of the screen
        NSLayoutConstraint.activate([
            infomationPanelView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            infomationPanelView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            infomationPanelView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            infomationPanelView.heightAnchor.constraint(equalToConstant: 150)  // Height of the panel
        ])
    }

    func setupParkingInformationPanel() {

        view.addSubview(parkingInformationPanel)

        parkingInformationPanel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            parkingInformationPanel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            parkingInformationPanel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            parkingInformationPanel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }

    private func setupMap(){

        view.addSubview(mapView)

        //constraints to the map view
        mapView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        mapView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        mapView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        mapView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }

    private func setMapView(location: CLLocationCoordinate2D) {
        let region = MKCoordinateRegion(center: location, latitudinalMeters: 750, longitudinalMeters: 750)
        mapView .setRegion(region, animated: true)
    }

    private func checkLocationAuthorization() {
        guard let locationManager = locationManager, let location = locationManager.location
        else {return}

        switch locationManager.authorizationStatus {

        case .authorizedWhenInUse, .authorizedAlways:
            let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 1500, longitudinalMeters: 1500)
            mapView .setRegion(region, animated: true)
            reverseGeocodeLocation(location: location)

        case .notDetermined, .restricted:
            print("Location access denied or restricted")

        case .denied:
            print("user denied")

        default:
            print("unknown")
        }
    }
}

//MARK: - CLLocationManagerDelegate

extension MapViewController: CLLocationManagerDelegate{

    func locationManagerDidChangeAuthorization( _ manager: CLLocationManager) {
        checkLocationAuthorization()
    }

    // This method is called when the location manager successfully gets the user's location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude

            // Print out the current location
            print("User's current location: Latitude: \(latitude), Longitude: \(longitude)")
            // You can also reverse-geocode the location if you want the address
            reverseGeocodeLocation(location: location)
        }
    }


    // This method is called when the location manager fails to get the location
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get the user's location: \(error.localizedDescription)")
    }

    func reverseGeocodeLocation(location: CLLocation) {
        let geocoder = CLGeocoder()

        geocoder.reverseGeocodeLocation(location) {  (placemarks, error) in
            if let error = error {
                print("Failed to reverse geocode location: \(error.localizedDescription)")
            } else if let placemarks = placemarks, let placemark = placemarks.first {
                // Extract detailed information from the placemark
                let street = placemark.thoroughfare ?? "N/A"
                let city = placemark.locality ?? "N/A"

                self.userLocation = UserLocation(streetName: street, city: city, location: location)
                if let userLocation = self.userLocation {
                    self.contentViewController.getUserLocation(userLocation: userLocation)
                    self.mapManager.userLocation = userLocation
                    self.mapManager.fetchAreaData()
                    self.mapManager.fetchParkingSpotData()
                }
            }
        }
    }
}

//MARK: - MKMapViewDelegate

extension MapViewController: MKMapViewDelegate {

    //     Delegate method to render the polyline
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = UIColor.blue
            renderer.lineWidth = 10.0
            return renderer
        }
        return MKOverlayRenderer()
    }

    //define a view for the annotation
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

        guard !(annotation is MKUserLocation) else {
            return nil  // Return nil to use default view for user's location
        }

        if annotation is AreaAnnotation {
            //annotation view's identifier
            let identifier = "CustomPin"

            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView

            if annotationView == nil {
                annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true

                // Set the marker's appearance
                annotationView?.glyphImage = UIImage(systemName: "p.circle.fill")

            } else {
                annotationView?.annotation = annotation
                annotationView?.glyphImage = UIImage(systemName: "p.circle.fill")
            }

            return annotationView
        }else if annotation is ParkingAnnotation{
            let identifier = "ParkingPin"

            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView

            if annotationView == nil {
                annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.glyphImage = UIImage(systemName: "car")
            }else {
                annotationView?.annotation = annotation
                annotationView?.glyphImage = UIImage(systemName: "car")
            }

            return annotationView
        }else {
            return nil
        }

    }

    //annotation selected access the data
    func mapView(_ mapView: MKMapView, didSelect annotation: MKAnnotation) {

        if let annotation = annotation as? AreaAnnotation {
            // Cancel any pending hide operation
            floatingPanelController.hide(animated: true)
            hideTimer?.invalidate()
            areaDetailFloatingPanel = AreaInformationViewController()
            guard let areaDetailFloatingPanel = areaDetailFloatingPanel else {
                return
            }
            areaDetailFloatingPanel.presentationController?.delegate = self
            areaDetailFloatingPanel.delegate = self
            // Set the modal presentation style
            areaDetailFloatingPanel.modalPresentationStyle = .pageSheet

            if let sheet = areaDetailFloatingPanel.sheetPresentationController {
                // Customize the sheet here
                sheet.detents = [
                    .medium(), // Medium height (~half screen)
                    .large()   // Full screen height
                ]

                sheet.prefersGrabberVisible = true // Show the grabber handle
                sheet.prefersScrollingExpandsWhenScrolledToEdge = true // Allow auto-expand when scrolling content
            }

            areaDetailFloatingPanel.areaModel = annotation.area
            areaDetailFloatingPanel.presentationController?.delegate = self
            areaDetailFloatingPanel.delegate = self
            // Set the modal presentation style
            areaDetailFloatingPanel.modalPresentationStyle = .pageSheet

            if let sheet = areaDetailFloatingPanel.sheetPresentationController {
                // Customize the sheet here
                sheet.detents = [
                    .medium(), // Medium height (~half screen)
                    .large()   // Full screen height
                ]

                sheet.prefersGrabberVisible = true // Show the grabber handle
                sheet.prefersScrollingExpandsWhenScrolledToEdge = true // Allow auto-expand when scrolling content
            }

            let areaModel = annotation.area
            let userLocation = userLocation?.location
            let areaLocation = CLLocation(latitude: areaModel.latitude, longitude: areaModel.longtitude)
            var distance = 0.0
            if let userLocation = userLocation {
                distance = mapManager.calculateDistance(userLocation, areaLocation)
            }
            areaDetailFloatingPanel.distance = distance
            mapManager.fetchStreetAndParkingSpotData(areaID: annotation.area.areaID)
            selectedAreaAnnotation = annotation

        }else if let annotation = annotation as? ParkingAnnotation{
    
            print("I form did select (parkingAnnotation")
            streetFloatingPanel?.dismiss(animated: true)
            floatingPanelController.hide(animated: false)
            setupParkingInformationPanel()
            showRoute(to: annotation.coordinate, annotation: annotation)
            guard let parkingSpotModel = annotation.parkingSpotModel else {
                return
            }
            let distanceString = mapManager.distanceToDistanceString(distance: parkingSpotModel.distance ?? 0.0)

            parkingInformationPanel.configure(
                parkingLot: String(parkingSpotModel.parkingSpotID),
                zone: parkingSpotModel.type,
                location: parkingSpotModel.areaName,
                isAvailable: parkingSpotModel.isAvailable
            )

            parkingInformationPanel.onStartParkingTapped = {
                let parkingSpotVC = ParkingSpotDetailsViewController()
                parkingSpotVC.parkingSpotModel = parkingSpotModel
                self.navigationController?.pushViewController(parkingSpotVC, animated: true)
            }
        }
    }


    // Annotation Deselected
    func mapView(_ mapView: MKMapView, didDeselect annotation: MKAnnotation) {
        if annotation is AreaAnnotation {
            // Hide the information panel
            self.infomationPanelView.hide()
            self.floatingPanelController.move(to: .tip, animated: true)
            print("I am from didDeselect (AreaAnnotation)")

        } else if annotation is ParkingAnnotation {
            print("I am from didDeselect (ParkingAnnotation)")

            // Remove only the parking annotation and the route overlay, not all annotations
            mapView.removeAnnotation(annotation)
            mapView.removeOverlays(mapView.overlays)

            // Re-add area annotations
            for areaAnnotation in areaAnnotations {
                mapView.addAnnotation(areaAnnotation)
            }

            // Delay selecting the area annotation to ensure smooth UI update
            if let selectedAreaAnnotation = selectedAreaAnnotation {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.mapView.selectAnnotation(selectedAreaAnnotation, animated: true)
                }
            } else {
                floatingPanelController.move(to: .half, animated: true)
            }

            // Remove the parking information panel
            parkingInformationPanel.removeFromSuperview()
        }
    }

    func showRoute(to destination: CLLocationCoordinate2D, annotation: ParkingAnnotation){

        guard let userLocation = userLocation?.location.coordinate else {
            print("User Location not available")
            return
        }

        let sourcePlacemark = MKPlacemark(coordinate: userLocation)
        let destinationPlacemark = MKPlacemark(coordinate: destination)

        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)

        let directionRequest = MKDirections.Request()
        directionRequest.source = sourceMapItem
        directionRequest.destination = destinationMapItem
        directionRequest.transportType = .automobile

        let direction = MKDirections(request: directionRequest)
        direction.calculate { response, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }

            guard let response = response else {return}
            let route = response.routes[0]
            self.mapView.addOverlay(route.polyline, level: .aboveRoads)


            let rect = route.polyline.boundingMapRect
            self.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
        }

        parkingInformationPanel.onNavigateTapped = {
            if destinationMapItem.openInMaps(){
                self.mapView.deselectAnnotation(annotation, animated: false)
            }
        }
    }
}

//MARK: - UIAdaptivePresentationControllerDelegate

extension MapViewController: UIAdaptivePresentationControllerDelegate {

    private func configureAndPresentAreaPanel() {
        // Configure presentation style
        guard let areaDetailFloatingPanel = areaDetailFloatingPanel else {return}
        areaDetailFloatingPanel.modalPresentationStyle = .pageSheet
        areaDetailFloatingPanel.presentationController?.delegate = self

        // Configure sheet presentation
        if let sheet = areaDetailFloatingPanel.sheetPresentationController {
            sheet.detents = [
                .medium(), // Medium height (~half screen)
                .large()   // Full screen height
            ]
            sheet.prefersGrabberVisible = true
            sheet.prefersScrollingExpandsWhenScrolledToEdge = true
        }

        // Present the panel
        present(areaDetailFloatingPanel, animated: true)
    }

    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        if presentationController.presentedViewController === areaDetailFloatingPanel {
            print("Area Detail Floating Panel was dismissed")
            if let selectedAnnotation = mapView.selectedAnnotations.first {
                mapView.deselectAnnotation(selectedAnnotation, animated: true)
            }
        } else if presentationController.presentedViewController === streetFloatingPanel {
            print("Street Floating Panel was dismissed")
            configureAndPresentAreaPanel()
        }
    }
}

// MARK: - MapManagerDelegate
extension MapViewController: MapManagerDelegate {
    func didFetchAreaData(_ areasModel: [AreaModel]) {
        self.areas = areasModel
        
        areas?.forEach { area in
            addAreaAnnotation(
                title: area.areaName,
                availableParking: area.availableParkingString,
                latitude: area.latitude,
                longtitude: area.longtitude,
                area: area
            )
        }
    }
    
    func didFetchStreetAndParkingSpotData(_ streetsModel: [StreetModel]) {
        DispatchQueue.main.async {
            if let areaDetailFloatingPanel = self.areaDetailFloatingPanel {
                areaDetailFloatingPanel.streetModels = streetsModel
                self.present(areaDetailFloatingPanel, animated: true)
            }
        }
    }
    
    func didFetchParkingSpotData(_ availableParkingSpotModel: [ParkingSpotModel]) {
        DispatchQueue.main.async {
            self.contentViewController.updateParkingSpots(availableParkingSpotModel)
        }
    }
}
//MARK: - AreaInformationViewControllerDelegate
extension MapViewController: AreaInformationViewControllerDelegate {
    
    func areaTableRowDidSelected(_ streetModel: StreetModel) {
        print("map view controller have been received that the street row in area floating panel view have been selected")
        // Dismiss areaDetailFloatingPanel if needed
        guard let areaDetailFloatingPanel = areaDetailFloatingPanel else {return}
        areaDetailFloatingPanel.dismiss(animated: true) { [self] in
            streetFloatingPanel = StreetInformationViewController()
            guard let streetFloatingPanel = streetFloatingPanel else {return}
            streetFloatingPanel.streetModel = streetModel
            streetFloatingPanel.delegate = self
            streetFloatingPanel.userLocation = self.userLocation?.location
            streetFloatingPanel.presentationController?.delegate = self
            
            streetFloatingPanel.modalPresentationStyle = .formSheet
            
            if let sheet = streetFloatingPanel.sheetPresentationController {
                sheet.detents = [
                    .medium(),
                    .large()
                ]
                sheet.prefersGrabberVisible = true
                sheet.prefersScrollingExpandsWhenScrolledToEdge = true
            }
            
            self.present(streetFloatingPanel, animated: true, completion: nil)
        }
    }
}

//MARK: - StreetInformationViewControllerDelegate
extension MapViewController: StreetInformationViewControllerDelegate {
    func parkingSpotRowDidSelected(_ parkingSpotModel: ParkingSpotModel) {
        areaAnnotations = mapView.annotations
        mapView.deselectAnnotation(selectedAreaAnnotation, animated: false)
        mapView.removeAnnotations(mapView.annotations)// remove all annotation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            let parkingLocation = CLLocationCoordinate2D(latitude: parkingSpotModel.latitude, longitude: parkingSpotModel.longitude)
            let stringParkingLotID = String(parkingSpotModel.parkingSpotID)
            let annotation = ParkingAnnotation(parkingLotID: stringParkingLotID, coordinate: parkingLocation, parkingSpotModel: parkingSpotModel)
            self.mapView.addAnnotation(annotation)
            self.mapView.selectAnnotation(annotation, animated: true)
        }
    }
}

//MARK: - ParkingFinderTableViewCellDelegate

extension MapViewController: ParkingFinderTableViewCellDelegate {
    func evParkingButtonDidPress() {
        print("have pressed")
    }
    
    func disableParkingButtonDidPress() {
        print("have pressed")
    }
    
    func nearestParkingButtonDidPress() {
        mapManager.fetchParkingSpotData()
    }
}

extension MapViewController: SearchTextFieldDelegate {
    func nearestParkingSpotDidSelect(_ selectedParkingSpot: ParkingSpotModel) {
        areaAnnotations = mapView.annotations
        mapView.deselectAnnotation(selectedAreaAnnotation, animated: false)
        mapView.removeAnnotations(mapView.annotations)// remove all annotation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            let parkingLocation = CLLocationCoordinate2D(latitude: selectedParkingSpot.latitude, longitude: selectedParkingSpot.longitude)
            let stringParkingLotID = String(selectedParkingSpot.parkingSpotID)
            let annotation = ParkingAnnotation(parkingLotID: stringParkingLotID, coordinate: parkingLocation, parkingSpotModel: selectedParkingSpot)
            self.mapView.addAnnotation(annotation)
            self.mapView.selectAnnotation(annotation, animated: true)
        }
    }
    
    func searchTextFieldDidSelect() {

        let parkingSpotListVC = ParkingSpotListViewController()
        parkingSpotListVC.delegate = self
        navigationController?.pushViewController(parkingSpotListVC, animated: true)
    }
}

extension MapViewController: ParkingSpotListViewControllerDelegate {
    func didSelectParkingSpot(_ parkingSpot: ParkingSpotModel) {
        let vc = ParkingSpotDetailsViewController()
        vc.parkingSpotModel = parkingSpot
        navigationController?.pushViewController(vc, animated: true)
    }
}

//MARK: - NearestParkingViewControllerDelegate

extension MapViewController: NearestParkingViewControllerDelegate {
    func didSelectedNearestParking(_ nearestParkingModel: ParkingSpotModel) {
        areaAnnotations = mapView.annotations
        selectedAreaAnnotation = nil
        mapView.removeAnnotations(mapView.annotations)// remove all annotation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            let parkingLocation = CLLocationCoordinate2D(latitude: nearestParkingModel.latitude, longitude: nearestParkingModel.longitude)
            let stringParkingLotID = String(nearestParkingModel.parkingSpotID)
            let annotation = ParkingAnnotation(parkingLotID: stringParkingLotID, coordinate: parkingLocation, parkingSpotModel: nearestParkingModel)
            self.mapView.addAnnotation(annotation)
            self.mapView.selectAnnotation(annotation, animated: true)
            self.nearestParkingfloatingPanel.removePanelFromParent(animated: true)
        }
    }
    
    func didDismissViewController() {
        self.floatingPanelController.move(to: .half, animated: false)
    }
}


#Preview {
    MapViewController()
}
