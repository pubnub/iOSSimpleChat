//
//  User+CoreDataProperties.swift
//  Push
//
//  Created by Jordan Zucker on 1/20/17.
//  Copyright © 2017 PubNub. All rights reserved.
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User");
    }

    @NSManaged public var identifier: String?
    @NSManaged public var pushToken: Data?
    @NSManaged public var isSubscribingToDebug: Bool
//    @NSManaged public var pushChannels: NSSet?
//    @NSManaged public var results: NSSet?
    @NSManaged public var pushChannels: Set<Channel>?
    @NSManaged public var events: Set<Event>?

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

// MARK: Generated accessors for events
extension User {

    @objc(addEventsObject:)
    @NSManaged public func addToEvents(_ value: Event)

    @objc(removeEventsObject:)
    @NSManaged public func removeFromEvents(_ value: Event)

    @objc(addEvents:)
    @NSManaged public func addToEvents(_ values: NSSet)

    @objc(removeEvents:)
    @NSManaged public func removeFromEvents(_ values: NSSet)

}
