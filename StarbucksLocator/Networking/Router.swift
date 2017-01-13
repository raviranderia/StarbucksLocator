//
//  Router.swift
//  StarbucksLocator
//
//  Created by RAVI RANDERIA on 1/12/17.
//  Copyright © 2017 RAVI RANDERIA. All rights reserved.
//

import Foundation
import CoreLocation

enum Router {
    
    static let baseURLString = "https://maps.googleapis.com/maps/api/place"
    static let privateKey = "AIzaSyA6MkeogfruwFTSHBl4zg8GzeFzNso_xL0"

    case getNearbyStarbucks(CLLocation,Int)
    case getPhotoByReference(String,Int)

    var path: String {
        switch self {
        case .getNearbyStarbucks(_, _):
            return "/textsearch/json?query=Starbucks"
        case .getPhotoByReference(_,let maxWidth):
            return "/photo?maxWidth=\(maxWidth)"
        }
    }
    
    // MARK: URLRequestConvertible
    func asURLRequest() -> URLRequest {
        let url = URL(string: Router.baseURLString + path)!
        var params: [String : String]
        switch self {
        case .getNearbyStarbucks(let location, let radius):
            params = ["location": "\(location.coordinate.latitude),\(location.coordinate.longitude)",
                      "radius": "\(radius)"]
            return addParametersToRequest(url: url, params: params)
        case .getPhotoByReference(let photoReference, _):
            params = ["photoreference": photoReference]
            return addParametersToRequest(url: url, params: params)
        }
    }
    
    func addParametersToRequest(url: URL, params: [String: String]) -> URLRequest {
        print(url)
        var parameters = ""
        for (key,value) in params {
            parameters += ("&\(key)=\(value)")
        }
        return URLRequest(url: URL(string: url.absoluteString + parameters + "&key=\(Router.privateKey)")!)
    }
    
}
