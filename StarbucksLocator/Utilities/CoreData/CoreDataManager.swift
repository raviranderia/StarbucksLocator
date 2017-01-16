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

protocol CoreDataManagerProtocol {
    func saveStarbucksStoreInfo(starbucksStore: StarbucksStoreInformation)
    func removeStoredData(completion: @escaping () -> ())
    func saveImageFromOperationQueue(image: UIImage, forId id: String)
    func fetchStoredData(delegate: FetchOperationDelegate)
}

final class CoreDataManager: CoreDataManagerProtocol {
    
    private let mainManagedContext: NSManagedObjectContext?
    private let masterManagedContext: NSManagedObjectContext!
    private let operationQueue = OperationQueue()
    
    static let shared = CoreDataManager()
    
    // Reason for creating a hierarchichal core data stack 
    // https://medium.com/soundwave-stories/core-data-cffe22efe716#.cptcwx7v7
    init(masterManagedContext: NSManagedObjectContext? = nil, mainManagedContext: NSManagedObjectContext? = nil) {
        
        if let masterContext = masterManagedContext,
            let mainContext = mainManagedContext {
            self.mainManagedContext = mainContext
            self.masterManagedContext = masterContext
        } else {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            self.masterManagedContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
            self.masterManagedContext.persistentStoreCoordinator = appDelegate.persistentContainer.persistentStoreCoordinator
            self.mainManagedContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
            self.mainManagedContext?.parent = self.masterManagedContext
        }
    }
    
    func saveStarbucksStoreInfo(starbucksStore: StarbucksStoreInformation) {
        
        if alreadyExists(id: starbucksStore.id!) {
            print("already exists")
        } else {
            if let mainManagedContext = mainManagedContext,
                let entity =  NSEntityDescription.entity(forEntityName: "StarbucksStore", in:mainManagedContext) {
                
                let managedObject = NSManagedObject(entity: entity, insertInto: mainManagedContext)
                managedObject.setValue(starbucksStore.id!, forKey: "id")
                managedObject.setValue(starbucksStore.name!, forKey: "name")
                managedObject.setValue(Double(starbucksStore.location!.coordinate.latitude), forKey: "latitude")
                managedObject.setValue(Double(starbucksStore.location!.coordinate.longitude), forKey: "longitude")
                managedObject.setValue(starbucksStore.formattedAddress!, forKey: "formattedAddress")
                managedObject.setValue(starbucksStore.photoReference, forKey: "photoReference")
                
                if mainManagedContext.hasChanges {
                    do {
                        try mainManagedContext.save()
                        if let masterContext = mainManagedContext.parent {
                            masterContext.performAndWait {
                                do {
                                    try masterContext.save()
                                    print("saved master context")
                                } catch let err {
                                    print("error: \(err.localizedDescription)")
                                }
                            }
                        }
                    } catch let err {
                        print("Could not save main context: \(err.localizedDescription)")
                    }
                }
            }
        }
    }
    
    func removeStoredData(completion: @escaping () -> ()) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"StarbucksStore")
        if let result = try? mainManagedContext?.fetch(fetchRequest),
            let resultObject = result as? [NSManagedObject] {
            print(resultObject.count)
            for object in resultObject {
                mainManagedContext?.delete(object)
            }
            do {
                try self.mainManagedContext?.save()
                if let masterContext = mainManagedContext?.parent {
                    masterContext.performAndWait {
                        do {
                            try masterContext.save()
                            print("deleted master context")
                            completion()
                        } catch let err {
                            print("error: \(err.localizedDescription)")
                        }
                    }
                }
                print("deleted mainNManagedObject")
            } catch let err as NSError {
                print("Could not save main context: \(err.localizedDescription)")
            }
        }
    }
    
    private func alreadyExists(id: String) -> Bool {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"StarbucksStore")
        let predicate = NSPredicate(format: "%K == %@", "id", id)
        fetchRequest.predicate = predicate
        var resultsDummy = [NSManagedObject]()
        do {
            let results =
                try mainManagedContext?.fetch(fetchRequest)
            resultsDummy = results as! [NSManagedObject]
            return resultsDummy.count > 0
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        return false
    }
    
    func saveImageFromOperationQueue(image: UIImage, forId id: String) {
        let operation = SaveOperation(managedObjectContext: mainManagedContext!, image: image, forId: id)
        operationQueue.addOperation(operation)
    }

    func fetchStoredData(delegate: FetchOperationDelegate) {
        let operation = FetchOperation(managedObjectContext: mainManagedContext!, delegate: delegate)
        operationQueue.addOperation(operation)
    }
    
}
