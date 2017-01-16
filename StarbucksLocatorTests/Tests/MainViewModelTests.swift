//
//  MainViewModelTests.swift
//  StarbucksLocator
//
//  Created by RAVI RANDERIA on 1/15/17.
//  Copyright © 2017 RAVI RANDERIA. All rights reserved.
//

import XCTest
@testable import StarbucksLocator

class MainViewModelTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    func testFetchFreshDataAndStore() {
        let populateStarbucksStoreInformationExpecation = expectation(description: "Starbucks data got from google api, saved to core data")
        let requestManager = RequestManager.shared
        let googlePlacesManager = GooglePlacesManagerMock(requestManager: requestManager)
        let dataManager = CoreDataManagerMock()
        var locationManager = LocationManagerMock()
        let mainViewModel = MainViewModel(googlePlacesManager: googlePlacesManager,
                                      coreDataManager: dataManager,
                                      locationManager: locationManager)
        googlePlacesManager.delegate = mainViewModel
        locationManager.locationManager.delegate = mainViewModel
        googlePlacesManager.coreDataManagerMock = dataManager
        
        mainViewModel.fetchFreshData { (results) in
            switch results {
            case .success(let starbucksStoreInfo):
                XCTAssertGreaterThan(starbucksStoreInfo.count, 0)
                populateStarbucksStoreInformationExpecation.fulfill()
            case .failure(_):
                XCTFail()
            }
        }
        
        waitForExpectations(timeout: 10) { (error) in
            if let error = error {
                print(error)
            }
        }
    }

}
