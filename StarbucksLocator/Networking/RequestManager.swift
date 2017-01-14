//
//  RequestManager.swift
//  StarbucksLocator
//
//  Created by RAVI RANDERIA on 1/12/17.
//  Copyright © 2017 RAVI RANDERIA. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

enum Result<T> {
    case success((T))
    case failure(Error)
}

enum NetworkOperationError: Error {
    case errorJSON
    case errorImage
    case getRequestNotSuccessful
    case notValidHTTPResponse
}

struct RequestManager {
    
    static let shared = RequestManager()
    private init() { }
    
    func fetchNearbyStarbucksStores(location: CLLocation, radius: Int, completion: @escaping (Result<[String:Any]>) -> ()) {
        let method = Router.getNearbyStarbucks(location, radius)
        let session = URLSession.shared
        let dataTask = session.dataTask(with: method.asURLRequest()) { (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse,
                let data = data {
                switch(httpResponse.statusCode) {
                case 200:
                    do {
                        let jsonDictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
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
    
    func getImageFromURL(photoReference: String, maxWidth: CGFloat, completion: @escaping (Result<UIImage>) -> ()) {
        let method = Router.getPhotoByReference(photoReference, maxWidth)
        let session = URLSession.shared
        let dataTask = session.dataTask(with: method.asURLRequest()) { (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse {
                switch(httpResponse.statusCode) {
                case 200:
                    if let data = data,
                        let image = UIImage(data: data) {
                        completion(.success(image))
                    } else {
                        completion(.failure(NetworkOperationError.errorImage))
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
