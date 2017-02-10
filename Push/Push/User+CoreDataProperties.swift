//
//  User+CoreDataProperties.swift
//  Push
//
//  Created by Jordan Zucker on 1/20/17.
//  Copyright © 2017 PubNub. All rights reserved.
//

import UIKit
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User");
    }

    @NSManaged public var identifier: String?
    @NSManaged public var pushToken: Data?
    @NSManaged public var subscribeKey: String?
    @NSManaged public var publishKey: String?
    @NSManaged public var origin: String?
    @NSManaged public var authKey: String?
    @NSManaged public var isSubscribingToDebug: Bool
    @NSManaged public var pushChannels: Set<Channel>?
    @NSManaged public var events: Set<Event>?
    @NSManaged public var name: String?
    @NSManaged public var thumbnail: UIImage?
    @NSManaged public var lastColorUpdaterThumbnail: UIImage?
    @NSManaged public var lastColorUpdaterName: String?
    @NSManaged public var showDebug: Bool
    @NSManaged public var rawBackgroundColor: Int16
    @NSManaged public var colorUpdateTimetoken: Int64
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
