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
