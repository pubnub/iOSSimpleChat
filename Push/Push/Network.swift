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

fileprivate let PrivateChatChannel = "chat"
fileprivate let PrivateColorChannel = "color"

@objc
class Network: NSObject, PNObjectEventListener {
    
    var chatChannel: String {
        return PrivateChatChannel
    }
    
    var colorChannel: String {
        return PrivateColorChannel
    }
    
    private var networkKVOContext = 0
    
    private let networkQueue = DispatchQueue(label: "Network", qos: .utility, attributes: [.concurrent])
    
//    func config(with identifier: String, pubKey: String, subKey: String) -> PNConfiguration {
//        let config = PNConfiguration(publishKey: pubKey, subscribeKey: subKey)
//        config.uuid = identifier
//        return config
//    }
    
    func updateClient(with configuration: PNConfiguration, completion: ((PubNub) -> Swift.Void)? = nil) {
        client.copyWithConfiguration(configuration, callbackQueue: networkQueue) { (updatedClient) in
            self.client = updatedClient
            DispatchQueue.main.async {
                completion?(updatedClient)
            }
        }
    }
    
    
    let subscribedChannels = [PrivateChatChannel, PrivateColorChannel]
    
    enum SubscriptionOperation {
        case subscribe
        case unsubscribe
    }
    
    func updateSubscription(with operation: SubscriptionOperation) {
        switch operation {
        case .subscribe:
            client.subscribeToChannels(subscribedChannels, withPresence: true)
        case .unsubscribe:
            client.unsubscribeFromAll()
        }
    }
    
    var client: PubNub {
        didSet {
            print("\(#function) client: \(client.debugDescription)")
            let configuredConfig = currentConfiguration
            networkContext.perform {
                self.user?.publishKey = configuredConfig.publishKey
                self.user?.subscribeKey = configuredConfig.subscribeKey
                self.user?.identifier = configuredConfig.uuid
                self.user?.authKey = configuredConfig.authKey
                self.user?.origin = configuredConfig.origin
                if self.networkContext.hasChanges {
                    User.updateUserID(identifier: self.user?.identifier)
                    do {
                        try self.networkContext.save()
                    } catch {
                        fatalError(error.localizedDescription)
                    }
                }
            }
        }
    }
    
    public var currentConfiguration: PNConfiguration {
        return client.currentConfiguration()
    }
    
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
                oldValue?.removeObserver(self, forKeyPath: #keyPath(User.isSubscribingToDebug), context: &self.networkKVOContext)
                settingUser?.addObserver(self, forKeyPath: #keyPath(User.pushToken), options: [.new, .old, .initial], context: &self.networkKVOContext)
                settingUser?.addObserver(self, forKeyPath: #keyPath(User.pushChannels), options: [.new, .old, .initial], context: &self.networkKVOContext)
                settingUser?.addObserver(self, forKeyPath: #keyPath(User.isSubscribingToDebug), options: [.new, .old, .initial], context: &self.networkKVOContext)
                guard let existingUser = settingUser else {
                    return
                }
                var config: PNConfiguration? = nil
                self.networkContext.performAndWait {
                    config = PNConfiguration(publishKey: existingUser.publishKey!, subscribeKey: existingUser.subscribeKey!)
                    config?.stripMobilePayload = false
                    config?.uuid = existingUser.identifier!
                    config?.authKey = existingUser.authKey
                    config?.origin = existingUser.origin!
                }
                self.client = PubNub.clientWithConfiguration(config!, callbackQueue: self.networkQueue)
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
            case #keyPath(User.isSubscribingToDebug):
                networkContext.perform {
                    let updatedIsSubscribingToDebugChannels = currentUser.isSubscribingToDebug
                    self.isSubscribingToDebugChannels = updatedIsSubscribingToDebugChannels
                }
            default:
                fatalError("what wrong in KVO?")
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    let networkContext: NSManagedObjectContext
    
    static let sharedNetwork = Network()
    
    
    
    override init() {
        let config = User.defaultConfiguration
        self.client = PubNub.clientWithConfiguration(config)
        let context = DataController.sharedController.newBackgroundContext()
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
                _ = DataController.sharedController.createCoreDataEvent(in: self.networkContext, for: result, with: self.user)
                _ = DataController.sharedController.createCoreDataEvent(in: self.networkContext, for: status, with: self.user)
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
                oldValue = self._pushToken
                self._pushToken = newValue
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
    
    var _isSubscribingToDebugChannels = false
    var isSubscribingToDebugChannels : Bool {
        set {
            let setItem = DispatchWorkItem(qos: .utility, flags: [.barrier]) {
                self._isSubscribingToDebugChannels = newValue
                if newValue {
                    self.updateDebugSubscription(for: self._pushChannels, with: .add)
                } else {
                    self.updateDebugSubscription(for: self._pushChannels, with: .remove)
                }
            }
            networkQueue.async(execute: setItem)
        }
        
        get {
            var finalIsSubscribingToDebugChannels = false
            let getItem = DispatchWorkItem(qos: .utility, flags: []) {
                finalIsSubscribingToDebugChannels = self._isSubscribingToDebugChannels
            }
            networkQueue.sync(execute: getItem)
            return finalIsSubscribingToDebugChannels
        }
    }
    
    var _pushChannels: Set<String>? = nil
    
    var pushChannels: Set<String>? {
        set {
            var oldValue: Set<String>? = nil
            let setItem = DispatchWorkItem(qos: .utility, flags: [.barrier]) {
                oldValue = self._pushChannels
                self._pushChannels = newValue
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
    
    enum SubscribeDebugOption {
        case add
        case remove
    }
    
    func publishChat(message: String?) {
        networkContext.perform {
            var payload = [String: String]()
            if let actualMessage = message {
                payload["text"] = actualMessage
            }
            if let actualThumbnail = self.user?.thumbnailString {
                payload["image"] = actualThumbnail
            }
            if let actualName = self.user?.name {
                payload["name"] = actualName
            }
            guard payload.count > 0 else {
                return
            }
            self.publish(payload: payload, toChannel: self.chatChannel)
        }
    }
    
    private func publish(payload: Any?, toChannel: String) {
        guard let actualPayload = payload else {
            return
        }
        client.publish(actualPayload, toChannel: toChannel, compressed: true) { (status) in
            self.networkContext.perform {
                _ = DataController.sharedController.createCoreDataEvent(in: self.networkContext, for: status, with: self.user)
                do {
                    try self.networkContext.save()
                } catch {
                    fatalError(error.localizedDescription)
                }
            }
        }
    }
    
    func updateDebugSubscription(for pushChannels: Set<String>?, with subscribeDebugOption: SubscribeDebugOption) {
        guard let actualPushChannelSet = pushChannels else {
            guard client.isSubscribing else {
                return
            }
            client.unsubscribeFromAll()
            return
        }
        let pushChannelsArray = actualPushChannelSet.map { (channel) -> String in
            return channel + "-pndebug"
        }
        if subscribeDebugOption == .add {
            client.subscribeToChannels(pushChannelsArray, withPresence: false)
        } else {
            guard client.isSubscribing else {
                return
            }
            client.unsubscribeFromChannels(pushChannelsArray, withPresence: false)
        }
    }
    
    func updatePush(tokens: tokens, current channels: Set<String>?) {
        guard let actualChannels = channelsArray(for: channels) else {
            return
        }
        
        let pushCompletionBlock: PNPushNotificationsStateModificationCompletionBlock = { (status) in
            self.networkContext.perform {
                _ = DataController.sharedController.createCoreDataEvent(in: self.networkContext, for: status, with: self._user)
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
            // If we no longer have a token at all, remove all push registrations for old token
            client.removeAllPushNotificationsFromDeviceWithPushToken(oldToken!, andCompletion: pushCompletionBlock)
        case let (oldToken, newToken):
            // Maybe skip this guard step?
            guard oldToken != newToken else {
                print("Token stayed the same, we don't need to adjust push registration")
                return
            }
            if let existingOldToken = oldToken, oldToken != newToken {
                // Only remove old token if it's different from the new token
                client.removePushNotificationsFromChannels(actualChannels, withDevicePushToken: existingOldToken, andCompletion: pushCompletionBlock)
            }
            if let existingNewToken = newToken {
                // add new token if it exists (not bad idea to register aggressively just in case this step got missed)
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
                _ = DataController.sharedController.createCoreDataEvent(in: self.networkContext, for: status, with: self._user)
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
            if self._isSubscribingToDebugChannels {
                updateDebugSubscription(for: oldChannels, with: .remove)
            }
        case let (nil, newChannels) where newChannels != nil:
            guard let existingNewChannels = channelsArray(for: newChannels) else {
                return
            }
            client.addPushNotificationsOnChannels(existingNewChannels, withDevicePushToken: actualToken, andCompletion: pushCompletionBlock)
            if self._isSubscribingToDebugChannels {
                updateDebugSubscription(for: newChannels, with: .add)
            }
        case let (oldChannels, newChannels):
            guard oldChannels != newChannels else {
                print("Don't need to do anything because the channels haven't changed")
                return
            }
            let addingChannels = newChannels!.subtracting(oldChannels!)
            let removingChannels = oldChannels!.subtracting(newChannels!)
            
            if let actualAddingChannels = channelsArray(for: addingChannels), !actualAddingChannels.isEmpty {
                client.addPushNotificationsOnChannels(actualAddingChannels, withDevicePushToken: actualToken, andCompletion: pushCompletionBlock)
                if self._isSubscribingToDebugChannels {
                    updateDebugSubscription(for: addingChannels, with: .add)
                }
            }
            if let actualRemovingChannels = channelsArray(for: removingChannels), !actualRemovingChannels.isEmpty {
                client.removePushNotificationsFromChannels(actualRemovingChannels, withDevicePushToken: actualToken, andCompletion: pushCompletionBlock)
                if self._isSubscribingToDebugChannels {
                    updateDebugSubscription(for: removingChannels, with: .remove)
                }
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
        self.networkContext.perform {
            _ = DataController.sharedController.createCoreDataEvent(in: self.networkContext, for: status, with: self.user)
            do {
                try self.networkContext.save()
            } catch {
                fatalError(error.localizedDescription)
            }
        }
    }
    
    func client(_ client: PubNub, didReceiveMessage message: PNMessageResult) {
        self.networkContext.perform {
            _ = DataController.sharedController.createCoreDataEvent(in: self.networkContext, for: message, with: self.user)
            do {
                try self.networkContext.save()
            } catch {
                fatalError(error.localizedDescription)
            }
        }
    }

}
