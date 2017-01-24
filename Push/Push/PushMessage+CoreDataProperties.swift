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

}
