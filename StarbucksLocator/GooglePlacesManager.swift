//
//  GooglePlacesManager.swift
//  StarbucksLocator
//
//  Created by RAVI RANDERIA on 1/13/17.
//  Copyright © 2017 RAVI RANDERIA. All rights reserved.
//

import Foundation

struct GooglePlacesManager {
    private let requestManager = RequestManager.shared
    private let locationManager = LocationManager.shared
    private let defaultRadius = 100
    private let dataManager = DataManager.shared
    
    static let shared = GooglePlacesManager()
    private init() {}
    
    func fetchNearbyStarbucksStores(completion: @escaping (Result<[StarbucksStoreInformation]>) -> ()) {
        locationManager.getCurrentLocation { (locationResult) in
            switch locationResult {
            case .success(let location):
                requestManager.fetchNearbyStarbucksStores(location: location, radius: defaultRadius, completion: { (result) in
                    switch result {
                    case .success(let responseDictionary):
                        self.mapDictionaryToStarbucksModelArray(responseDictionary: responseDictionary, completion: { (starbucksStoreList) in
                            completion(starbucksStoreList)
                        })
                    case .failure(let error):
                        completion(.failure(error))
                    }
                    
                })
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func mapDictionaryToStarbucksModelArray(responseDictionary: [String: Any], completion: (Result<[StarbucksStoreInformation]>) -> ()) {
        var starbucksStoreList = [StarbucksStoreInformation]()
        if let results = responseDictionary["results"] as? [[String: Any]] {
            for storeInformation in results {
                let starbucksInformation = StarbucksStoreInformation(starbucksJSON: storeInformation)
                starbucksStoreList.append(starbucksInformation)
                dataManager.saveStarbucksStoreInfo(starbucksStore: starbucksInformation)
            }
            completion(.success(starbucksStoreList))
        } else {
            completion(.failure(NetworkOperationError.errorJSON))
        }
        
    }
}
