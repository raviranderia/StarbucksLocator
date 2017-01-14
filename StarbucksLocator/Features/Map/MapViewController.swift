//
//  MapViewController.swift
//  StarbucksLocator
//
//  Created by RAVI RANDERIA on 1/13/17.
//  Copyright © 2017 RAVI RANDERIA. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    var currentStarbucksStoreInfo: StarbucksStoreInformation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let location = currentStarbucksStoreInfo?.location {
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = location.coordinate
            annotation.title = currentStarbucksStoreInfo?.name
            annotation.subtitle = currentStarbucksStoreInfo?.formattedAddress
            mapView.addAnnotation(annotation)
            
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            mapView.setRegion(MKCoordinateRegion(center: location.coordinate, span: span), animated: true)
        }
    }
    

}
