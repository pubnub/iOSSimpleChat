//
//  SubscribeStatus+CoreDataProperties.swift
//  Push
//
//  Created by Jordan Zucker on 1/26/17.
//  Copyright © 2017 PubNub. All rights reserved.
//

import Foundation
import CoreData


extension SubscribeStatus {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SubscribeStatus> {
        return NSFetchRequest<SubscribeStatus>(entityName: "SubscribeStatus");
    }

    @NSManaged public var channel: String?
    @NSManaged public var subscription: String?
    @NSManaged public var timetoken: Int64
    @NSManaged public var currentTimetoken: Int64
    @NSManaged public var lastTimetoken: Int64
    @NSManaged public var subscribedChannels: String?
    @NSManaged public var subscribedChannelGroups: String?

}
