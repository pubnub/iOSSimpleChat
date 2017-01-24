//
//  PushMessage+CoreDataProperties.swift
//  Push
//
//  Created by Jordan Zucker on 1/20/17.
//  Copyright © 2017 PubNub. All rights reserved.
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension PushMessage {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PushMessage> {
        return NSFetchRequest<PushMessage>(entityName: "PushMessage");
    }

    @NSManaged public var identifier: String?
    @NSManaged public var rawTrigger: Int16
    @NSManaged public var badge: Int16
    @NSManaged public var body: String?
    @NSManaged public var categoryIdentifier: String?
    @NSManaged public var subtitle: String?
    @NSManaged public var title: String?
    @NSManaged public var userInfo: String?
}
