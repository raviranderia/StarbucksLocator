//
//  ViewController.swift
//  StarbucksLocator
//
//  Created by RAVI RANDERIA on 1/12/17.
//  Copyright © 2017 RAVI RANDERIA. All rights reserved.
//

import UIKit
import CoreLocation

class MainViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, MainViewModelDelegate, CLLocationManagerDelegate, ErrorViewControllerDelegate {
    
    @IBOutlet weak var starbucksCollectionView: UICollectionView!

    var mainViewModel = MainViewModel()
    var starbucksStoreInformation = [StarbucksStoreInformation]()
    let locationManager = LocationManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainViewModel.delegate = self
        locationManager.locationManager.delegate = self
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return starbucksStoreInformation.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: mainViewModel.collectionViewCellIdentifier, for: indexPath) as! StarbucksInformationCollectionViewCell
        let starbucksCollectionCellViewModel = StarbucksInformationCellViewModel(starbucksStoreInformation: starbucksStoreInformation[indexPath.row])
        cell.configureCell(starbucksInformationCellViewModel: starbucksCollectionCellViewModel)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: mainViewModel.mapSegueIdentifer, sender: starbucksStoreInformation[indexPath.row])
    }
    
    private func displayError(message: String) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        
        alertController.addAction(alertAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? MapViewController,
            let selectedStore = sender as? StarbucksStoreInformation{
            destinationVC.currentStarbucksStoreInfo = selectedStore
        } else if let destinationVC = segue.destination as? ErrorViewController,
            let feedError = sender as? FeedError {
            destinationVC.feedError = feedError
            destinationVC.delegate = self
        }
    }
    
    func firstLaunch() {
        reloadCollectionView {
            self.mainViewModel.fetchFreshData()
        }
    }
    
    func reloadCollectionView(completion: @escaping () -> ()) {
        mainViewModel.fetchNearbyStarbucksStores { (result) in
            switch result {
            case .success(let starbucksStoreInformation):
                self.starbucksStoreInformation = starbucksStoreInformation
                if starbucksStoreInformation.count > 0 {
                    self.starbucksCollectionView.reloadData()
                } else {
                    guard !(self.presentedViewController is ErrorViewController) else { return }
                    self.performSegue(withIdentifier: self.mainViewModel.errorSegueIdentifier, sender: FeedError.InvalidData)
                }
            case .failure(let error):
                self.displayError(message: error.localizedDescription)
            }
            completion()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse:
            firstLaunch()
        case .denied:
            self.performSegue(withIdentifier: mainViewModel.errorSegueIdentifier, sender: FeedError.LocationServicesDisabled)
        default:
            break
        }
    }
    
    func errorResolved(error: FeedError) {
        firstLaunch()
        switch error {
        case .InvalidData:
            if starbucksStoreInformation.count > 0 {
                dismiss(animated: true, completion: nil)
            }
        default:
            break
        }
    }
    
}

