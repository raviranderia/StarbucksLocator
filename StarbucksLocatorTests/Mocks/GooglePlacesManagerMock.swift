//
//  GooglePlacesManagerMock.swift
//  StarbucksLocator
//
//  Created by RAVI RANDERIA on 1/15/17.
//  Copyright © 2017 RAVI RANDERIA. All rights reserved.
//

import Foundation
@testable import StarbucksLocator

class GooglePlacesManagerMock: GooglePlacesManagerProtocol {
    
    var delegate: GooglePlacesManagerDelegate?
    var coreDataManagerMock: CoreDataManagerMock?
    var requestManager: RequestManagerProtocol
    
    required init(requestManager: RequestManagerProtocol) {
        self.requestManager = requestManager
    }
    
    func fetchNearbyStarbucksStores(completion: @escaping (Result<[StarbucksStoreInformation]>) -> ()) {
        
        getStarbucksStoresAndSaveToLocalCoreData(fileName: "starbucksGooglePlacesResponse") { results in
            self.delegate?.fetchedNewStores(sender: self)
            completion(results)
        }
    }
    
    func getStarbucksStoresAndSaveToLocalCoreData(fileName: String, completionHandler: @escaping (Result<[StarbucksStoreInformation]>) -> ()) {

        guard let filePath = Bundle.main.path(forResource: fileName, ofType:"json") else {
            completionHandler(.failure(NetworkOperationError.errorJSON))
            return
        }
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: filePath), options: .uncached)
            let jsonDictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            if let starbucksJSON = jsonDictionary as? [String: Any] {
                mapDictionaryToStarbucksModelArray(responseDictionary: starbucksJSON, completion: { (results) in
                    completionHandler(results)
                })
            }
        } catch let err {
            print(err)
            completionHandler(.failure(err))
        }
    }
    
    private func mapDictionaryToStarbucksModelArray(responseDictionary: [String: Any], completion: @escaping (Result<[StarbucksStoreInformation]>) -> ()) {
        if let results = responseDictionary["results"] as? [[String: Any]],
            results.count > 0 {
            if let dataManager = coreDataManagerMock {
                dataManager.removeStoredData {
                    completion(.success(results.map(){ (storeJSON) -> StarbucksStoreInformation in
                        let starbucksStore = StarbucksStoreInformation(starbucksJSON: storeJSON)
                        dataManager.saveStarbucksStoreInfo(starbucksStore: starbucksStore)
                        return starbucksStore
                    }))
                }
            }
        } else {
            completion(.failure(NetworkOperationError.errorJSON))
        }
    }
    
}
