//
//  DataController.swift
//  Push
//
//  Created by Jordan Zucker on 1/9/17.
//  Copyright © 2017 PubNub. All rights reserved.
//

import UIKit
import CoreData
import PubNub

class DataController: NSObject {
    
    static let sharedController = DataController()
    
    var currentUserObjectID: NSManagedObjectID {
        return currentUser!.objectID
    }
    
    dynamic var currentUser: User? {
        didSet {
            print(#function)
            Network.sharedNetwork.user = currentUser
        }
    }
    
    public func fetchUser(for userIdentifier: String, in context: NSManagedObjectContext? = nil) -> User? {
        var context = context
        if context == nil {
            context = persistentContainer.viewContext
        }
        var finalUser: User? = nil
        context?.performAndWait {
            let userFetchRequest: NSFetchRequest<User> = User.fetchRequest()
            userFetchRequest.predicate = NSPredicate(format: "identifier == %@", userIdentifier)
            do {
                let results = try userFetchRequest.execute()
                finalUser = results.first
            } catch {
                fatalError(error.localizedDescription)
            }
        }
        return finalUser
    }
    
    func fetchUser(with objectID: NSManagedObjectID, in context: NSManagedObjectContext? = nil) -> User? {
        var context = context
        if context == nil {
            context = persistentContainer.viewContext
        }
        var finalUser: User? = nil
        // forcibly unwrap, we want to make sure we fail if there is no context
        context!.performAndWait {
            finalUser = context!.object(with: objectID) as? User
        }
        return finalUser
        
    }
    
    // view context by default if context is not supplied
    func fetchCurrentUser(in context: NSManagedObjectContext? = nil) -> User {
        return fetchUser(with: currentUserObjectID, in: context)! // forcibly unwrap for now
//        var context = context
//        if context == nil {
//            context = persistentContainer.viewContext
//        }
//        var finalUser: User? = nil
//        // forcibly unwrap, we want to make sure we fail if there is no context
//        context!.performAndWait {
//            guard let object = context?.object(with: self.currentUserObjectID) as? User else {
//                fatalError("What went wrong with context: \(context) and objectID: \(self.currentUserObjectID)")
//            }
//            finalUser = object
//        }
//        return finalUser!
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "Push")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}
