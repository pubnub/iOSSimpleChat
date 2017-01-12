//
//  Channel+CoreDataProperties.swift
//  
//
//  Created by Jordan Zucker on 1/11/17.
//
//

import Foundation
import CoreData


extension Channel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Channel> {
        return NSFetchRequest<Channel>(entityName: "Channel");
    }

    @NSManaged public var name: String?
    @NSManaged public var user: User?

}
