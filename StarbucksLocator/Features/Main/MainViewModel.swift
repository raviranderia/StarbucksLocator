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

class MainViewModel: NSObject,GooglePlacesManagerDelegate, CLLocationManagerDelegate, ErrorViewControllerDelegate, FetchOperationDelegate {
    
    var starbucksStoreInformation = [StarbucksStoreInformation]()
    let mapSegueIdentifer = "showStarbucksOnMap"
    let errorSegueIdentifier = "errorViewControllerSegue"
    let collectionViewCellIdentifier = "Cell"
    private var locationManager = LocationManager.shared
    
    weak var delegate: MainViewModelDelegate?
    
    private weak var dataManager = CoreDataManager.shared
    private var googlePlacesManager = GooglePlacesManager.shared
    
    override init() {
        super.init()
        googlePlacesManager.delegate = self
        locationManager.locationManager.delegate = self
    }
    
    // fetch stored data from coreData
    func fetchStoredData() {
        self.dataManager?.fetchStoredData(delegate: self)
    }
    
    //fetch fresh data from google places API
    func fetchFreshData() {
        googlePlacesManager.fetchNearbyStarbucksStores()
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
        switch status {
        case .authorizedWhenInUse:
            reloadCollectionView()
            fetchFreshData()
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
        self.fetchFreshData()
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
