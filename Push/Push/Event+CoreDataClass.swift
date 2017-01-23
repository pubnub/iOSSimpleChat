//
//  Event+CoreDataClass.swift
//  Push
//
//  Created by Jordan Zucker on 1/20/17.
//  Copyright © 2017 PubNub. All rights reserved.
//

import Foundation
import CoreData


public class Event: NSManagedObject {
    
    @objc
    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    public required init(object: NSObject, entity: NSEntityDescription, context: NSManagedObjectContext) {
        super.init(entity: entity, insertInto: context)
    }
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        creationDate = NSDate()
    }

}
