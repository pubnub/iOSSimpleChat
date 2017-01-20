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

protocol CoreDataObject {
    var managedObjectType: NSManagedObject.Type { get }
}

enum SystemEvent: CoreDataObject {
    case notification
    case pushNotification
    
    var managedObjectType: NSManagedObject.Type {
        switch self {
        case .notification:
            return NSManagedObject.self
        default:
            return NSManagedObject.self
        }
    }
    
}

enum PubNubEvent: CoreDataObject {
    case result
    case status
    case publishStatus
    case pushAuditResult
    
    var managedObjectType: NSManagedObject.Type {
        switch self {
        case .result:
            return Result.self
        case .status:
            return Status.self
        case .publishStatus:
            return PublishStatus.self
        case .pushAuditResult:
            return NSManagedObject.self
        }
    }
    
    init?(result: PNResult?) {
        guard let actualResult = result else {
            return nil
        }
        switch actualResult {
        case _ as PNPublishStatus:
            self = PubNubEvent.publishStatus
        case _ as PNStatus:
            self = PubNubEvent.status
        case _ as PNAPNSEnabledChannelsResult:
            self = PubNubEvent.pushAuditResult
        default:
            self = PubNubEvent.result
        }
    }
    
}

enum EventType {
    case system(SystemEvent)
    case pubnub(PubNubEvent)
    
    
    
}

enum ResultType {
    case result
    case status
    case publishStatus
    
    var resultType: Result.Type {
        switch self {
        case .publishStatus:
            return PublishStatus.self
        case .status:
            return Status.self
        case .result:
            return Result.self
        }
    }
    
    init?(result: PNResult?) {
        guard let actualResult = result else {
            return nil
        }
        switch actualResult {
        case _ as PNPublishStatus:
            self = ResultType.publishStatus
        case _ as PNStatus:
            self = ResultType.status
        default:
            self = ResultType.result
        }
    }
    
    static func createCoreDataObject(in context: NSManagedObjectContext, for result: PNResult?, with user: User? = nil) -> Result? {
        guard let actualResult = result else {
            return nil
        }
        guard let resultType = ResultType(result: actualResult) else {
            return nil
        }
        let actualResultType = resultType.resultType
        let entity = actualResultType.entity()
        var finalResult: Result? = nil
        context.performAndWait {
            finalResult = actualResultType.init(result: actualResult, entity: entity, context: context)
            guard let actualUser = user else {
                return
            }
            if actualUser.managedObjectContext == context {
                finalResult?.user = actualUser
            } else {
                let contextualUser = DataController.sharedController.fetchUser(with: actualUser.objectID, in: context)
                finalResult?.user = contextualUser
            }
        }
        return finalResult
    }
    
}
