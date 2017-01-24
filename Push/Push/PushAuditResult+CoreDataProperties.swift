//
//  PushAuditResult+CoreDataProperties.swift
//  Push
//
//  Created by Jordan Zucker on 1/20/17.
//  Copyright © 2017 PubNub. All rights reserved.
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension PushAuditResult {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PushAuditResult> {
        return NSFetchRequest<PushAuditResult>(entityName: "PushAuditResult");
    }

    @NSManaged public var channels: String?

}
