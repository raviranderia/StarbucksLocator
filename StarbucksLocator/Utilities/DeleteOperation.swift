//
//  DeleteOperation.swift
//  StarbucksLocator
//
//  Created by RAVI RANDERIA on 1/14/17.
//  Copyright © 2017 RAVI RANDERIA. All rights reserved.
//

import UIKit
import CoreData

class DeleteOperation: Operation {
    let mainManagedObjectContext: NSManagedObjectContext
    var privateManagedObjectContext: NSManagedObjectContext!
    
    init(managedObjectContext: NSManagedObjectContext) {
        mainManagedObjectContext = managedObjectContext
        super.init()
    }
    
    override func main() {
        privateManagedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        privateManagedObjectContext.parent = mainManagedObjectContext
        
        removeStoredData()
        
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
    
    func removeStoredData() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"StarbucksStore")
        if let result = try? privateManagedObjectContext.fetch(fetchRequest),
            let resultObject = result as? [NSManagedObject] {
            for object in resultObject {
                privateManagedObjectContext.delete(object)
            }
        }
    }
}
