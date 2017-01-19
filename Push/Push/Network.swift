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

fileprivate let publishKey = "pub-c-a9dc3f6b-98f7-4b44-97e6-4ea5a705ab2d"
fileprivate let subscribeKey = "sub-c-93f47f52-d6b4-11e6-9102-0619f8945a4f"

class Network: NSObject, PNObjectEventListener {
    
    private var networkKVOContext = 0
    
    private let networkQueue = DispatchQueue(label: "Network", qos: .utility, attributes: [.concurrent])
    
    func config(with identifier: String) -> PNConfiguration {
        let config = PNConfiguration(publishKey: publishKey, subscribeKey: subscribeKey)
        config.uuid = identifier
        return config
    }
    
    var client: PubNub!
    
//    func setCurrentUser(user: User?) {
//        guard let actualUser = user else {
//            DispatchQueue.main.async {
//                self.user = nil
//            }
//            return
//        }
//        DispatchQueue.main.async {
//            guard let contextualUser = self.networkContext.object(with: actualUser.objectID) as? User else {
//                fatalError()
//            }
//            self.user = contextualUser
//        }
//    }
    
    private var _user: User?
    
    public var user: User? {
        set {
            var settingUser = newValue
            if let actualUser = settingUser, actualUser.managedObjectContext != networkContext {
                guard let contextualUser = networkContext.object(with: actualUser.objectID) as? User else {
                    fatalError()
                }
                settingUser = contextualUser
            }
            let setItem = DispatchWorkItem(qos: .utility, flags: [.barrier]) { 
                let oldValue: User? = self._user
                self._user = settingUser
                oldValue?.removeObserver(self, forKeyPath: #keyPath(User.pushToken), context: &self.networkKVOContext)
                oldValue?.removeObserver(self, forKeyPath: #keyPath(User.pushChannels), context: &self.networkKVOContext)
                settingUser?.addObserver(self, forKeyPath: #keyPath(User.pushToken), options: [.new, .old, .initial], context: &self.networkKVOContext)
                settingUser?.addObserver(self, forKeyPath: #keyPath(User.pushChannels), options: [.new, .old, .initial], context: &self.networkKVOContext)
                guard let existingUser = settingUser else {
                    return
                }
                var userID: String? = nil
                self.networkContext.performAndWait {
                    userID = existingUser.identifier!
                }
                guard let pubNubUUID = userID else {
                    fatalError("How did we not get an identifier from existingUser: \(existingUser)")
                }
                let configuration = self.config(with: pubNubUUID) // can forcibly unwrap, we
                self.client = PubNub.clientWithConfiguration(configuration, callbackQueue: self.networkQueue)
                self.client.addListener(self)
            }
            networkQueue.async(execute: setItem)
        }
        
        get {
            var finalUser: User? = nil
            let getItem = DispatchWorkItem(qos: .utility, flags: []) { 
                finalUser = self._user
            }
            networkQueue.sync(execute: getItem)
            return finalUser
            
        }
    }
    
//    private var user: User? {
//        didSet {
//            if let existingOldValue = oldValue {
//                existingOldValue.removeObserver(self, forKeyPath: #keyPath(User.pushToken), context: &networkKVOContext)
//                existingOldValue.removeObserver(self, forKeyPath: #keyPath(User.pushChannels), context: &networkKVOContext)
//            }
//            user?.addObserver(self, forKeyPath: #keyPath(User.pushToken), options: [.new, .old, .initial], context: &networkKVOContext)
//            user?.addObserver(self, forKeyPath: #keyPath(User.pushChannels), options: [.new, .old, .initial], context: &networkKVOContext)
//            guard let currentUser = user else {
//                return
//            }
//            networkContext.perform {
//                let identifier = currentUser.identifier!
//                DispatchQueue.main.async {
//                    let configuration = self.config(with: identifier)
//                    self.client = PubNub.clientWithConfiguration(configuration, callbackQueue: self.networkQueue)
//                    self.client.addListener(self)
//                }
//            }
//        }
//    }
    
    deinit {
        user = nil
    }
    
    // MARK: - KVO
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &networkKVOContext {
            guard let existingKeyPath = keyPath else {
                return
            }
            guard let currentUser = object as? User else {
                fatalError("How is it not a user: \(object.debugDescription)")
            }
            switch existingKeyPath {
            case #keyPath(User.pushToken):
                networkContext.perform {
                    let currentPushToken = currentUser.pushToken
                    self.pushToken = currentPushToken
                }
            case #keyPath(User.pushChannels):
                networkContext.perform {
                    let newChannels = currentUser.pushChannels?.map({ (channel) -> String in
                        return channel.name!
                    })
                    var finalResult: Set<String>? = nil
                    if let actualChannels = newChannels {
                        finalResult = Set(actualChannels)
                    }
                    self.pushChannels = finalResult
                }
            default:
                fatalError("what wrong in KVO?")
            }
            print("======================================")
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    let networkContext: NSManagedObjectContext
    
    static let sharedNetwork = Network()
    
    
    override init() {
        let context = DataController.sharedController.persistentContainer.newBackgroundContext()
        context.automaticallyMergesChangesFromParent = true
        self.networkContext = context
        super.init()
    }
    
    // MARK: - APNS
    
    var _pushToken: Data?
    
    var pushToken: Data? {
        set {
            var oldValue: Data? = nil
            let setItem = DispatchWorkItem(qos: .utility, flags: [.barrier]) {
                print("pushToken: setItem")
                oldValue = self._pushToken
                self._pushToken = newValue
                print("now update push token")
                self.updatePush(tokens: (oldValue, newValue), current: self._pushChannels)
            }
            networkQueue.async(execute: setItem)
//            let updatePushTokenItem = DispatchWorkItem(qos: .utility, flags: []) {
//                print("pushToken: updateItem")
////                self.updatePushToken(oldToken: oldValue, newToken: newValue)
//                self.updatePush(tokens: (oldValue, newValue), current: self._pushChannels)
//            }
//            networkQueue.async(execute: updatePushTokenItem)
        }
        
        get {
            var finalToken: Data? = nil
            let getItem = DispatchWorkItem(qos: .utility, flags: []) {
                finalToken = self._pushToken
            }
            networkQueue.sync(execute: getItem)
            return finalToken
        }
//        didSet {
//            print("set pushToken: \(pushToken)")
//            // now remove old token and update new token
//            updatePushToken(oldToken: oldValue, newToken: pushToken)
//        }
    }
    
    var _pushChannels: Set<String>? = nil
    
    var pushChannels: Set<String>? {
        set {
            var oldValue: Set<String>? = nil
            let setItem = DispatchWorkItem(qos: .utility, flags: [.barrier]) {
                oldValue = self._pushChannels
                self._pushChannels = newValue
                print("pushChannels: setItem with oldValue: \(oldValue) newValue: \(newValue)")
                print("now update push channels")
                self.updatePush(channels: (oldValue, newValue), current: self._pushToken)
            }
            networkQueue.async(execute: setItem)
//            let updatePushItem = DispatchWorkItem(qos: .utility, flags: []) {
//                print("pushChannels: updatePushItem")
//                
//            }
//            networkQueue.async(execute: updatePushItem)
        }
        
        get {
            var finalChannels: Set<String>? = nil
            let getItem = DispatchWorkItem(qos: .utility, flags: []) {
                finalChannels = self._pushChannels
            }
            networkQueue.sync(execute: getItem)
            return finalChannels
        }
    }
    
//    var pushChannels: Set<String>? = Set() {
//        didSet {
//            updatePush(oldChannels: oldValue, newChannels: pushChannels)
//        }
//    }
    
    typealias tokens = (oldToken: Data?, newToken: Data?)
    typealias channels = (oldChannels: Set<String>?, newChannels: Set<String>?)
    
    func updatePush(tokens: tokens, current channels: Set<String>?) {
        guard let actualChannels = channelsArray(for: channels) else {
            return
        }
        
        let pushCompletionBlock: PNPushNotificationsStateModificationCompletionBlock = { (status) in
            self.networkContext.perform {
                let _ = ResultType.createCoreDataObject(result: status, in: self.networkContext)
                do {
                    try self.networkContext.save()
                } catch {
                    fatalError(error.localizedDescription)
                }
            }
        }
        
        switch tokens {
        case (nil, nil):
            return
        case let (oldToken, nil) where oldToken != nil:
            client.removeAllPushNotificationsFromDeviceWithPushToken(oldToken!, andCompletion: pushCompletionBlock)
        case let (oldToken, newToken):
            guard oldToken != newToken else {
                return
            }
            if let existingOldToken = oldToken, oldToken != newToken {
                client.removePushNotificationsFromChannels(actualChannels, withDevicePushToken: existingOldToken, andCompletion: pushCompletionBlock)
            }
            if let existingNewToken = newToken {
                client.addPushNotificationsOnChannels(actualChannels, withDevicePushToken: existingNewToken, andCompletion: pushCompletionBlock)
            }
        }
    }
    
    func updatePush(channels: channels, current token: Data?) {
        guard let actualToken = token else {
            return
        }
        let pushCompletionBlock: PNPushNotificationsStateModificationCompletionBlock = { (status) in
            self.networkContext.perform {
                let _ = ResultType.createCoreDataObject(result: status, in: self.networkContext)
                do {
                    try self.networkContext.save()
                } catch {
                    fatalError(error.localizedDescription)
                }
            }
        }
        
        switch channels {
        case (nil, nil):
            return
        case let (oldChannels, nil) where oldChannels != nil:
            guard let existingOldChannels = channelsArray(for: oldChannels) else {
                return
            }
            client.removePushNotificationsFromChannels(existingOldChannels, withDevicePushToken: actualToken, andCompletion: pushCompletionBlock)
        case let (nil, newChannels) where newChannels != nil:
            guard let existingNewChannels = channelsArray(for: newChannels) else {
                return
            }
            client.addPushNotificationsOnChannels(existingNewChannels, withDevicePushToken: actualToken, andCompletion: pushCompletionBlock)
        case let (oldChannels, newChannels):
            guard oldChannels != newChannels else {
                print("Don't need to do anything because the channels haven't changed")
                return
            }
            let addingChannels = newChannels!.subtracting(oldChannels!)
            let removingChannels = oldChannels!.subtracting(newChannels!)
            
            if let actualAddingChannels = channelsArray(for: addingChannels), !actualAddingChannels.isEmpty {
                client.addPushNotificationsOnChannels(actualAddingChannels, withDevicePushToken: actualToken, andCompletion: pushCompletionBlock)
            }
            if let actualRemovingChannels = channelsArray(for: removingChannels), !actualRemovingChannels.isEmpty {
                client.removePushNotificationsFromChannels(actualRemovingChannels, withDevicePushToken: actualToken, andCompletion: pushCompletionBlock)
            }
        }
    }
    
//    func updatePush(tokens: tokens, channels: channels) {
//        
//        let pushCompletionBlock: PNPushNotificationsStateModificationCompletionBlock = { (status) in
//            self.networkContext.perform {
//                let _ = ResultType.createCoreDataObject(result: status, in: self.networkContext)
//                do {
//                    try self.networkContext.save()
//                } catch {
//                    fatalError(error.localizedDescription)
//                }
//            }
//        }
//        
//        var addingChannels: Set<String> = Set()
//        var removingChannels: Set<String> = Set()
//        
//        if let newChannels = channels.newChannels {
//            addingChannels.formUnion(newChannels)
//        }
//        if let oldChannels = channels.oldChannels {
//            addingChannels.subtract(oldChannels)
//            
//        }
//        
//        let addChannelsArray = channelsArray(for: addingChannels)
//        let removingChannelsArray = channelsArray(for: removingChannels)
//        
//        switch (tokens, channels) {
//        case ((nil, nil), (_, _)):
//            break
//        case let ((oldToken, nil), (_, _)) where oldToken != nil:
//            client.removeAllPushNotificationsFromDeviceWithPushToken(oldToken!, andCompletion: pushCompletionBlock)
//        // oldToken is already not nil for this case
//        case let ((oldToken, newToken), (_, _)) where newToken != nil:
//            if let existingOldToken = oldToken,  {
//                client.removePushNotificationsFromChannels(<#T##channels: [String]##[String]#>, withDevicePushToken: <#T##Data#>, andCompletion: <#T##PNPushNotificationsStateModificationCompletionBlock?##PNPushNotificationsStateModificationCompletionBlock?##(PNAcknowledgmentStatus) -> Void#>)
//            }
//        default:
//            fatalError("Can't handle this case")
//        }
//    }
//    
//    func updatePush(oldChannels: Set<String>?, newChannels: Set<String>?) {
//        print("%%%%%%%%%%%%%%%% \(#function) with old: \(oldChannels) and new: \(newChannels)")
//        // seems like this could result in tokens not being removed
//        guard let currentPushToken = pushToken else {
//            return
//        }
//        
//        let newPushArray = channelsArray(for: newChannels)
//        let oldPushArray = channelsArray(for: oldChannels)
//        
//        let pushCompletionBlock: PNPushNotificationsStateModificationCompletionBlock = { (status) in
//            self.networkContext.perform {
//                let _ = ResultType.createCoreDataObject(result: status, in: self.networkContext)
//                do {
//                    try self.networkContext.save()
//                } catch {
//                    fatalError(error.localizedDescription)
//                }
//            }
//        }
//        
//        switch (oldChannels, newChannels) {
//        case (nil, nil):
//            break
//        case let (oldChannels, nil) where oldChannels != nil:
//            client.removePushNotificationsFromChannels(oldPushArray!, withDevicePushToken: currentPushToken, andCompletion: pushCompletionBlock)
//        case let (nil, newChannels) where newChannels != nil:
//            client.addPushNotificationsOnChannels(newPushArray!, withDevicePushToken: currentPushToken, andCompletion: pushCompletionBlock)
//        case let (oldChannels, newChannels) where (oldChannels != nil) && (newChannels != nil):
//            if oldChannels != newChannels {
//                client.removePushNotificationsFromChannels(oldPushArray!, withDevicePushToken: currentPushToken, andCompletion: pushCompletionBlock)
//            }
//            client.addPushNotificationsOnChannels(newPushArray!, withDevicePushToken: currentPushToken, andCompletion: pushCompletionBlock)
//        default:
//            fatalError("unexpected case")
//        }
//    }
//    
//    func updatePushToken(oldToken: Data?, newToken: Data?) {
//        // seems like this could result in tokens not being removed
//        guard let currentChannelsArray = channelsArray(for: pushChannels) else {
//            return
//        }
//        
//        let pushCompletionBlock: PNPushNotificationsStateModificationCompletionBlock = { (status) in
//            self.networkContext.perform {
//                let _ = ResultType.createCoreDataObject(result: status, in: self.networkContext)
//                do {
//                    try self.networkContext.save()
//                } catch {
//                    fatalError(error.localizedDescription)
//                }
//            }
//        }
//        
//        switch (oldToken, newToken) {
//        case (nil, nil):
//            break
//        case let (oldToken, nil) where oldToken != nil:
//            print("whatever")
//            client.removeAllPushNotificationsFromDeviceWithPushToken(oldToken!, andCompletion: pushCompletionBlock)
//        case let (nil, newToken) where newToken != nil:
//            client.addPushNotificationsOnChannels(currentChannelsArray, withDevicePushToken: newToken!, andCompletion: pushCompletionBlock)
//            print("again")
//        case let (oldToken, newToken) where (oldToken != nil) && (newToken != nil):
//            print("hey hey")
//            if oldToken != newToken {
//                client.removeAllPushNotificationsFromDeviceWithPushToken(oldToken!, andCompletion: pushCompletionBlock)
//            }
//            client.addPushNotificationsOnChannels(currentChannelsArray, withDevicePushToken: newToken!, andCompletion: pushCompletionBlock)
//        default:
//            fatalError("unexpected case")
//        }
//    }
    
    func channelsArray(for set: Set<String>?) -> [String]? {
        guard let actualSet = set, !actualSet.isEmpty else {
            return nil
        }
        return actualSet.map { (channelName) -> String in
            return channelName
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
