//
//  Network.swift
//  Push
//
//  Created by Jordan Zucker on 1/9/17.
//  Copyright © 2017 PubNub. All rights reserved.
//

import UIKit
import CoreData
import PubNub

fileprivate let DeviceTokenKey = "DeviceTokenKey"
fileprivate let publishKey = "pub-c-a9dc3f6b-98f7-4b44-97e6-4ea5a705ab2d"
fileprivate let subscribeKey = "sub-c-93f47f52-d6b4-11e6-9102-0619f8945a4f"

class Network: NSObject, PNObjectEventListener {
    
//    var pushChannels: [String] = [String]()
    
//    dynamic var deviceToken: Data? {
//        didSet {
//            UserDefaults.standard.set(deviceToken, forKey: DeviceTokenKey)
//            guard let actualDeviceToken = deviceToken else {
//                return
//            }
//            client.addPushNotificationsOnChannels(pushChannels, withDevicePushToken: actualDeviceToken) { (status) in
//                print("\(status.debugDescription)")
//                DataController.sharedController.persistentContainer.performBackgroundTask({ (context) in
//                    let _ = ResultType.createCoreDataObject(result: status, in: context)
//                    do {
//                        try context.save()
//                    } catch {
//                        fatalError(error.localizedDescription)
//                    }
//                })
//                
//            }
//        }
//    }
//    var deviceToken: Data?
    
//    let configuration: PNConfiguration = {
//        let config = PNConfiguration(publishKey: publishKey, subscribeKey: subscribeKey)
//        config.uuid = User.userID
//        return config
//    }()
    
    private var networkKVOContext = 0
    
    func config(with identifier: String) -> PNConfiguration {
        let config = PNConfiguration(publishKey: publishKey, subscribeKey: subscribeKey)
        config.uuid = identifier
        return config
    }
    
    var client: PubNub!
    
    private var user: User? {
        didSet {
            if let existingOldValue = oldValue {
                existingOldValue.removeObserver(self, forKeyPath: #keyPath(User.pushToken), context: &networkKVOContext)
//                existingOldValue.removeObserver(self, forKeyPath: #keyPath(User.pushChannels), context: &networkKVOContext)
            }
            user?.addObserver(self, forKeyPath: #keyPath(User.pushToken), options: [.new, .old, .initial], context: &networkKVOContext)
//            user?.addObserver(self, forKeyPath: #keyPath(User.pushChannels), options: [.new, .old, .initial], context: &networkKVOContext)
//            guard let currentUser = user else {
//                return
//            }
//            networkContext.perform {
//                self.networkContext.refresh(currentUser, mergeChanges: true)
//                let configuration = self.config(with: currentUser.identifier!)
//                self.client = PubNub.clientWithConfiguration(configuration)
//                self.client.addListener(self)
//            }
        }
    }
    
    deinit {
        user = nil
    }
    
    // MARK: - KVO
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &networkKVOContext {
            guard let existingKeyPath = keyPath else {
                return
            }
            switch existingKeyPath {
            case #keyPath(User.pushToken):
//                print("Network: Push Token KVO")
//                print("Network: object: \(object.debugDescription)")
//                print("Network: change: \(change)")
//                let _ = change![NSKeyValueChangeKey.newKey] as? Data
//                print("Network: KVO \(keyPath)")
                // now remove old and add new
                updatePushToken()
//                self.pushToken = object as? Data // check this!!!!!
            case #keyPath(User.pushChannels):
                print("======================================")
                print("Network: Push Channels KVO")
                print("Network: object: \(object.debugDescription)")
                print("Network: change: \(change)")
                print("Network: KVO \(keyPath)")
                guard let changeKindNumber = change?[NSKeyValueChangeKey.kindKey] as? NSNumber else {
                    fatalError("there should always be a change kind")
                }
                guard let changeKind = NSKeyValueChange(rawValue: changeKindNumber.uintValue) else {
                    fatalError("How did we not get a change kind?")
                }
                switch changeKind {
                case .setting, .insertion:
                    print("setting or insertion")
                    guard let newChannels = change?[NSKeyValueChangeKey.newKey] as? Set<Channel> else {
                        return // no changes
                    }
                    print("newChannels: \(newChannels)")
                    guard let oldChannels = change?[NSKeyValueChangeKey.oldKey] as? Set<Channel> else {
                        return
                    }
                    print("oldChannels: \(oldChannels)")
                    let channelsObjectArray = newChannels.map({ (channel) -> Channel in
                        return channel
                    })
                    if !channelsObjectArray.isEmpty {
                        addPush(channels: channelsObjectArray)
                    }
                case .removal:
                    print("removal")
                    guard let newChannels = change![NSKeyValueChangeKey.newKey] as? Set<Channel> else {
                        return // no changes
                    }
                    let channelsObjectArray = newChannels.map({ (channel) -> Channel in
                        return channel
                    })
                    removePush(channels: channelsObjectArray)
                case .replacement:
                    fatalError("We can't handle replacements for: \(object.debugDescription) with keyPath: \(keyPath)")
                    
                }
                
                // now updated added channels
            default:
                fatalError("what wrong in KVO?")
            }
            print("======================================")
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    let networkContext: NSManagedObjectContext
    
    var pushToken: Data? {
        didSet {
            print("set pushToken: \(pushToken)")
            // now remove old token and update new token
        }
    }
    
    static let sharedNetwork = Network()
    
    func setUp() {
        // Should this be nested? It seems fishy
        let viewContext = DataController.sharedController.persistentContainer.viewContext
        NotificationCenter.default.addObserver(self, selector: #selector(managedObjectContextObjectsDidChange(notification:)), name: .NSManagedObjectContextObjectsDidChange, object: viewContext)
        NotificationCenter.default.addObserver(self, selector: #selector(managedObjectContextObjectsDidSave(notification:)), name: .NSManagedObjectContextDidSave, object: viewContext)
        networkContext.perform {
//            guard let currentUser = self.networkContext.object(with: user.objectID) as? User else {
//                fatalError("How did we not find a user for \(user.debugDescription)")
//            }
//            self.user = currentUser
//            guard let currentUser = DataController.sharedController.fetchCurrentUser(in: self.networkContext) else {
//                fatalError("How did we not find a user for user: \(user.debugDescription)")
//            }
//            self.user = currentUser
            
            self.user = DataController.sharedController.fetchCurrentUser(in: self.networkContext)
//            let configuration = self.config(with: self.user!.identifier!)
//            self.client = PubNub.clientWithConfiguration(configuration)
//            self.client.addListener(self)
        }
    }
    
    func managedObjectContextObjectsDidSave(notification: Notification) {
        print("+++++++++++++++++++++++++++++++++")
        print(#function)
        guard let userInfo = notification.userInfo else {
            return
        }
        
        print("start updates")
        if let updates = userInfo[NSUpdatedObjectsKey] as? Set<NSManagedObject>, updates.count > 0 {
            for update in updates {
                print("update: \(update.debugDescription)")
                print("didSave changed values: \(update.changedValues())")
                print("didSave changed values for current event: \(update.changedValuesForCurrentEvent())")
                guard let user = update as? User else {
                    continue
                }
                let oldValues = user.changedValuesForCurrentEvent()
                let newValues = user.changedValues()
                guard let oldPushChannels = oldValues["pushChannels"] as? Set<Channel>, let newPushChannels = newValues["pushChannels"] as? Set<Channel> else {
                    continue
                }
                updatePush(oldChannels: oldPushChannels, newChannels: newPushChannels)
            }
        }
        print("end updates")
        
        print("start refreshes")
        if let refreshes = userInfo[NSRefreshedObjectsKey] as? Set<NSManagedObject>, refreshes.count > 0 {
            for refresh in refreshes {
                print("refresh: \(refresh.debugDescription)")
                print("didSave changed values: \(refresh.changedValues())")
                print("didSave changed values for current event: \(refresh.changedValuesForCurrentEvent())")
                guard let user = refresh as? User else {
                    continue
                }
                let oldValues = user.changedValuesForCurrentEvent()
                let newValues = user.changedValues()
                guard let oldPushChannels = oldValues["pushChannels"] as? Set<Channel>, let newPushChannels = newValues["pushChannels"] as? Set<Channel> else {
                    continue
                }
                updatePush(oldChannels: oldPushChannels, newChannels: newPushChannels)
            }
        }
        print("end refreshes")
        
        print("\(#function) userInfo: \(userInfo)")
        networkContext.mergeChanges(fromContextDidSave: notification)
        print("+++++++++++++++++++++++++++++++++")
    }
    
    func managedObjectContextObjectsDidChange(notification: Notification) {
        print("^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^")
        print(#function)
        guard let userInfo = notification.userInfo else {
            return
        }
        print("\(#function) userInfo: \(userInfo)")
        print("start updates")
        if let updates = userInfo[NSUpdatedObjectsKey] as? Set<NSManagedObject>, updates.count > 0 {
            for update in updates {
                print("update: \(update.debugDescription)")
                print("didSave changed values: \(update.changedValues())")
                print("didSave changed values for current event: \(update.changedValuesForCurrentEvent())")
                guard let user = update as? User else {
                    continue
                }
                let oldValues = user.changedValuesForCurrentEvent()
                let newValues = user.changedValues()
                guard let oldPushChannels = oldValues["pushChannels"] as? Set<Channel>, let newPushChannels = newValues["pushChannels"] as? Set<Channel> else {
                    continue
                }
                updatePush(oldChannels: oldPushChannels, newChannels: newPushChannels)
            }
        }
        print("end updates")
        
        print("start refreshes")
        if let refreshes = userInfo[NSRefreshedObjectsKey] as? Set<NSManagedObject>, refreshes.count > 0 {
            for refresh in refreshes {
                print("refresh: \(refresh.debugDescription)")
                print("didSave changed values: \(refresh.changedValues())")
                print("didSave changed values for current event: \(refresh.changedValuesForCurrentEvent())")
                guard let user = refresh as? User else {
                    continue
                }
                let oldValues = user.changedValuesForCurrentEvent()
                let newValues = user.changedValues()
                guard let oldPushChannels = oldValues["pushChannels"] as? Set<Channel>, let newPushChannels = newValues["pushChannels"] as? Set<Channel> else {
                    continue
                }
                updatePush(oldChannels: oldPushChannels, newChannels: newPushChannels)
            }
        }
        print("end refreshes")
        print("^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^")
//        networkContext.mergeChanges(fromContextDidSave: <#T##Notification#>)
    }
    
    
    override init() {
//        if let existingDeviceToken = UserDefaults.standard.object(forKey: DeviceTokenKey) {
//            guard let actualDeviceToken = existingDeviceToken as? Data else {
//                fatalError("What happened, we should have had: \(existingDeviceToken)")
//            }
//            self.deviceToken = actualDeviceToken
//        }
        let context = DataController.sharedController.persistentContainer.newBackgroundContext()
//        context.automaticallyMergesChangesFromParent = true
        self.networkContext = context
        super.init()
//        client = PubNub.clientWithConfiguration(configuration)
//        client.addListener(self)
//        // add a channel here
//        pushChannels.append("a")
    }
    
    // MARK: - APNS
    
//    func addPush(token: Data) {
//        networkContext.perform {
//            do {
////                let user = DataController.sharedController.currentUser(in: self.networkContext)
////                guard let pushChannels = user.pushChannelsArray else {
////                    return
////                }
////                self.client.removeAllPushNotificationsFromDeviceWithPushToken(<#T##pushToken: Data##Data#>, andCompletion: <#T##PNPushNotificationsStateModificationCompletionBlock?##PNPushNotificationsStateModificationCompletionBlock?##(PNAcknowledgmentStatus) -> Void#>)
//                try self.networkContext.save()
//            } catch {
//                fatalError(error.localizedDescription)
//            }
//        }
//    }
//    
//    func removePush(token: Data) {
//        networkContext.perform {
//            do {
////                let user = DataController.sharedController.currentUser(in: self.networkContext)
////                guard let pushChannels = user.pushChannelsArray else {
////                    return
////                }
////                self.client.removePushNotificationsFromChannels(pushChannels, withDevicePushToken: self., andCompletion: <#T##PNPushNotificationsStateModificationCompletionBlock?##PNPushNotificationsStateModificationCompletionBlock?##(PNAcknowledgmentStatus) -> Void#>)
//                try self.networkContext.save()
//            } catch {
//                fatalError(error.localizedDescription)
//            }
//        }
//    }
    
//    func updatePushToken() {
//        networkContext.perform {
//            do {
//                let user = DataController.sharedController.currentUser(in: self.networkContext)
//                guard let pushChannels = user.pushChannelsArray else {
//                    return
//                }
//                self.client.removePushNotificationsFromChannels(pushChannels, withDevicePushToken: self., andCompletion: <#T##PNPushNotificationsStateModificationCompletionBlock?##PNPushNotificationsStateModificationCompletionBlock?##(PNAcknowledgmentStatus) -> Void#>)
//                try self.networkContext.save()
//            } catch {
//                fatalError(error.localizedDescription)
//            }
//        }
//    }
    
    func updatePush(oldChannels: Set<Channel>, newChannels: Set<Channel>) {
        networkContext.perform {
            let currentPushChannels = self.user?.pushChannels
            let updatedArray: [Channel] = newChannels.map({ (channel) -> Channel in
                return self.networkContext.object(with: channel.objectID) as! Channel
            })
            let updatedSet: Set<Channel> = Set(updatedArray)
            
        }
        print("%%%%%%%%%%%%%%%% \(#function) with old: \(oldChannels) and new: \(newChannels)")
    }
    
    func addPush(channels: [Channel]) {
        print("add channels: \(channels.debugDescription)")
    }
    
    func removePush(channels: [Channel]) {
        print("remove channels: \(channels.debugDescription)")
    }
    
    func updatePushToken() {
        networkContext.perform {
            self.pushToken = self.user?.pushToken
        }
    }
    
    // MARK: - PNObjectEventListener
    
    func client(_ client: PubNub, didReceive status: PNStatus) {
        print("\(#function) status: \(status.debugDescription)")
    }
    
    func client(_ client: PubNub, didReceiveMessage message: PNMessageResult) {
        print("\(#function) message: \(message.debugDescription)")
    }
    
    func client(_ client: PubNub, didReceivePresenceEvent event: PNPresenceEventResult) {
        print("\(#function) event: \(event.debugDescription)")
    }

}
