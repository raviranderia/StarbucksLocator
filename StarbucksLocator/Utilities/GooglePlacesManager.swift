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
    private let dataManager = CoreDataManager.shared
    private let defaultRadius = 100

    static let shared = GooglePlacesManager()
    private init() {}
    
    weak var delegate: GooglePlacesManagerDelegate?
    
    func fetchNearbyStarbucksStores() {
        locationManager.getCurrentLocation { (locationResult) in
            switch locationResult {
            case .success(let location):
                requestManager.fetchNearbyStarbucksStores(location: location, radius: defaultRadius) { (result) in
                    switch result {
                    case .success(let responseDictionary):
                        self.mapDictionaryToStarbucksModelArray(responseDictionary: responseDictionary) { (results) in
                            switch results {
                            case .success(_):
                                self.delegate?.fetchedNewStores(sender: self)
                            default:
                                break
                            }
                        }
                    case .failure(let error):
                        print(error)
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func mapDictionaryToStarbucksModelArray(responseDictionary: [String: Any], completion: @escaping (Result<[StarbucksStoreInformation]>) -> ()) {
        if let results = responseDictionary["results"] as? [[String: Any]],
            results.count > 0 {
            dataManager.removeStoredData()
            completion(.success(results.map(){ (storeJSON) -> StarbucksStoreInformation in
                let starbucksStore = StarbucksStoreInformation(starbucksJSON: storeJSON)
                dataManager.saveStarbucksStoreInfo(starbucksStore: starbucksStore)
                return starbucksStore
            }))
        } else {
            completion(.failure(NetworkOperationError.errorJSON))
        }
    }
}
