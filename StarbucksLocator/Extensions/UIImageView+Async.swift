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
    
    func getImageFrom(photoReference: String) {
        let maxWidth = UIScreen.main.bounds.width
        RequestManager.shared.getImageFromURL(photoReference: photoReference, maxWidth: maxWidth, completion: { (result) in
            switch result {
            case .success(let image):
                DispatchQueue.main.async {
                    self.image = image
                }
            case .failure(_):
                break
            }
        })
    }
}
