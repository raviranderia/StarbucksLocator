//
//  LocationManagerMock.swift
//  StarbucksLocator
//
//  Created by RAVI RANDERIA on 1/15/17.
//  Copyright © 2017 RAVI RANDERIA. All rights reserved.
//

import Foundation
import CoreLocation

@testable import StarbucksLocator

class CoreLocationManagerMock: CoreLocationManagerProtocol {
    var delegate: CLLocationManagerDelegate?
    static func authorizationStatus() -> CLAuthorizationStatus {
        return .authorizedWhenInUse
    }
    var location: CLLocation?
    func requestWhenInUseAuthorization() {
        
    }
    
}

struct LocationManagerMock: LocationManagerProtocol {
    var locationManager: CoreLocationManagerProtocol
    
    init() {
        self.locationManager = CoreLocationManagerMock()
    }
    
    func getCurrentLocation(completion: (Result<CLLocation>) -> ()) {
        let latitude = CLLocationDegrees(exactly: 42.3208)
        let longitude = CLLocationDegrees(exactly: -71.6804)
        completion(.success(CLLocation(latitude: latitude!, longitude: longitude!)))
    }
}
