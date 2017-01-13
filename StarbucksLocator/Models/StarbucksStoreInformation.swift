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

struct StarbucksStoreInformation {
    var formattedAddress: String?
    var location: CLLocation?
    var iconURL: URL?
    var name: String?
    var openNow: Bool?
    var priceLevel: Int?
    var photoReference: String?
    
//    var starbucksStoreImage: UIImage?
//    var iconImage: UIImage?
    
    init(starbucksJSON: [String: Any]) {
        if let formattedAddress = starbucksJSON["formatted_address"] as? String {
            self.formattedAddress = formattedAddress
        }
        
        if let iconURLString = starbucksJSON["icon"] as? String, let url = URL(string: iconURLString) {
            self.iconURL = url
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
     
//        if let photoReference = self.photoReference {
//            
//        }
        
    }
}

