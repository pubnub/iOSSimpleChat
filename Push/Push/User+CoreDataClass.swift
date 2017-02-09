//
//  User+CoreDataClass.swift
//  Push
//
//  Created by Jordan Zucker on 1/20/17.
//  Copyright © 2017 PubNub. All rights reserved.
//

import Foundation
import CoreData
import PubNub

fileprivate let defaultPublishKey = "pub-c-d3e5298d-569b-456d-8098-441375674875"
fileprivate let defaultSubscribeKey = "sub-c-67dc596e-ee3b-11e6-81cc-0619f8945a4f"
fileprivate let UserIdentifierKey = "UserIdentifierKey"

@objc(User)
public class User: NSManagedObject {
    
    static var defaultConfiguration: PNConfiguration {
        let config = PNConfiguration(publishKey: defaultPublishKey, subscribeKey: defaultSubscribeKey)
        config.stripMobilePayload = false
        return config
    }
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        identifier = UUID().uuidString
        subscribeKey = defaultSubscribeKey
        publishKey = defaultPublishKey
        showDebug = false
        thumbnail = UIImage(named: "pubnub.png")
        backgroundColor = .white
        colorUpdateTimetoken = .min
    }
    
    // true if valid update, false if update is too old
    func update(color: Color?, with timetoken: Int64) -> Bool {
        guard let actualColor = color, timetoken > colorUpdateTimetoken else {
            return false
        }
        colorUpdateTimetoken = timetoken
        backgroundColor = actualColor
        return true
    }
    
//    let backgroundColorKeyPath = #keyPath(User.backgroundColor)
    var backgroundColor: Color {
        set {
//            willChangeValue(forKey: backgroundColorKeyPath)
            self.rawBackgroundColor = newValue.rawValue
//            didChangeValue(forKey: backgroundColorKeyPath)
        }
        get {
//            return Source(rawValue: rawCategory)! // forcibly unwrap so we can catch errors in debug
//            willAccessValue(forKey: backgroundColorKeyPath)
            let returningColor = Color(rawValue: rawBackgroundColor)! // forcibly unwrap so we can catch errors in debug
//            didAccessValue(forKey: backgroundColorKeyPath)
            return returningColor
        }
    }
    
    func removeAllResults(in context: NSManagedObjectContext? = nil) {
        var context = context
        if context == nil {
            context = DataController.sharedController.viewContext
        }
        context?.perform {
            let deleteUsers: (User) -> () = { (user) in
                user.events?.forEach({ (event) in
                    context?.delete(event)
                })
            }
            if context == self.managedObjectContext {
                deleteUsers(self)
            } else {
                guard let contextualUser = DataController.sharedController.fetchUser(with: self.objectID, in: context!) else {
                    fatalError()
                }
                deleteUsers(contextualUser)
            }
        }
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
    
    var thumbnailString: String? {
        guard let actualThumbnail = thumbnail else {
            return nil
        }
        let resizedImage = ImageHandler.resizedImage(actualThumbnail, targetWidth: 100.0)
        return ImageHandler.base64String(for: resizedImage, compressed: true)
    }
    
    static func updateUserID(identifier: String?) {
        guard let existingID = identifier else {
            return
        }
        UserDefaults.standard.set(existingID, forKey: UserIdentifierKey)
    }
    
    var pushChannelsArray: [Channel]? {
        return pushChannels?.map { $0 }
    }
    
    var pushTokenString: String? {
        guard let actualPushToken = pushToken else {
            return nil
        }
        let tokenString = actualPushToken.reduce("", {$0 + String(format: "%02X", $1)})
        return tokenString.lowercased()
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
