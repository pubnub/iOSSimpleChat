//
//  Status+CoreDataClass.swift
//  Push
//
//  Created by Jordan Zucker on 1/10/17.
//  Copyright © 2017 PubNub. All rights reserved.
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData
import PubNub

@objc(Status)
public class Status: Result {
    
    @objc
    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    public required init(result: PNResult, entity: NSEntityDescription, context: NSManagedObjectContext) {
        super.init(result: result, entity: entity, context: context)
        guard let status = result as? PNStatus else {
            fatalError()
        }
        isError = status.isError
        stringifiedCategory = status.stringifiedCategory()
    }
    
    public override var textViewDisplayText: String {
        let superText = super.textViewDisplayText
        return superText + "\nCategory: \(stringifiedCategory!)\nisError: \(isError)"
    }

}
