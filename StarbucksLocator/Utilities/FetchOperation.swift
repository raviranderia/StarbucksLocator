//
//  FetchOperation.swift
//  StarbucksLocator
//
//  Created by RAVI RANDERIA on 1/14/17.
//  Copyright © 2017 RAVI RANDERIA. All rights reserved.
//

import UIKit
import CoreData

protocol FetchOperationDelegate: class {
    func fetchCompleted(operation: FetchOperation, result: Result<[StarbucksStoreInformation]>)
}


class FetchOperation: Operation {
    let mainManagedObjectContext: NSManagedObjectContext
    var privateManagedObjectContext: NSManagedObjectContext!
    weak var delegate: FetchOperationDelegate?
    
    init(managedObjectContext: NSManagedObjectContext, delegate: FetchOperationDelegate) {
        mainManagedObjectContext = managedObjectContext
        self.delegate = delegate
        super.init()
    }
    
    override func main() {
        privateManagedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        privateManagedObjectContext.parent = mainManagedObjectContext
        
        fetchStoredData()
    }
    
    func fetchStoredData() {
        print("fetching stored data")
        let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"StarbucksStore")
        var resultsDummy = [NSManagedObject]()
        do {
            let results =
                try managedObjectContext.fetch(fetchRequest)
            resultsDummy = results as! [NSManagedObject]
            delegate?.fetchCompleted(operation: self, result: .success(resultsDummy.map(){ (managedObject) -> StarbucksStoreInformation in
                return StarbucksStoreInformation(managedObject: managedObject)}))
        } catch let error as NSError {
            delegate?.fetchCompleted(operation: self, result: .failure(error))
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    
}
