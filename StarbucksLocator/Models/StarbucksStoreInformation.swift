//
//  StarbucksInformation.swift
//  StarbucksLocator
//
//  Created by RAVI RANDERIA on 1/12/17.
//  Copyright © 2017 RAVI RANDERIA. All rights reserved.
//

import Foundation
import CoreLocation
import CoreData
import UIKit

final class StarbucksStoreInformation {
    private let requestManager = RequestManager.shared

    var formattedAddress: String?
    var location: CLLocation?
    var name: String?
    var photoReference: String?
    var id: String?
    
    var starbucksImage: UIImage?
    
    // From JSON recieved as response from network request
    init(starbucksJSON: [String: Any]) {
        if let formattedAddress = starbucksJSON["formatted_address"] as? String {
            self.formattedAddress = formattedAddress
        }
        
        if let name = starbucksJSON["name"] as? String {
            self.name = name
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
    
    // From NSManaged object recieved as response from CoreData
    init(managedObject: NSManagedObject) {
        if let formattedAddress = managedObject.value(forKey: "formattedAddress") as? String {
            self.formattedAddress = formattedAddress
        }
        
        if let photoReference = managedObject.value(forKey: "photoReference") as? String {
            self.photoReference = photoReference
        }
        
        if let name = managedObject.value(forKey: "name") as? String {
            self.name = name
        }
        
        if let imageData = managedObject.value(forKey: "photo") as? Data,
            let image = UIImage(data: imageData) {
            self.starbucksImage = image
        }
        
        if let id = managedObject.value(forKey: "id") as? String {
            self.id = id
        }
        
        if let latitude = managedObject.value(forKey: "latitude") as? Double,
            let longitude = managedObject.value(forKey: "longitude") as? Double,
            let latitudeDegrees = CLLocationDegrees(exactly: latitude),
            let longitudeDegrees = CLLocationDegrees(exactly: longitude) {
            self.location = CLLocation(latitude: latitudeDegrees, longitude: longitudeDegrees)
        } else {
            self.location = nil
        }
    }
}

