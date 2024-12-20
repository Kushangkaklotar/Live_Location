//
//  HomeScreen.swift
//  LiveLocationTrack
//
//  Created by Kushang  on 15/12/24.
//

import UIKit
import MapKit

class HomeScreen: UIViewController {
    // MARK: - IB Outlet
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var locationButton: UIButton!
    
    // MARK: - Variables
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation!
    var locationArray: [MapModel] = []
    
    // MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialise()
    }
    
    // MARK: - Function's
    func initialise(){
        self.manageUI()
        self.mapView.delegate = self
        self.locationManager.delegate = self
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.startUpdatingLocation()
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(self.getCoordinatePressOnMap(sender:)))
        gestureRecognizer.numberOfTapsRequired = 1
        self.mapView.addGestureRecognizer(gestureRecognizer)
    }
    
    func manageUI(){
        self.locationButton.layer.cornerRadius = 10
    }
    // MARK: - IB  Actoin method
    @IBAction func onLocationTrack(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Location", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "LocationScreenViewController") as? LocationScreenViewController {
            vc.currentLocation = self.locationArray.first(where: {$0.id == 1})?.coordinate ?? CLLocationCoordinate2D()
            vc.DestinationLocation = self.locationArray.first(where: {$0.id == 2})?.coordinate ?? CLLocationCoordinate2D()
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

// MARK: - Extension
extension HomeScreen {
    func addAnnotaion(){
        for _annotation in self.mapView.annotations {
            if let annotation = _annotation as? MKAnnotation {
                self.mapView.removeAnnotation(annotation)
            }
        }
        for location in locationArray {
            let pin = MapModel(id: location.id, coordinate: location.coordinate, name: location.name)
            self.mapView.addAnnotation(pin)
        }
        if self.locationArray.count == 1 {
            self.ZoomToLocation(location: self.locationArray.first(where: {$0.id == 1})?.coordinate ?? CLLocationCoordinate2D())
        } else if self.locationArray.count == 2 {
            self.locationButton.isHidden = false
            self.showRouteOnMap(pickupCoordinate: self.locationArray.first(where: {$0.id == 1})?.coordinate ?? CLLocationCoordinate2D(), destinationCoordinate: self.locationArray.first(where: {$0.id == 2})?.coordinate ?? CLLocationCoordinate2D())
        }
    }
    func showRouteOnMap(pickupCoordinate: CLLocationCoordinate2D, destinationCoordinate: CLLocationCoordinate2D) {
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: pickupCoordinate, addressDictionary: nil))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destinationCoordinate, addressDictionary: nil))
        request.requestsAlternateRoutes = true
        request.transportType = .automobile
        
        let directions = MKDirections(request: request)
        
        directions.calculate { [unowned self] response, error in
            guard let unwrappedResponse = response else { return }
            self.mapView.removeOverlays(self.mapView.overlays)
            if let route = unwrappedResponse.routes.first {
                self.mapView.addOverlay(route.polyline)
//                if self.isUpdatelocation == false {
                    self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, edgePadding: UIEdgeInsets.init(top: 20.0, left: 20.0, bottom: 20.0, right: 20.0), animated: true)
//                }
//                self.timer?.invalidate()
//                self.timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(updateLocation), userInfo: nil, repeats: true)
            }
        }
    }
    func ZoomToLocation(location: CLLocationCoordinate2D) {
        let location = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: location, span: span)
        self.mapView.setRegion(region, animated: true)
    }
    
    @objc func getCoordinatePressOnMap(sender: UITapGestureRecognizer) {
        let touchLocation = sender.location(in: self.mapView)
        let locationCoordinate = self.mapView.convert(touchLocation, toCoordinateFrom: self.mapView)
//        if let removeId = self.locationArray.first(where: {$0.id == 2})?.id {
        self.locationArray.removeAll(where: {$0.id == 2})
        self.locationArray.append(MapModel(id: 2, coordinate: CLLocationCoordinate2D(latitude: locationCoordinate.latitude, longitude: locationCoordinate.longitude), name: "Destination location"))
        self.addAnnotaion()
//        }
//        let liveLocationPin = MKPointAnnotation()
//        liveLocationPin.coordinate = CLLocationCoordinate2D(latitude: locationCoordinate.latitude,longitude: locationCoordinate.longitude)
//        self.mapView.addAnnotation(liveLocationPin)
    }
}

// MARK: - Delegate method
extension HomeScreen: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation :CLLocation = locations[0] as CLLocation
        let location = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        print("Current location >>>>>>>>>>>>>>> \(location.latitude), \(location.longitude)")
        self.locationArray.removeAll()
        self.locationArray.append(MapModel(id: 1, coordinate: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude), name: "Current location"))
        self.addAnnotaion()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:\(error)")
    }
}

extension HomeScreen: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation { return nil }
        if let annotation = annotation as? MapModel {
            var annotationView = self.mapView.dequeueReusableAnnotationView(withIdentifier: "id")
            
            if annotationView == nil {
                annotationView?.canShowCallout = true
                let pin = MKAnnotationView(annotation: annotation, reuseIdentifier: String(annotation.id ?? 0))
                
                let nameLabel = UILabel(frame: CGRect(x: 10, y: 3, width: 30, height: Int(30)))
                nameLabel.text = nil
                nameLabel.text = String(annotation.id ?? 10)
                nameLabel.textAlignment = .center
                nameLabel.textColor = UIColor.white
                nameLabel.backgroundColor = UIColor.black
                
                pin.addSubview(nameLabel)
                annotationView = pin
                return annotationView
            }
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKGradientPolylineRenderer(overlay: overlay)
        renderer.invalidatePath()
        renderer.setColors([UIColor.black], locations: [])
        renderer.lineCap = .round
        renderer.lineWidth = 5.0
        
        return renderer
    }
}
// MARK: - API Call
