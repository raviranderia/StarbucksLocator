//
//  ViewController.swift
//  StarbucksLocator
//
//  Created by RAVI RANDERIA on 1/12/17.
//  Copyright © 2017 RAVI RANDERIA. All rights reserved.
//

import UIKit
import CoreLocation

class MainViewController: UIViewController {

    let googlePlacesManager = GooglePlacesManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        googlePlacesManager.fetchNearbyStarbucksStores { (starbucksStoreList) in
            print(starbucksStoreList)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

