//
//  LocationScreenViewController.swift
//  LiveLocationTrack
//
//  Created by Kushang  on 14/12/24.
//

import UIKit
import MapKit
import Foundation

class MapModel: NSObject, MKAnnotation  {

    var id: Int?
    var coordinate: CLLocationCoordinate2D
    var name: String?
    var type: Int?
    
    init(id: Int? = nil, coordinate: CLLocationCoordinate2D, name: String? = nil, type: Int? = nil) {
        self.id = id
        self.coordinate = coordinate
        self.name = name
        self.type = type
    }
}

class LocationScreenViewController: UIViewController {

    // MARK: - IB Outlets
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: - Variables
    var timer: Timer?
    var locationArray: [MapModel] = []
    var isUpdatelocation = false
    var currentLocation: CLLocationCoordinate2D?
    var DestinationLocation: CLLocationCoordinate2D?
    
    // MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.locationArray.append(MapModel(id: 1, coordinate: CLLocationCoordinate2D(latitude: self.DestinationLocation?.latitude ?? 0.00, longitude: self.DestinationLocation?.longitude ?? 0.00), name: "Destination location"))
        self.locationArray.append(MapModel(id: 2, coordinate: CLLocationCoordinate2D(latitude: self.currentLocation?.latitude ?? 0.00, longitude: self.currentLocation?.longitude ?? 0.00), name: "Current location"))
        self.addAnnotaion()
        self.mapView.delegate = self
    }
    
    // MARK: - Annotaion add
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
        self.showRouteOnMap(pickupCoordinate: self.locationArray.first(where: {$0.id == 1})?.coordinate ?? CLLocationCoordinate2D(), destinationCoordinate: self.locationArray.first(where: {$0.id == 2})?.coordinate ?? CLLocationCoordinate2D())
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
                if self.isUpdatelocation == false {
                    self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, edgePadding: UIEdgeInsets.init(top: 20.0, left: 20.0, bottom: 20.0, right: 20.0), animated: true)
                }
                self.timer?.invalidate()
                self.timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(updateLocation), userInfo: nil, repeats: true)
            }
        }
    }
    @objc func updateLocation() {
        self.isUpdatelocation = true
        let newLocation = self.locationArray.first(where: {$0.id == 2})?.coordinate ?? CLLocationCoordinate2D()
        self.locationArray.removeAll(where: {$0.id == 2})
        self.locationArray.append(MapModel(id: 2, coordinate: CLLocationCoordinate2D(latitude: newLocation.latitude + 0.0001, longitude: newLocation.longitude + 0.0001), name: "Live location"))
        print("New locatin >>>>>>>>>>>>>>>>> \(newLocation.latitude + 0.01) \(newLocation.longitude + 0.01)")
        self.addAnnotaion()
    }
}

extension LocationScreenViewController: MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation { return nil }
        if let annotation = annotation as? MapModel {
            var annotationView = self.mapView.dequeueReusableAnnotationView(withIdentifier: String(annotation.id ?? 0))
            let pin = MKAnnotationView(annotation: annotation, reuseIdentifier: String(annotation.id ?? 0))
            
            let label = UILabel()
            label.backgroundColor = .black
            label.textColor = .white
            label.text = annotation.name
            
            let backgroundView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
            backgroundView.layer.cornerRadius = backgroundView.frame.height / 2
            backgroundView.backgroundColor = UIColor.red
            
//            let annotationImage = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
//            annotationImage.image = UIImage(named: "map_annotaion_ic")
//            annotationImage.layer.cornerRadius = 25
            
            pin.addSubview(backgroundView)
            annotationView = pin
            return annotationView
//            backGroundView.frame.height
//            backGroundView.frame.width = 20
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
