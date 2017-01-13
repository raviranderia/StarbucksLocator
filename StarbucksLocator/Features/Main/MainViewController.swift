//
//  ViewController.swift
//  StarbucksLocator
//
//  Created by RAVI RANDERIA on 1/12/17.
//  Copyright © 2017 RAVI RANDERIA. All rights reserved.
//

import UIKit
import CoreLocation

class MainViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var starbucksCollectionView: UICollectionView!

    let mainViewModel = MainViewModel()
    var starbucksStoreInformation = [StarbucksStoreInformation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainViewModel.fetchNearbyStarbucksStores { [weak self] (result) in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let starbucksStoreInformation):
                strongSelf.starbucksStoreInformation = starbucksStoreInformation
                strongSelf.starbucksCollectionView.reloadData()
            case .failure(let error):
                strongSelf.displayError(message: error.localizedDescription)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return starbucksStoreInformation.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! StarbucksInformationCollectionViewCell
        let starbucksCollectionCellViewModel = StarbucksInformationCellViewModel(starbucksStoreInformation: starbucksStoreInformation[indexPath.row])
        cell.configureCell(starbucksInformationCellViewModel: starbucksCollectionCellViewModel)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(starbucksStoreInformation[indexPath.row])
    }
    
    private func displayError(message: String) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        
        alertController.addAction(alertAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
}

