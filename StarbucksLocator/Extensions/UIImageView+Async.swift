//
//  UIImageView+Async.swift
//  StarbucksLocator
//
//  Created by RAVI RANDERIA on 1/13/17.
//  Copyright © 2017 RAVI RANDERIA. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {
    
    func getImageFrom(photoReference: String,andId id: String, starbucksStoreInformation: StarbucksStoreInformation) {
        let dataManager = CoreDataManager.shared
        let maxWidth = UIScreen.main.bounds.width
        RequestManager.shared.getImageFromURL(photoReference: photoReference, maxWidth: maxWidth, completion: { (result) in
            switch result {
            case .success(let image):
                    dataManager.saveImageFromOperationQueue(image: image, forId: id)
                    DispatchQueue.main.async {
                        self.image = image
                        starbucksStoreInformation.starbucksImage = image
                    }
            case .failure(_):
                break
            }
        })
    }
}
