//
//  SaveOperation.swift
//  StarbucksLocator
//
//  Created by RAVI RANDERIA on 1/14/17.
//  Copyright © 2017 RAVI RANDERIA. All rights reserved.
//

import UIKit
import CoreData

enum SaveOperationType {
    case saveStarbucksStoreInfo(StarbucksStoreInformation)
    case saveImage(image: UIImage, forId: String)
}

class SaveOperation: Operation {
    let mainManagedObjectContext: NSManagedObjectContext
    var privateManagedObjectContext: NSManagedObjectContext!
    let saveOperationType: SaveOperationType
    
    init(managedObjectContext: NSManagedObjectContext, saveOperationType: SaveOperationType) {
        mainManagedObjectContext = managedObjectContext
        self.saveOperationType = saveOperationType
        super.init()
    }
    
    override func main() {
        privateManagedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        privateManagedObjectContext.parent = mainManagedObjectContext
        if let entity =  NSEntityDescription.entity(forEntityName: "StarbucksStore", in: privateManagedObjectContext) {
            let managedObject = NSManagedObject(entity: entity, insertInto: privateManagedObjectContext)
            switch saveOperationType {
            case .saveStarbucksStoreInfo(let starbucksStoreInformation):
                saveStarbucksStoreInfo(managedObject: managedObject, starbucksStore: starbucksStoreInformation)
            case .saveImage(let image, let id):
                save(image: image, forId: id)
            }
            
            
            if privateManagedObjectContext.hasChanges {
                do {
                    try privateManagedObjectContext.save()
                    do {
                        try  mainManagedObjectContext.save()
                    } catch let err as NSError {
                        print("Could not save main context: \(err.localizedDescription)")
                    }
                } catch {
                    print("Could not save \(error), \(error.localizedDescription)")
                }
            }
        }
    }
    
    func saveStarbucksStoreInfo(managedObject: NSManagedObject, starbucksStore: StarbucksStoreInformation) {
        
        if alreadyExists(id: starbucksStore.id!) {
            print("already exists")
        } else {
            managedObject.setValue(starbucksStore.id!, forKey: "id")
            managedObject.setValue(starbucksStore.name!, forKey: "name")
            managedObject.setValue(Double(starbucksStore.location!.coordinate.latitude), forKey: "latitude")
            managedObject.setValue(Double(starbucksStore.location!.coordinate.longitude), forKey: "longitude")
            managedObject.setValue(starbucksStore.formattedAddress!, forKey: "formattedAddress")
            managedObject.setValue(starbucksStore.photoReference, forKey: "photoReference")
        }
    }
    
    private func alreadyExists(id: String) -> Bool {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"StarbucksStore")
        let predicate = NSPredicate(format: "%K == %@", "id", id)
        fetchRequest.predicate = predicate
        var resultsDummy = [NSManagedObject]()
        do {
            let results =
                try privateManagedObjectContext.fetch(fetchRequest)
            resultsDummy = results as! [NSManagedObject]
            return resultsDummy.count > 0
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        return false
    }
    
    func save(image: UIImage,forId id: String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"StarbucksStore")
        let predicate = NSPredicate(format: "%K == %@", "id", id)
        fetchRequest.predicate = predicate
        var resultsDummy = [NSManagedObject]()
        do {
            let results =
                try privateManagedObjectContext.fetch(fetchRequest)
            resultsDummy = results as! [NSManagedObject]
            
            resultsDummy[0].setValue(UIImageJPEGRepresentation(image, 1.0), forKey: "photo")
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
}
