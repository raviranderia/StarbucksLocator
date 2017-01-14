//
//  GooglePlacesManager.swift
//  StarbucksLocator
//
//  Created by RAVI RANDERIA on 1/13/17.
//  Copyright © 2017 RAVI RANDERIA. All rights reserved.
//

import Foundation
import UIKit

protocol GooglePlacesManagerDelegate: class {
    func fetchedNewStores(sender: Any?)
}

class GooglePlacesManager {
    private let requestManager = RequestManager.shared
    private let locationManager = LocationManager.shared
    private let defaultRadius = 100
    private let dataManager = DataManager.shared
    
    static let shared = GooglePlacesManager()
    private init() {}
    
    weak var delegate: GooglePlacesManagerDelegate?
    
    func fetchNearbyStarbucksStores() {
        locationManager.getCurrentLocation { (locationResult) in
            switch locationResult {
            case .success(let location):
                requestManager.fetchNearbyStarbucksStores(location: location, radius: defaultRadius, completion: { (result) in
                    switch result {
                    case .success(let responseDictionary):
                        self.mapDictionaryToStarbucksModelArray(responseDictionary: responseDictionary, completion: { (starbucksStoreList) in
                            DispatchQueue.main.async {
                                self.delegate?.fetchedNewStores(sender: self)
                            }
                        })
                    case .failure(let error):
                        print(error)
                    }
                    
                })
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func mapDictionaryToStarbucksModelArray(responseDictionary: [String: Any], completion: (Result<[StarbucksStoreInformation]>) -> ()) {
        if let results = responseDictionary["results"] as? [[String: Any]] {
            dataManager.removeStoredData() { (result) in
                switch result {
                case .success(_):
                    completion(.success(results.map(){ (storeJSON) -> StarbucksStoreInformation in
                        let starbucksStore = StarbucksStoreInformation(starbucksJSON: storeJSON)
                        dataManager.saveStarbucksStoreInfo(starbucksStore: starbucksStore)
                        return starbucksStore
                    }))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        } else {
            completion(.failure(NetworkOperationError.errorJSON))
        }
        
    }
}
