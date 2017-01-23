//
//  PublishStatus+CoreDataClass.swift
//  Push
//
//  Created by Jordan Zucker on 1/20/17.
//  Copyright © 2017 PubNub. All rights reserved.
//

import Foundation
import CoreData
import PubNub

@objc(PublishStatus)
public class PublishStatus: Status {
    
    @objc
    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    public required init(object: NSObject, entity: NSEntityDescription, context: NSManagedObjectContext) {
        super.init(object: object, entity: entity, context: context)
        guard let publishStatus = object as? PNPublishStatus else {
            fatalError()
        }
        timetoken = publishStatus.data.timetoken.int64Value
        information = publishStatus.data.information
    }
    
    public override var textViewDisplayText: String {
        let superText = super.textViewDisplayText
        return superText + "\nTimetoken: \(timetoken)\nInformation: \(information)"
    }

}
