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

class DataManager {
    var starbucksStores = [NSManagedObject]()
    
    static let shared = DataManager()
    private init() { }
    
    func saveStarbucksStoreInfo(starbucksStore: StarbucksStoreInformation) {
        removeStoredContent()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity =  NSEntityDescription.entity(forEntityName: "StarbucksStore",
                                                 in:managedContext)
        
        if alreadyExists(id: starbucksStore.id!) {
            print("already exists")
        } else {
            let store = NSManagedObject(entity: entity!, insertInto: managedContext)
            
            store.setValue(starbucksStore.id!, forKey: "id")
            store.setValue(starbucksStore.name!, forKey: "name")
            store.setValue(Double(starbucksStore.location!.coordinate.latitude), forKey: "latitude")
            store.setValue(Double(starbucksStore.location!.coordinate.longitude), forKey: "longitude")
            store.setValue(starbucksStore.formattedAddress!, forKey: "formattedAddress")
            
            do {
                try managedContext.save()
                starbucksStores.append(store)
            } catch let error as NSError  {
                print("Could not save \(error), \(error.userInfo)")
            }
        }
    }
    
    func alreadyExists(id: String) -> Bool {
        let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"StarbucksStore")
        
        let predicate = NSPredicate(format: "%K == %@", "id", id)
        fetchRequest.predicate = predicate
        var resultsDummy = [NSManagedObject]()
        do {
            let results =
                try managedObjectContext.fetch(fetchRequest)
            resultsDummy = results as! [NSManagedObject]
            return resultsDummy.count > 0
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        return false
    }
    
    func removeStoredContent() {
        let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"StarbucksStore")
        if let result = try? managedObjectContext.fetch(fetchRequest),
            let resultObject = result as? [NSManagedObject] {
            for object in resultObject {
                managedObjectContext.delete(object)
            }
        }
        
        do {
            try managedObjectContext.save()
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
}
