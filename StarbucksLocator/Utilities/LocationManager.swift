//
//  LocationManager.swift
//  StarbucksLocator
//
//  Created by RAVI RANDERIA on 1/13/17.
//  Copyright © 2017 RAVI RANDERIA. All rights reserved.
//

import Foundation
import CoreLocation

protocol LocationManagerProtocol {
    func getCurrentLocation(completion : (Result<CLLocation>) -> () )
    var locationManager: CoreLocationManagerProtocol { set get }
}

enum LocationError : Error {
    case notAuthorized
    case locationServicesDisabled
}

protocol CoreLocationManagerProtocol {
    static func authorizationStatus() -> CLAuthorizationStatus
    var location: CLLocation? {get}
    func requestWhenInUseAuthorization()
    var delegate: CLLocationManagerDelegate? { set get }
}

extension CLLocationManager: CoreLocationManagerProtocol {}

final class LocationManager : LocationManagerProtocol {
    var locationManager: CoreLocationManagerProtocol

    static let shared = LocationManager()
    private init(locationManager: CoreLocationManagerProtocol = CLLocationManager()) {
        self.locationManager = locationManager
        requestForLocationServices()
    }
    
    
    private func requestForLocationServices(){
        locationManager.requestWhenInUseAuthorization()
    }
    
    func getCurrentLocation(completion : (Result<CLLocation>) -> () )  {
        self.requestForLocationServices()
        if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse {
            if let currentLocation = locationManager.location {
                completion(.success(currentLocation))
            } else {
                completion(.failure(LocationError.locationServicesDisabled))
            }
        } else{
            completion(.failure(LocationError.notAuthorized))
        }
    }
    
}
