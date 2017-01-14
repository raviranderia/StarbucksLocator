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

class MainViewModel: NSObject,GooglePlacesManagerDelegate, CLLocationManagerDelegate, ErrorViewControllerDelegate {
    
    var starbucksStoreInformation = [StarbucksStoreInformation]()
    let mapSegueIdentifer = "showStarbucksOnMap"
    let errorSegueIdentifier = "errorViewControllerSegue"
    let collectionViewCellIdentifier = "Cell"
    private var locationManager = LocationManager.shared
    var starbucksStore = [StarbucksStoreInformation]()
    
    weak var delegate: MainViewModelDelegate?
    
    private weak var dataManager = DataManager.shared
    private var googlePlacesManager = GooglePlacesManager.shared
    
    override init() {
        super.init()
        googlePlacesManager.delegate = self
        locationManager.locationManager.delegate = self
    }
    
    func fetchNearbyStarbucksStores(completion: @escaping (Result<[StarbucksStoreInformation]>) -> ())  {
        DispatchQueue.global().async {
            self.dataManager?.fetchStoreData() { (result) in
                DispatchQueue.main.async {
                    completion(result)
                }
            }
        }
    }
    
    func fetchFreshData() {
        googlePlacesManager.fetchNearbyStarbucksStores()
    }
    
    func fetchedNewStores(sender: Any?) {
        if let mainViewController = delegate as? MainViewController {
            if mainViewController.presentedViewController is ErrorViewController {
                reloadCollectionView {
                    mainViewController.dismissViewController()
                }
            }
        }
    }
    
    // MARK: CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse:
            reloadCollectionView {
                self.fetchFreshData()
            }
        case .denied:
            delegate?.performSegueWithIdentifier(identifier: errorSegueIdentifier, error: FeedError.LocationServicesDisabled)
        default:
            break
        }
    }
    
    // MARK: ErrorViewControllerDelegate
    func errorResolved(error: FeedError) {
        reloadCollectionView {
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
    }
    
    func reloadCollectionView(completion: @escaping () -> ()) {
        fetchNearbyStarbucksStores { (result) in
            switch result {
            case .success(let starbucksStoreInformation):
                self.starbucksStoreInformation = starbucksStoreInformation
                if starbucksStoreInformation.count > 0 {
                    self.delegate?.reloadCollectionViewData()
                } else {
                    guard let mainViewController = self.delegate as? MainViewController,
                    !(mainViewController.presentedViewController is ErrorViewController) else {
                        completion()
                        return
                    }
                    self.delegate?.performSegueWithIdentifier(identifier: self.errorSegueIdentifier, error: FeedError.InvalidData)
                }
            case .failure(let error):
                print(error)
            }
            completion()
        }
    }
}
