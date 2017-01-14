//
//  MainViewModel.swift
//  StarbucksLocator
//
//  Created by RAVI RANDERIA on 1/13/17.
//  Copyright © 2017 RAVI RANDERIA. All rights reserved.
//

import Foundation
import CoreData

protocol MainViewModelDelegate: class {
    func reloadCollectionView(completion: @escaping () -> ())
}

class MainViewModel: GooglePlacesManagerDelegate {
    let segueIdentifer = "showStarbucksOnMap"
    let collectionViewCellIdentifier = "Cell"
    var starbucksStore = [StarbucksStoreInformation]()
    
    weak var delegate: MainViewModelDelegate?
    
    private weak var dataManager = DataManager.shared
    private var googlePlacesManager = GooglePlacesManager.shared
    
    init() {
        googlePlacesManager.delegate = self
    }
    
    func fetchNearbyStarbucksStores(completion: @escaping (Result<[StarbucksStoreInformation]>) -> ())  {
        DispatchQueue.global().async {
            self.dataManager?.fetchStoreData() { (result) in
                DispatchQueue.main.async {
                    completion(result)
                }
            }
        }
    }
    
    func fetchFreshData() {
        googlePlacesManager.fetchNearbyStarbucksStores()
    }
    
    func fetchedNewStores(sender: Any?) {
        delegate?.reloadCollectionView { }
    }
}
