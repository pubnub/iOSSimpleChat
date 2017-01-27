//
//  SubscribeStatus+CoreDataClass.swift
//  Push
//
//  Created by Jordan Zucker on 1/26/17.
//  Copyright © 2017 PubNub. All rights reserved.
//

import Foundation
import CoreData
import PubNub

@objc(SubscribeStatus)
public class SubscribeStatus: Status {
    
    @objc
    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    public required init(object: NSObject, entity: NSEntityDescription, context: NSManagedObjectContext) {
        super.init(object: object, entity: entity, context: context)
        guard let subscribeStatus = object as? PNSubscribeStatus else {
            fatalError()
        }
        timetoken = subscribeStatus.data.timetoken.int64Value
        channel = subscribeStatus.data.channel
        subscription = subscribeStatus.data.subscription
        currentTimetoken = subscribeStatus.currentTimetoken.int64Value
        lastTimetoken = subscribeStatus.lastTimeToken.int64Value
        subscribedChannels = PubNub.subscribablesToString(subscribeStatus.subscribedChannels)
        subscribedChannelGroups = PubNub.subscribablesToString(subscribeStatus.subscribedChannelGroups)
    }
    
    public override var textViewDisplayText: String {
        let superText = super.textViewDisplayText
        return superText + "\nTimetoken: \(timetoken)\nChannels: \(subscribedChannels)\nChannel groups: \(subscribedChannelGroups)"
    }

}
