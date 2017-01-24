//
//  Result+CoreDataProperties.swift
//  Push
//
//  Created by Jordan Zucker on 1/20/17.
//  Copyright © 2017 PubNub. All rights reserved.
//

import Foundation
import CoreData


extension Result {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Result> {
        return NSFetchRequest<Result>(entityName: "Result");
    }

    @NSManaged public var authKey: String?
    @NSManaged public var clientRequest: NSObject?
    @NSManaged public var isTLSEnabled: Bool
    @NSManaged public var origin: String?
    @NSManaged public var statusCode: Int16
    @NSManaged public var stringifiedOperation: String?
    @NSManaged public var uuid: String?

}
