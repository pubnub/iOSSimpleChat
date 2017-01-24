//
//  PublishStatus+CoreDataProperties.swift
//  Push
//
//  Created by Jordan Zucker on 1/20/17.
//  Copyright © 2017 PubNub. All rights reserved.
//

import Foundation
import CoreData


extension PublishStatus {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PublishStatus> {
        return NSFetchRequest<PublishStatus>(entityName: "PublishStatus");
    }

    @NSManaged public var information: String?
    @NSManaged public var timetoken: Int64

}
