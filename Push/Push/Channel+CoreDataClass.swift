//
//  Channel+CoreDataClass.swift
//  
//
//  Created by Jordan Zucker on 1/11/17.
//
//

import Foundation
import CoreData


public class Channel: NSManagedObject {
    
    public convenience init(in context: NSManagedObjectContext, name: String, user: User? = nil) {
        self.init(context: context)
        context.performAndWait {
            self.name = name
            self.user = user
        }
    }

}
