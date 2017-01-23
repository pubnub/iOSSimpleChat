//
//  Result+CoreDataClass.swift
//  Push
//
//  Created by Jordan Zucker on 1/20/17.
//  Copyright © 2017 PubNub. All rights reserved.
//

import Foundation
import CoreData
import PubNub

@objc(Result)
public class Result: Event {
    
    @objc
    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
//    public convenience required init(object: NSObject, entity: NSEntityDescription, context: NSManagedObjectContext) {
//        guard let result = object as? PNResult else {
//            fatalError()
//        }
//        self.init(result: result, entity: entity, context: context)
//    }
    
    public required init(object: NSObject, entity: NSEntityDescription, context: NSManagedObjectContext) {
        guard let result = object as? PNResult else {
            fatalError()
        }
        super.init(entity: entity, insertInto: context)
        stringifiedOperation = result.stringifiedOperation()
        //        clientRequest = result.clientRequest?.url?.absoluteString
        isTLSEnabled = result.isTLSEnabled
        origin = result.origin
        statusCode = Int16(result.statusCode)
    }
    
//    public convenience init(result: PNResult, context: NSManagedObjectContext) {
//        let entity = type(of: self).entity()
//        self.init(result: result, entity: entity, context: context)
//    }
    
    public var textViewDisplayText: String {
        //return "Type: PNResult\nOperation: \(stringifiedOperation)\nStatus Code: \(statusCode)\nLocal Time: \(creationDate)"
        return "Operation: \(stringifiedOperation!)\nStatus Code: \(statusCode)\nLocal Time: \(creationDate!)"
    }

}
