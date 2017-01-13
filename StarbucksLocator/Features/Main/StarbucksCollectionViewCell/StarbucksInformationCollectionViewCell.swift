//
//  StarbucksInformationCollectionViewCell.swift
//  StarbucksLocator
//
//  Created by RAVI RANDERIA on 1/12/17.
//  Copyright © 2017 RAVI RANDERIA. All rights reserved.
//

import UIKit

class StarbucksInformationCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var starbucksImageView: UIImageView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    
    func configureCell(starbucksInformationCellViewModel: StarbucksInformationCellViewModel) {
        self.addressLabel.text = starbucksInformationCellViewModel.address
        if let photoReference = starbucksInformationCellViewModel.photoReference {
            self.starbucksImageView.getImageFrom(photoReference: photoReference)
        }
        
    }
}
