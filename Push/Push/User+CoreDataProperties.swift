//
//  User+CoreDataProperties.swift
//  
//
//  Created by Jordan Zucker on 1/11/17.
//
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User");
    }

    @NSManaged public var identifier: String?
    @NSManaged public var pushToken: Data?
//    @NSManaged public var pushChannels: NSSet?
//    @NSManaged public var results: NSSet?
    @NSManaged public var pushChannels: Set<Channel>?
    @NSManaged public var results: Set<Result>?

}

// MARK: Generated accessors for pushChannels
extension User {

    @objc(addPushChannelsObject:)
    @NSManaged public func addToPushChannels(_ value: Channel)

    @objc(removePushChannelsObject:)
    @NSManaged public func removeFromPushChannels(_ value: Channel)

    @objc(addPushChannels:)
    @NSManaged public func addToPushChannels(_ values: NSSet)

    @objc(removePushChannels:)
    @NSManaged public func removeFromPushChannels(_ values: NSSet)

}

// MARK: Generated accessors for results
extension User {

    @objc(addResultsObject:)
    @NSManaged public func addToResults(_ value: Result)

    @objc(removeResultsObject:)
    @NSManaged public func removeFromResults(_ value: Result)

    @objc(addResults:)
    @NSManaged public func addToResults(_ values: NSSet)

    @objc(removeResults:)
    @NSManaged public func removeFromResults(_ values: NSSet)

}
