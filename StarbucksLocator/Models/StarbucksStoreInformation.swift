//
//  StarbucksInformation.swift
//  StarbucksLocator
//
//  Created by RAVI RANDERIA on 1/12/17.
//  Copyright © 2017 RAVI RANDERIA. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

class StarbucksStoreInformation {
    private let requestManager = RequestManager.shared

    var formattedAddress: String?
    var location: CLLocation?
    var name: String?
    var openNow: Bool?
    var priceLevel: Int?
    var photoReference: String?
    var id: String?
    
    var starbucksStoreImage: UIImage?
    
    init(starbucksJSON: [String: Any]) {
        if let formattedAddress = starbucksJSON["formatted_address"] as? String {
            self.formattedAddress = formattedAddress
        }
        
        if let name = starbucksJSON["name"] as? String {
            self.name = name
        }
        
        if let openingHours = starbucksJSON["opening_hours"] as? [String: Any],
            let openNow = openingHours["open_now"] as? Bool {
            self.openNow = openNow
        }
        
        if let priceLevel = starbucksJSON["price_level"] as? Int {
            self.priceLevel = priceLevel
        }
        
        if let photos = starbucksJSON["photos"] as? [[String: Any]],
            let photoReference = photos[0]["photo_reference"] as? String {
            self.photoReference = photoReference
        }
        
        if let id = starbucksJSON["id"] as? String {
            self.id = id
        }
        
        if let geometry = starbucksJSON["geometry"] as? [String: Any],
            let location = geometry["location"] as? [String: Any],
            let latitude = location["lat"] as? Double,
            let longitude = location["lng"] as? Double,
            let latitudeDegrees = CLLocationDegrees(exactly: latitude),
            let longitudeDegrees = CLLocationDegrees(exactly: longitude) {
                self.location = CLLocation(latitude: latitudeDegrees, longitude: longitudeDegrees)
            } else {
                self.location = nil
            }
        }
}

