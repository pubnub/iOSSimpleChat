//
//  PublishStatus+CoreDataProperties.swift
//  Push
//
//  Created by Jordan Zucker on 1/10/17.
//  Copyright © 2017 PubNub. All rights reserved.
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension PublishStatus {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PublishStatus> {
        return NSFetchRequest<PublishStatus>(entityName: "PublishStatus");
    }

    @NSManaged public var timetoken: Int64
    @NSManaged public var information: String?

}
