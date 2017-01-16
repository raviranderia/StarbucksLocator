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

protocol GooglePlacesManagerProtocol {
    func fetchNearbyStarbucksStores(completion: @escaping (Result<[StarbucksStoreInformation]>) -> ())
    var delegate: GooglePlacesManagerDelegate? { set get }
    var requestManager: RequestManagerProtocol { get }
    init(requestManager: RequestManagerProtocol)
}

final class GooglePlacesManager: GooglePlacesManagerProtocol {
    private let locationManager = LocationManager.shared
    private let dataManager = CoreDataManager.shared
    private let defaultRadius = 100
    let requestManager: RequestManagerProtocol

    static let shared = GooglePlacesManager()
    
    internal init(requestManager: RequestManagerProtocol = RequestManager.shared) {
        self.requestManager = requestManager
    }
    
    weak var delegate: GooglePlacesManagerDelegate?
    
    func fetchNearbyStarbucksStores(completion: @escaping (Result<[StarbucksStoreInformation]>) -> ()) {
        locationManager.getCurrentLocation { (locationResult) in
            switch locationResult {
            case .success(let location):
                requestManager.fetchNearbyStarbucksStores(location: location, radius: defaultRadius) { (result) in
                    switch result {
                    case .success(let responseDictionary):
                        self.mapDictionaryToStarbucksModelArray(responseDictionary: responseDictionary) { (results) in
                            switch results {
                            case .success(_):
                                print("fetched new stores")
                                self.delegate?.fetchedNewStores(sender: self)
                                completion(results)
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
            dataManager.removeStoredData {
                completion(.success(results.map(){ (storeJSON) -> StarbucksStoreInformation in
                    let starbucksStore = StarbucksStoreInformation(starbucksJSON: storeJSON)
                    self.dataManager.saveStarbucksStoreInfo(starbucksStore: starbucksStore)
                    return starbucksStore
                }))
            }
        } else {
            completion(.failure(NetworkOperationError.errorJSON))
        }
    }
}
