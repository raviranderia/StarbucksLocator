//
//  RequestManager.swift
//  StarbucksLocator
//
//  Created by RAVI RANDERIA on 1/12/17.
//  Copyright © 2017 RAVI RANDERIA. All rights reserved.
//

import Foundation
import CoreLocation

enum Result<T> {
    case success((T))
    case failure(Error)
}

enum NetworkOperationError: Error {
    case errorJSON
    case getRequestNotSuccessful
    case notValidHTTPResponse
}

struct RequestManager {
    
    static let shared = RequestManager()
    
    private init() { }
    
    func fetchNearbyStarbucksStores(location: CLLocation, radius: Int, completion: @escaping (Result<[String:Any]>) -> ()) {
        apiCall(method: .getNearbyStarbucks(location, radius)) { (result) in
            completion(result)
        }
    }
    
    func getImageFromURL(photoReference: String, maxWidth: Int, completion: @escaping (Result<[String:Any]>) -> ()) {
        apiCall(method: .getPhotoByReference(photoReference, maxWidth)) { (result) in
            completion(result)
        }
    }
    
    private func apiCall(method: Router, completion: @escaping (Result<[String: Any]>) -> ()) {
        let session = URLSession.shared
        print(method.asURLRequest())
        let dataTask = session.dataTask(with: method.asURLRequest()) { (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse {
                switch(httpResponse.statusCode) {
                case 200:
                    do {
                        let jsonDictionary = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                        completion(.success(jsonDictionary as! [String: Any]))
                    } catch {
                        completion(.failure(NetworkOperationError.errorJSON))
                    }
                default :
                    completion(.failure(NetworkOperationError.getRequestNotSuccessful))
                }
            } else {
                completion(.failure(NetworkOperationError.notValidHTTPResponse))
            }
        }
        dataTask.resume()
    }

}
