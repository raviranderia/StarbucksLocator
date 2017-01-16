//
//  MainViewModel.swift
//  StarbucksLocator
//
//  Created by RAVI RANDERIA on 1/13/17.
//  Copyright © 2017 RAVI RANDERIA. All rights reserved.
//

import Foundation
import CoreData
import CoreLocation

protocol MainViewModelDelegate: class {
    func reloadCollectionViewData()
    func performSegueWithIdentifier(identifier: String, error: FeedError?)
    func dismissViewController()
}

final class MainViewModel: NSObject,GooglePlacesManagerDelegate, CLLocationManagerDelegate, ErrorViewControllerDelegate, FetchOperationDelegate {
    
    var starbucksStoreInformation = [StarbucksStoreInformation]()
    let mapSegueIdentifer = "showStarbucksOnMap"
    let errorSegueIdentifier = "errorViewControllerSegue"
    let collectionViewCellIdentifier = "Cell"
    private let locationManager: LocationManagerProtocol
    private let dataManager: CoreDataManagerProtocol
    private let googlePlacesManager: GooglePlacesManagerProtocol
    
    weak var delegate: MainViewModelDelegate?
    
    init(googlePlacesManager: GooglePlacesManagerProtocol = GooglePlacesManager.shared,
         coreDataManager: CoreDataManagerProtocol = CoreDataManager.shared,
         locationManager: LocationManagerProtocol = LocationManager.shared) {
        self.googlePlacesManager = googlePlacesManager
        self.dataManager = coreDataManager
        self.locationManager = locationManager
        super.init()
        self.googlePlacesManager.delegate = self
        self.locationManager.locationManager.delegate = self
    }
    
    // fetch stored data from coreData
    func fetchStoredData(delegate: FetchOperationDelegate? = nil) {
        if let delegate = delegate {
            self.dataManager.fetchStoredData(delegate: delegate)
        } else {
            self.dataManager.fetchStoredData(delegate: self)
        }
        
    }
    
    //fetch fresh data from google places API
    func fetchFreshData(completion: ((Result<[StarbucksStoreInformation]>) -> ())?) {
        googlePlacesManager.fetchNearbyStarbucksStores { (results) in
            completion?(results)
        }
    }
    
    // MARK: GooglePlacesManagerDelegate
    func fetchedNewStores(sender: Any?) {
        reloadCollectionView()
        if let mainViewController = delegate as? MainViewController {
            if mainViewController.presentedViewController is ErrorViewController {
                DispatchQueue.main.async {
                    mainViewController.dismissViewController()
                }
            }
        }
    }
    
    // MARK: CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil {
            return
        }
        switch status {
        case .authorizedWhenInUse:
            reloadCollectionView()
            fetchFreshData(completion: nil)
        case .denied:
            delegate?.performSegueWithIdentifier(identifier: errorSegueIdentifier, error: FeedError.LocationServicesDisabled)
        default:
            break
        }
    }
    
    // MARK: ErrorViewControllerDelegate
    // fetch data from coreData and also send a network request
    func resolve(error: FeedError) {
        reloadCollectionView()
        self.fetchFreshData(completion: nil)
        switch error {
        case .InvalidData:
            if self.starbucksStoreInformation.count > 0 {
                self.delegate?.dismissViewController()
            }
        default:
            break
        }
    }
    
    // fetches stored data and dismisses errorViewController if it is the presentedViewController and if there is data to display
    func reloadCollectionView() {
        fetchStoredData()
    }
    
    // Fetch Operation Delegate - data from core data fetched
    func fetchCompleted(operation: FetchOperation, result: Result<[StarbucksStoreInformation]>) {
        DispatchQueue.main.async {
            switch result {
            case .success(let starbucksStoreInformation):
                self.starbucksStoreInformation = starbucksStoreInformation
                if starbucksStoreInformation.count > 0 {
                    self.delegate?.reloadCollectionViewData()
                } else {
                    guard let mainViewController = self.delegate as? MainViewController,
                        !(mainViewController.presentedViewController is ErrorViewController) else {
                            return
                    }
                    self.delegate?.performSegueWithIdentifier(identifier: self.errorSegueIdentifier, error: FeedError.InvalidData)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}
