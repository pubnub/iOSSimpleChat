//
//  Channel+CoreDataClass.swift
//  Push
//
//  Created by Jordan Zucker on 1/20/17.
//  Copyright © 2017 PubNub. All rights reserved.
//

import Foundation
import CoreData

@objc(Channel)
public class Channel: NSManagedObject {
    
    public convenience init(in context: NSManagedObjectContext, name: String, user: User? = nil) {
        self.init(context: context)
        context.performAndWait {
            self.name = name
            self.user = user
        }
    }
    
    // if it returns nil, then there is no channel to update
    static func update(name: String, in context: NSManagedObjectContext) -> Channel? {
        var updatedChannel: Channel? = nil
        context.performAndWait {
            let channelFetchRequest: NSFetchRequest<Channel> = Channel.fetchRequest()
            do {
                let results = try channelFetchRequest.execute()
                if let firstResult = results.first {
                    updatedChannel = firstResult
                }
            } catch {
                fatalError(error.localizedDescription)
            }
        }
        return updatedChannel
    }
    
    static func channel(in context: NSManagedObjectContext, with name: String, shouldSave: Bool = true) -> Channel? {
        var updatedChannel: Channel? = nil
        context.performAndWait {
            let channelFetchRequest: NSFetchRequest<Channel> = Channel.fetchRequest()
            channelFetchRequest.predicate = NSPredicate(format: "name == %@", name)
            do {
                let results = try channelFetchRequest.execute()
                if let firstResult = results.first {
                    updatedChannel = firstResult
                } else {
                    updatedChannel = Channel(in: context, name: name)
                    if shouldSave {
                        try context.save()
                    }
                }
            } catch {
                fatalError(error.localizedDescription)
            }
        }
        return updatedChannel
    }

}
