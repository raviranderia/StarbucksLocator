//
//  ErrorViewController.swift
//  StarbucksLocator
//
//  Created by RAVI RANDERIA on 1/14/17.
//  Copyright © 2017 RAVI RANDERIA. All rights reserved.
//

import UIKit
import CoreLocation

protocol ErrorViewControllerDelegate: class {
    func errorResolved()
}

class ErrorViewController: UIViewController, CLLocationManagerDelegate {
    
    var errorMessage: String?
    let locationManager = LocationManager.shared
    weak var delegate: ErrorViewControllerDelegate?

    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.locationManager.delegate = self
        if let errorMessage = errorMessage {
            errorLabel.text = errorMessage
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            dismiss(animated: true, completion: { 
                self.delegate?.errorResolved()
            })
        }
    }
}
