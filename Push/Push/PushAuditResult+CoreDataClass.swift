//
//  PushAuditResult+CoreDataClass.swift
//  Push
//
//  Created by Jordan Zucker on 1/20/17.
//  Copyright © 2017 PubNub. All rights reserved.
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData
import PubNub

@objc(PushAuditResult)
public class PushAuditResult: Result {
    
    @objc
    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    public required init(object: NSObject, entity: NSEntityDescription, context: NSManagedObjectContext) {
        super.init(object: object, entity: entity, context: context)
        guard let result = object as? PNAPNSEnabledChannelsResult else {
            fatalError()
        }
        channels = "\(result.data.channels)"
    }
    
    public override var textViewDisplayText: String {
        let superText = super.textViewDisplayText
        return superText + "\nChannels: \(channels!)"
    }

}
