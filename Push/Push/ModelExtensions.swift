//
//  ModelExtensions.swift
//  Push
//
//  Created by Jordan Zucker on 1/10/17.
//  Copyright © 2017 PubNub. All rights reserved.
//

import Foundation
import CoreData
import PubNub
import UserNotifications

protocol CoreDataObjectType {
    var managedObjectType: Event.Type { get }
    init?(event: NSObject?)
}

enum SystemEventType: CoreDataObjectType {
    case notification
    case pushNotification
    
    var managedObjectType: Event.Type {
        switch self {
        case .notification:
            fatalError()
        case .pushNotification:
            return PushMessage.self
        }
    }
    
    init?(event: NSObject?) {
        switch event {
        case let nilEvent where nilEvent == nil:
            return nil
        case _ as Notification:
            self = .notification
        case _ as UNNotification:
            self = .pushNotification
        default:
            fatalError()
        }
    }
    
}

enum PubNubEventType: CoreDataObjectType {
    case result
    case status
    case publishStatus
    case pushAuditResult
    case subscribeStatus
    case message
    
    var managedObjectType: Event.Type {
        switch self {
        case .result:
            return Result.self
        case .status:
            return Status.self
        case .publishStatus:
            return PublishStatus.self
        case .pushAuditResult:
            return PushAuditResult.self
        case .message:
            return Message.self
        case .subscribeStatus:
            return SubscribeStatus.self
        }
    }
    
    init?(event: NSObject?) {
        guard let actualEvent = event, actualEvent is PNResult else {
            return nil
        }
        switch event {
        case _ as PNSubscribeStatus:
            self = .subscribeStatus
        case _ as PNMessageResult:
            self = .message
        case _ as PNPublishStatus:
            self = .publishStatus
        case _ as PNStatus:
            self = .status
        case _ as PNAPNSEnabledChannelsResult:
            self = .pushAuditResult
        default:
            self = .result
        }
    }
    
}

enum EventType: CoreDataObjectType {

    case system(NSObject)
    case pubnub(NSObject)
    
    var managedObjectType: Event.Type {
        switch self {
        case let .system(object):
            return (SystemEventType(event: object)?.managedObjectType)!
        case let .pubnub(object):
            return (PubNubEventType(event: object)?.managedObjectType)!
        }
    }
    
    init?(event: NSObject?) {
        guard let actualEvent = event else {
            return nil
        }
        if let _ = PubNubEventType(event: actualEvent) {
            self = EventType.pubnub(actualEvent)
        } else {
            self = EventType.system(actualEvent)
        }
    }
    
}

class ImageToDataTransformer: ValueTransformer {
    
    class override func allowsReverseTransformation() -> Bool {
        return true
    }
    
    class override func transformedValueClass() -> Swift.AnyClass {
        return NSData.self
    }
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let image = value as? UIImage else {
            fatalError("can only handle UIImage, not: \(value.debugDescription)")
        }
        let data = UIImageJPEGRepresentation(image, 1.0)
        return data
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else {
            fatalError("can only handle Data, not: \(value.debugDescription)")
        }
        let image = UIImage(data: data)
        return image
    }
    
}
