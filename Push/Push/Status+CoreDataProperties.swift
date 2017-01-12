//
//  Status+CoreDataProperties.swift
//  Push
//
//  Created by Jordan Zucker on 1/10/17.
//  Copyright © 2017 PubNub. All rights reserved.
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension Status {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Status> {
        return NSFetchRequest<Status>(entityName: "Status");
    }

    @NSManaged public var isError: Bool
    @NSManaged public var stringifiedCategory: String?

}
