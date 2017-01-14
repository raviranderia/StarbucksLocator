//
//  StarbucksInformationCellViewModel.swift
//  StarbucksLocator
//
//  Created by RAVI RANDERIA on 1/12/17.
//  Copyright © 2017 RAVI RANDERIA. All rights reserved.
//

import Foundation
import UIKit

struct StarbucksInformationCellViewModel {
    
    var name: String?
    var address: String?
    var photoReference: String?
    var starbucksStoreImage: UIImage?
    var id: String?
    
    var starbucksStoreInformation: StarbucksStoreInformation
    
    init(starbucksStoreInformation: StarbucksStoreInformation) {
        self.name = starbucksStoreInformation.name
        self.address = starbucksStoreInformation.formattedAddress
        self.photoReference = starbucksStoreInformation.photoReference
        self.starbucksStoreImage = starbucksStoreInformation.starbucksImage
        self.id = starbucksStoreInformation.id
        self.starbucksStoreInformation = starbucksStoreInformation
    }
}
