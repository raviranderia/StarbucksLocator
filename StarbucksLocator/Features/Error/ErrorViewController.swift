//
//  ErrorViewController.swift
//  StarbucksLocator
//
//  Created by RAVI RANDERIA on 1/14/17.
//  Copyright © 2017 RAVI RANDERIA. All rights reserved.
//

import UIKit
import CoreLocation

enum FeedError: Error {
    case LocationServicesDisabled
    case InvalidData
}

protocol ErrorViewControllerDelegate: class {
    func errorResolved(error: FeedError)
}

class ErrorViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var refreshButton: UIButton!
    
    var feedError: FeedError?
    let locationManager = LocationManager.shared
    weak var delegate: ErrorViewControllerDelegate?

    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.locationManager.delegate = self
        if let feedError = feedError {
            switch feedError {
            case .LocationServicesDisabled:
                errorLabel.text = "Please go to settings to enable location services"
            case .InvalidData:
                errorLabel.text = "No data to display, try again later"
                refreshButton.isHidden = false
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            dismiss(animated: true, completion: { 
                self.delegate?.errorResolved(error: .LocationServicesDisabled)
            })
        }
    }
    
    @IBAction func refreshButtonPressed(_ sender: UIButton) {
        delegate?.errorResolved(error: .InvalidData)
    }
    
}
