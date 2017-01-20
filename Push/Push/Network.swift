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
    
    func requestPushChannelsForCurrentPushToken() {
        guard let currentToken = self.pushToken else {
            return
        }
        requestPushChannels(for: currentToken)
    }
    
    func requestPushChannels(for token: Data) {
        client.pushNotificationEnabledChannelsForDeviceWithPushToken(token) { (result, status) in
            self.networkContext.perform {
                var savingResponse: PNResult? = nil
                if let actualResult = result {
                    savingResponse = actualResult
                } else {
                    savingResponse = status
                }
                let _ = ResultType.createCoreDataObject(in: self.networkContext, for: savingResponse, with: self.user)
                do {
                    try self.networkContext.save()
                } catch {
                    fatalError(error.localizedDescription)
                }
            }
        }
    }
    
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
        }
        
        get {
            var finalToken: Data? = nil
            let getItem = DispatchWorkItem(qos: .utility, flags: []) {
                finalToken = self._pushToken
            }
            networkQueue.sync(execute: getItem)
            return finalToken
        }
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
    
    typealias tokens = (oldToken: Data?, newToken: Data?)
    typealias channels = (oldChannels: Set<String>?, newChannels: Set<String>?)
    
    func updatePush(tokens: tokens, current channels: Set<String>?) {
        guard let actualChannels = channelsArray(for: channels) else {
            return
        }
        
        let pushCompletionBlock: PNPushNotificationsStateModificationCompletionBlock = { (status) in
            self.networkContext.perform {
                let _ = ResultType.createCoreDataObject(in: self.networkContext, for: status, with: self.user)
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
                let _ = ResultType.createCoreDataObject(in: self.networkContext, for: status, with: self.user)
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
