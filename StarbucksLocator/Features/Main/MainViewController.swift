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

    let mainViewModel = MainViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainViewModel.fetchNearbyStarbucksStores { (result) in
            print(result)
        }
    }
}

