//
//  SaveOperation.swift
//  StarbucksLocator
//
//  Created by RAVI RANDERIA on 1/14/17.
//  Copyright © 2017 RAVI RANDERIA. All rights reserved.
//

import UIKit
import CoreData

final class SaveOperation: Operation {
    private let mainManagedObjectContext: NSManagedObjectContext
    private var privateManagedObjectContext: NSManagedObjectContext!
    private let image: UIImage
    private let id: String
    
    init(managedObjectContext: NSManagedObjectContext, image: UIImage, forId id: String) {
        mainManagedObjectContext = managedObjectContext
        self.image = image
        self.id = id
        super.init()
    }
    
    override func main() {
        privateManagedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        privateManagedObjectContext.parent = mainManagedObjectContext
        
        save(image: image, forId: id)
        
        if privateManagedObjectContext.hasChanges {
            privateManagedObjectContext.perform() {
                do {
                    try self.privateManagedObjectContext.save()
                    self.mainManagedObjectContext.performAndWait(){
                        do {
                            try  self.mainManagedObjectContext.save()
                            print("saved image mainNManagedObject")
                            if let masterManagedObjectContext = self.mainManagedObjectContext.parent {
                                masterManagedObjectContext.perform() {
                                    do {
                                        try masterManagedObjectContext.save()
                                        print("Saved image to master manage")
                                    } catch let err as NSError {
                                        print("Could not save master context: \(err.localizedDescription)")
                                    }
                                }
                            }
                        } catch let err as NSError {
                            print("Could not save main context: \(err.localizedDescription)")
                        }
                    }
                } catch {
                    print("Could not save \(error), \(error.localizedDescription)")
                }
            }
        }
    }

    private func save(image: UIImage,forId id: String) {
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
