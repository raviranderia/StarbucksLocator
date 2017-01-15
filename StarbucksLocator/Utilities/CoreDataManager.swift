//
//  DataManager.swift
//  StarbucksLocator
//
//  Created by RAVI RANDERIA on 1/13/17.
//  Copyright © 2017 RAVI RANDERIA. All rights reserved.
//

import Foundation

import UIKit
import CoreData

class CoreDataManager {
    
    private let mainManagedContext: NSManagedObjectContext?
    var operationQueue = OperationQueue()
    
    static let shared = CoreDataManager()
    private init() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        mainManagedContext = appDelegate.persistentContainer.viewContext
        operationQueue.maxConcurrentOperationCount = 1
    }
    
    func saveImageFromOperationQueue(image: UIImage, forId id: String) {
        let operation = SaveOperation(managedObjectContext: mainManagedContext!, saveOperationType: .saveImage(image: image, forId: id))
        operationQueue.addOperation(operation)
    }
    
    func saveStarbucksStoreInfo(starbucksStore: StarbucksStoreInformation) {
        let operation = SaveOperation(managedObjectContext: mainManagedContext!, saveOperationType: .saveStarbucksStoreInfo(starbucksStore))
        operationQueue.addOperation(operation)
    }
    
    func removeStoredData() {
        let operation = DeleteOperation(managedObjectContext: mainManagedContext!)
        operationQueue.addOperation(operation)
    }

    func fetchStoredData(delegate: FetchOperationDelegate) {
        let operation = FetchOperation(managedObjectContext: mainManagedContext!, delegate: delegate)
        operationQueue.addOperation(operation)
    }
    
}
