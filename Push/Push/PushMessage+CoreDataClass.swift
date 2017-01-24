//
//  PushMessage+CoreDataClass.swift
//  Push
//
//  Created by Jordan Zucker on 1/20/17.
//  Copyright © 2017 PubNub. All rights reserved.
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData
import UserNotifications

@objc(PushMessage)
public class PushMessage: Event {
    
    @objc
    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    public required init(object: NSObject, entity: NSEntityDescription, context: NSManagedObjectContext) {
        super.init(entity: entity, insertInto: context)
        guard let notification = object as? UNNotification else {
            fatalError()
        }
        creationDate = notification.date as NSDate?
        trigger = Trigger.trigger(for: notification.request.trigger)
        let content = notification.request.content
        body = content.body
        categoryIdentifier = content.categoryIdentifier
        subtitle = content.subtitle
        title = content.title
        userInfo = content.userInfo.debugDescription
        badge = content.badge?.int16Value ?? Int16.max
    }
    
    public enum Trigger: Int16 {
        case none = 0, push, timeInterval, calendar, location
        
        var name: String {
            switch self {
            case .none:
                return "No trigger"
            case .push:
                return "Push"
            case .timeInterval:
                return "Time interval"
            case .calendar:
                return "Calendar"
            case .location:
                return "Location"
            }
        }
        
        static func trigger(for notificationTrigger: UNNotificationTrigger?) -> Trigger {
            guard let actualTrigger = notificationTrigger else { return .none }
            switch actualTrigger {
            case actualTrigger as UNLocationNotificationTrigger:
                return .location
            case actualTrigger as UNTimeIntervalNotificationTrigger:
                return .timeInterval
            case actualTrigger as UNCalendarNotificationTrigger:
                return .calendar
            case actualTrigger as UNPushNotificationTrigger:
                return .push
            default:
                fatalError("Can't handle other types of triggers: \(actualTrigger.debugDescription)")
            }
        }
    }
    
    var trigger: Trigger {
        set {
            self.rawTrigger = newValue.rawValue
        }
        get {
            return Trigger(rawValue: rawTrigger)! // forcibly unwrap so we can catch errors in debug
        }
    }
    
    public override var textViewDisplayText: String {
        //return "Type: PNResult\nOperation: \(stringifiedOperation)\nStatus Code: \(statusCode)\nLocal Time: \(creationDate)"
        return "Type: Push\nIdentifier: \(identifier)\nDate: \(creationDate)\nTrigger: \(trigger.name)\nTitle: \(title)\nSubtitle: \(subtitle)\nBody: \(body)"
    }

}
