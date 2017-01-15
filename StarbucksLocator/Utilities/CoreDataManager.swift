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
    private let masterManagedContext: NSManagedObjectContext!
    var operationQueue = OperationQueue()
    
    static let shared = CoreDataManager()
    private init() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        masterManagedContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        masterManagedContext.persistentStoreCoordinator = appDelegate.persistentContainer.persistentStoreCoordinator
        mainManagedContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        mainManagedContext?.parent = masterManagedContext
//        mainManagedContext = appDelegate.persistentContainer.viewContext
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
