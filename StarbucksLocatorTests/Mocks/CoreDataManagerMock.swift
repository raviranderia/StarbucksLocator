//
//  CoreDataManagerMock.swift
//  StarbucksLocator
//
//  Created by RAVI RANDERIA on 1/15/17.
//  Copyright © 2017 RAVI RANDERIA. All rights reserved.
//

import Foundation
import CoreData
import UIKit

@testable import StarbucksLocator

class CoreDataManagerMock: CoreDataManagerProtocol {
    
    var coreDataManager: CoreDataManagerProtocol!
    
    init() {
        let managedObjextContexts = setUpInMemoryManagedObjectContext()
        coreDataManager = CoreDataManager(masterManagedContext: managedObjextContexts.master, mainManagedContext: managedObjextContexts.main)
    }
    
    func saveStarbucksStoreInfo(starbucksStore: StarbucksStoreInformation) {
        coreDataManager.saveStarbucksStoreInfo(starbucksStore: starbucksStore)
    }
    
    func saveImageFromOperationQueue(image: UIImage, forId id: String) {
        coreDataManager.saveImageFromOperationQueue(image: image, forId: id)
    }
    
    func fetchStoredData(delegate: FetchOperationDelegate) {
        coreDataManager.fetchStoredData(delegate: delegate)
    }
    
    func removeStoredData(completion: @escaping () -> ()) {
        coreDataManager.removeStoredData {
            completion()
        }
    }
    
    private func setUpInMemoryManagedObjectContext() -> (master: NSManagedObjectContext, main: NSManagedObjectContext) {
        let managedObjectModel = NSManagedObjectModel.mergedModel(from: [Bundle.main])!
        
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        
        do {
            try persistentStoreCoordinator.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil, options: nil)
        } catch {
            print("Adding in-memory persistent store failed")
        }
        
        let masterManagedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        masterManagedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator
        
        let mainManagedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        mainManagedObjectContext.parent = masterManagedObjectContext
        
        return (masterManagedObjectContext,mainManagedObjectContext)
    }
}
