//
//  ViewController.swift
//  StarbucksLocator
//
//  Created by RAVI RANDERIA on 1/12/17.
//  Copyright © 2017 RAVI RANDERIA. All rights reserved.
//

import UIKit
import CoreLocation

final class MainViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, MainViewModelDelegate {
    
    @IBOutlet weak var starbucksCollectionView: UICollectionView!

    private var mainViewModel = MainViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainViewModel.delegate = self
    }
    
    // MARK: CollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mainViewModel.starbucksStoreInformation.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: mainViewModel.collectionViewCellIdentifier, for: indexPath) as! StarbucksInformationCollectionViewCell
        let starbucksCollectionCellViewModel = StarbucksInformationCellViewModel(starbucksStoreInformation: mainViewModel.starbucksStoreInformation[indexPath.row])
        cell.configureCell(starbucksInformationCellViewModel: starbucksCollectionCellViewModel)
        return cell
    }
    
    // MARK: CollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: mainViewModel.mapSegueIdentifer, sender: mainViewModel.starbucksStoreInformation[indexPath.row])
    }
    
    // MARK: MainViewModelDelegate
    func reloadCollectionViewData() {
        self.starbucksCollectionView.reloadData()
    }

    func performSegueWithIdentifier(identifier: String, error: FeedError?) {
        performSegue(withIdentifier: identifier, sender: error)
    }
    
    func dismissViewController() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? MapViewController,
            let selectedStore = sender as? StarbucksStoreInformation{
            destinationVC.currentStarbucksStoreInfo = selectedStore
        } else if let destinationVC = segue.destination as? ErrorViewController,
            let feedError = sender as? FeedError {
            destinationVC.feedError = feedError
            destinationVC.delegate = mainViewModel
        }
    }
    
    @IBAction func refreshButtonPressed(_ sender: UIBarButtonItem) {
        mainViewModel.fetchFreshData()
    }
    
}

