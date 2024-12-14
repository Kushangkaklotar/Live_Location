//
//  LocationUpdate.swift
//  LiveLocationTrack
//
//  Created by Kushang  on 14/12/24.
//

import Foundation
import UIKit
import MapKit

class MutablePolylineRenderer: MKOverlayPathRenderer {
    var pathCoordinates: [CLLocationCoordinate2D]

    init(overlay: MKOverlay, coordinates: [CLLocationCoordinate2D]) {
        self.pathCoordinates = coordinates
        super.init(overlay: overlay)
        createPath()
    }

    override func createPath() {
        let path = CGMutablePath()
        guard pathCoordinates.count > 1 else { return }
 
        let firstPoint = point(for: MKMapPoint(pathCoordinates[0]))
        path.move(to: firstPoint)
        for coordinate in pathCoordinates.dropFirst() {
            let nextPoint = point(for: MKMapPoint(coordinate))
            path.addLine(to: nextPoint)
        }
        self.path = path

    }

    func updateCoordinates(_ newCoordinates: [CLLocationCoordinate2D]) {
        self.pathCoordinates = newCoordinates
        createPath()
        setNeedsDisplay()
    }
}
