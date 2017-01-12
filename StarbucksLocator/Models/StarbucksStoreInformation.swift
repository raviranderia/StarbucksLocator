//
//  StarbucksInformation.swift
//  StarbucksLocator
//
//  Created by RAVI RANDERIA on 1/12/17.
//  Copyright © 2017 RAVI RANDERIA. All rights reserved.
//

import Foundation
import CoreLocation

struct StarbucksStoreInformation {
    let formattedAddress: String
    let location: CLLocation?
    let iconURL: URL?
    let name: String
    let openNow: Bool
    let priceLevel: Int
    
    init(formattedAddress: String, latitude: CLLocationDegrees, longitude: Double, iconURLString: String, name: String, openNow: Bool, priceLevel: Int) {
        self.formattedAddress = formattedAddress
        self.iconURL = URL(string: iconURLString)
        self.name = name
        self.openNow = openNow
        self.priceLevel = priceLevel
        if let latitudeDegrees = CLLocationDegrees(exactly: latitude), let longitudeDegrees = CLLocationDegrees(exactly: longitude) {
            self.location = CLLocation(latitude: latitudeDegrees, longitude: longitudeDegrees)
        } else {
            self.location = nil
        }
    }
}
