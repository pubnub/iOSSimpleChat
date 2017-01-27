//
//  Message+CoreDataProperties.swift
//  Push
//
//  Created by Jordan Zucker on 1/26/17.
//  Copyright © 2017 PubNub. All rights reserved.
//

import Foundation
import CoreData


extension Message {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Message> {
        return NSFetchRequest<Message>(entityName: "Message");
    }

    @NSManaged public var message: String?
    @NSManaged public var publisher: String?
    @NSManaged public var channel: String?
    @NSManaged public var subscription: String?
    @NSManaged public var timetoken: Int64

}
