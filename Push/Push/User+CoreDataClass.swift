//
//  User+CoreDataClass.swift
//  
//
//  Created by Jordan Zucker on 1/11/17.
//
//

import UIKit
import CoreData
import PubNub

let UserIdentifierKey = "UserIdentifierKey"


public class User: NSManagedObject {
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        identifier = UUID().uuidString
    }
    
    static var userID: String {
        if let existingUserID = UserDefaults.standard.object(forKey: UserIdentifierKey) {
            return existingUserID as! String
        } else {
            let uuidString = UUID().uuidString
            UserDefaults.standard.set(uuidString, forKey: UserIdentifierKey)
            return uuidString
        }
    }
    
    var pushChannelsArray: [Channel]? {
        return pushChannels?.map { $0 }
    }
    
    var pushChannelsString: String? {
        guard let actualChannels = pushChannels, !actualChannels.isEmpty else {
            return nil
        }
        return actualChannels.reduce("", { (result, channel) -> String in
            if result.isEmpty {
                return channel.name!
            }
            return result + "," + channel.name!
        })
    }
    
    func alertControllerForPushChannels(in context: NSManagedObjectContext) -> UIAlertController {
        let alertController = UIAlertController(title: "Update push channels", message: "Enter or edit the push channels for this client", preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.placeholder = "Channels ..."
            context.perform {
                let currentUser = DataController.sharedController.fetchCurrentUser(in: context)
                guard let channelsString = currentUser.pushChannelsString else {
                    return
                }
                DispatchQueue.main.async {
                    textField.text = channelsString
                }
            }
        }
        
        let textField = alertController.textFields![0] // we just added only a single textField
        
        let pushChannelsKeyPath = #keyPath(User.pushChannels)
        
        let updateAction = UIAlertAction(title: "Update", style: .default) { (action) in
            defer {
                context.perform {
                    do {
                        print("Save push channels change!")
                        try context.save()
                    } catch {
                        fatalError(error.localizedDescription)
                    }
                }
            }
            context.perform {
                let currentUser = DataController.sharedController.fetchCurrentUser(in: context)
                guard let entryText = textField.text, !entryText.isEmpty else {
                    context.perform {
                        currentUser.mutableSetValue(forKeyPath: pushChannelsKeyPath).removeAllObjects()
                    }
                    return
                }
                var channelsArray: [String]? = nil
                do {
                    if let inputArray = try PubNub.stringToSubscribablesArray(channels: entryText) {
                        channelsArray = inputArray
                    }
                } catch {
                    fatalError(error.localizedDescription)
                }
                // check this forced unwrap
                let channelsObjectArray = channelsArray!.map({ (channelName) -> Channel in
                    let foundChannel = Channel.channel(in: context, with: channelName, shouldSave: false)
                    return foundChannel!
                })
                let channelsSet: Set<Channel> = Set(channelsObjectArray) // we can forcibly unwrap because we checked for channels above
                if !channelsSet.isEmpty {
                    print("user: \(currentUser.debugDescription)")
                    let pushChannelsKeyPath = #keyPath(User.pushChannels)
                    currentUser.mutableSetValue(forKeyPath: pushChannelsKeyPath).union(channelsSet)
                    currentUser.mutableSetValue(forKeyPath: pushChannelsKeyPath).intersect(channelsSet)
                }
            }
            
        }
        alertController.addAction(updateAction)
        
        let clearAction = UIAlertAction(title: "Clear", style: .destructive) { (action) in
            defer {
                context.perform {
                    do {
                        print("Save push channels change!")
                        try context.save()
                    } catch {
                        fatalError(error.localizedDescription)
                    }
                }
            }
            context.perform {
                let currentUser = DataController.sharedController.fetchCurrentUser(in: context)
                currentUser.mutableSetValue(forKeyPath: pushChannelsKeyPath).removeAllObjects()
            }
        }
        alertController.addAction(clearAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            
        }
        alertController.addAction(cancelAction)
        
        return alertController
    }

}
