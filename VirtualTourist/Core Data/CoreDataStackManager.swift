//
//  CoreDataStackManager.swift
//  VirtualTourist
//
//  Created by Noureddine Marigh on 12/05/17.
//  Copyright © 2017 NM. All rights reserved.
//

import Foundation
import CoreData

private let SQLITE_FILE_NAME = "model.sqlite"

class CoreDataStackManager {
    
class func sharedInstance() -> CoreDataStackManager {
        struct Static {
            static let instance = CoreDataStackManager()
        }
            return Static.instance
}
        lazy var applicationDocumentsDirectoryName: URL = {
        
            let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            return urls[urls.count-1]
            }()
    
        lazy var managedObjectModel: NSManagedObjectModel = {
            let modelURL = Bundle.main.url(forResource: "Model", withExtension: "momd")!
            return NSManagedObjectModel(contentsOf: modelURL)!
            }()
    
        lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
            let coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
            let url = self.applicationDocumentsDirectoryName.appendingPathComponent(SQLITE_FILE_NAME)
            debugPrint(url)
            print("sqlite path: \(url.path)")
        
            var dataError = "Unable to load stored data."
            do {
            try coordinator!.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
            }
            catch {
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Unable to initialize saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = dataError as AnyObject?
            dict[NSUnderlyingErrorKey] = error as NSError
            let domainError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            NSLog("error \(domainError), \(domainError.userInfo)")
            abort()
        }
            return coordinator
            }()
    
            lazy var managedObjectContext: NSManagedObjectContext = {
            let coordinator = self.persistentStoreCoordinator
            var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
            managedObjectContext.persistentStoreCoordinator = coordinator
            return managedObjectContext
            }()
    
    func saveObjectContext() {
        if managedObjectContext.hasChanges {
            do {
            try managedObjectContext.save()
            }
            catch {
            let nserror = error as NSError
            NSLog("error \(nserror), \(nserror.userInfo)")
            abort()
            }
        }
    }
}



