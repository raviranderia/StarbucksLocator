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
}

enum LocationError : Error {
    case notAuthorized
    case locationServicesDisabled
}

struct LocationManager : LocationManagerProtocol {
    
    static let shared = LocationManager()
    private init() {}
    
    private var locationManager = CLLocationManager()
    private var reverseGeoCoder = CLGeocoder()
    
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
