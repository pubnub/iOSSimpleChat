//
//  ConfigurationProperty.swift
//  Push
//
//  Created by Jordan Zucker on 1/25/17.
//  Copyright © 2017 PubNub. All rights reserved.
//

import Foundation
import PubNub

enum ConfigurationProperty: KeyValue, KeyValueAlertControllerUpdates {
    case origin(PNConfiguration)
    case publishKey(PNConfiguration)
    case subscribeKey(PNConfiguration)
    case authKey(PNConfiguration)
    case uuid(PNConfiguration)
    
    var key: String {
        switch self {
        case .origin(_):
            return #keyPath(PNConfiguration.origin)
        case .publishKey(_):
            return #keyPath(PNConfiguration.publishKey)
        case .subscribeKey(_):
            return #keyPath(PNConfiguration.subscribeKey)
        case .authKey(_):
            return #keyPath(PNConfiguration.authKey)
        case .uuid(_):
            return #keyPath(PNConfiguration.uuid)
        }
    }
    
    var displayKeyName: String {
        switch self {
        case .origin:
            return "Origin"
        case .publishKey:
            return "Publish Key"
        case .subscribeKey:
            return "Subscribe Key"
        case .authKey:
            return "Auth Key"
        case .uuid:
            return "UUID"
        }
    }
    
    var value: Any? {
        get {
            switch self {
            case let .publishKey(config), let .origin(config), let .subscribeKey(config), let .authKey(config), let .uuid(config):
                return config.value(forKey: key)
            }
        }
        set {
            switch self {
            case let .publishKey(config), let .origin(config), let .subscribeKey(config), let .authKey(config), let .uuid(config):
                config.setValue(newValue, forKey: key)
            }
        }
    }
    
    var displayValue: String? {
        switch self {
        case .subscribeKey(_), .publishKey(_), .origin(_), .authKey(_), .uuid(_):
            return value as! String? // we should never fail for these values
        }
    }
    
}
