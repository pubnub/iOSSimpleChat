//
//  Message+CoreDataClass.swift
//  Push
//
//  Created by Jordan Zucker on 1/26/17.
//  Copyright © 2017 PubNub. All rights reserved.
//

import Foundation
import CoreData
import PubNub

@objc(Message)
public class Message: Result {
    
    @objc
    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    public required init(object: NSObject, entity: NSEntityDescription, context: NSManagedObjectContext) {
        super.init(object: object, entity: entity, context: context)
        guard let messageResult = object as? PNMessageResult else {
            fatalError()
        }
        timetoken = messageResult.data.timetoken.int64Value
        channel = messageResult.data.channel
        subscription = messageResult.data.subscription
        publisher = messageResult.data.publisher
        guard let messageObject = messageResult.data.message as? AnyObject else {
            message = "Cannot convert message to string"
            return
        }
        message = messageObject.debugDescription
    }
    
    public override var textViewDisplayText: String {
        let superText = super.textViewDisplayText
        return superText + "\nTimetoken: \(timetoken)\nChannel: \(channel)\nSubscription: \(subscription)\nPublisher: \(publisher)\nMessage: \(message)"
    }

}
