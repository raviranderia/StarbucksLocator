//
//  MainViewModel.swift
//  StarbucksLocator
//
//  Created by RAVI RANDERIA on 1/13/17.
//  Copyright © 2017 RAVI RANDERIA. All rights reserved.
//

import Foundation
import CoreData

struct MainViewModel {
    let segueIdentifer = "showStarbucksOnMap"
    let collectionViewCellIdentifier = "Cell"
    
    var starbucksStore = [NSManagedObject]()
    
    private let googlePlacesManager = GooglePlacesManager.shared

    func fetchNearbyStarbucksStores(completion: @escaping (Result<[StarbucksStoreInformation]>) -> ()) {
        DispatchQueue.global().async {
            self.googlePlacesManager.fetchNearbyStarbucksStores { (starbucksStoreList) in
                DispatchQueue.main.async {
                    print(starbucksStoreList)
                    completion(starbucksStoreList)
                }
            }
        }
       
    }
}
