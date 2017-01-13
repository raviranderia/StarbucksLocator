//
//  MainViewModel.swift
//  StarbucksLocator
//
//  Created by RAVI RANDERIA on 1/13/17.
//  Copyright © 2017 RAVI RANDERIA. All rights reserved.
//

import Foundation

struct MainViewModel {
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
