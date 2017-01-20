//
//  Channel+CoreDataProperties.swift
//  Push
//
//  Created by Jordan Zucker on 1/20/17.
//  Copyright © 2017 PubNub. All rights reserved.
//

import Foundation
import CoreData


extension Channel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Channel> {
        return NSFetchRequest<Channel>(entityName: "Channel");
    }

    @NSManaged public var isPushChannel: Bool
    @NSManaged public var isPushEnabled: Bool
    @NSManaged public var name: String?
    @NSManaged public var user: User?

}
