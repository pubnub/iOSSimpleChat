//
//  PubNubExtensions.swift
//  Push
//
//  Created by Jordan Zucker on 1/12/17.
//  Copyright © 2017 PubNub. All rights reserved.
//

import Foundation
import PubNub

extension String {
    var isOnlyWhiteSpace: Bool {
        let whitespaceSet = CharacterSet.whitespaces
        return self.trimmingCharacters(in: whitespaceSet).isEmpty
    }
    var containsPubNubKeyWords: Bool {
        let keywordCharacterSet = CharacterSet(charactersIn: ",:.*/\\")
        if let _ = self.rangeOfCharacter(from: keywordCharacterSet, options: .caseInsensitive) {
            return true
        }
        else {
            return false
        }
    }
}

enum PubNubSubscribableStringParsingError: Error, CustomStringConvertible {
    case empty
    case channelNameContainsInvalidCharacters(channel: String)
    case channelNameTooLong(channel: String)
    case onlyWhitespace(channel: String)
    case unknown(channel: String)
    var description: String {
        switch self {
        case .empty:
            return "string has no length"
        case let .onlyWhitespace(channel):
            return channel + " is only whitespace"
        case let .channelNameContainsInvalidCharacters(channel):
            return channel + " contains keywords that cannot be used with PubNub"
        case let .channelNameTooLong(channel):
            return channel + " is too long (over 92 characters)"
        case let .unknown(channel):
            return channel + " is incorrect with unknown error"
        }
    }
}

//extension PubNubSubscribableStringParsingError: PromptError {
//    var prompt: String {
//        return description
//    }
//}
//
//extension PubNubSubscribableStringParsingError: AlertControllerError {
//    var alertTitle: String {
//        return "String parsing error"
//    }
//    
//    var alertMessage: String {
//        return description
//    }
//}

//extension UIAlertController {
//    
//    static func alertControllerForPubNubStringParsingIntoSubscribablesArrayError(_ source: String?, error: PubNubSubscribableStringParsingError, handler: ((UIAlertAction) -> Void)?) -> UIAlertController {
//        let blame = source ?? "string Parsing"
//        let title = "Issue with " + blame
//        let message = "Could not parse " + blame + " into array because \(error)"
//        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: handler))
//        return alertController
//    }
//}

extension PubNub {
    
    // TODO: Implement this, should eventually be a universal function in the PubNub framework
    static func stringToSubscribablesArray(channels: String?, commaDelimited: Bool = true) throws -> [String]? {
        guard let actualChannelsString = channels else {
            return nil
        }
        // if the whole string is empty, then return nil
        guard !actualChannelsString.characters.isEmpty else {
            return nil
        }
        var channelsArray: [String]
        if commaDelimited {
            channelsArray = actualChannelsString.components(separatedBy: ",")
        } else {
            channelsArray = [actualChannelsString]
        }
        for channel in channelsArray {
            guard !channel.isOnlyWhiteSpace else {
                throw PubNubSubscribableStringParsingError.onlyWhitespace(channel: channel)
            }
            guard channel.characters.count > 0 else {
                throw PubNubSubscribableStringParsingError.empty
            }
            guard channel.characters.count <= 92 else {
                throw PubNubSubscribableStringParsingError.channelNameTooLong(channel: channel)
            }
            guard !channel.containsPubNubKeyWords else {
                throw PubNubSubscribableStringParsingError.channelNameContainsInvalidCharacters(channel: channel)
            }
        }
        return channelsArray
    }
    
    func channelsString() -> String? {
        return PubNub.subscribablesToString(self.channels())
    }
    
    func channelGroupsString() -> String? {
        return PubNub.subscribablesToString(self.channelGroups())
    }
    
    internal static func subscribablesToString(_ subscribables: [String]) -> String? {
        if subscribables.isEmpty {
            return nil
        }
        return subscribables.reduce("", { (accumulator: String, component) in
            if accumulator.isEmpty {
                return component
            }
            return accumulator + "," + component
        })
    }
    var isSubscribingToChannels: Bool {
        return !self.channels().isEmpty
    }
    var isSubscribingToChannelGroups: Bool {
        return !self.channelGroups().isEmpty
    }
    var isSubscribing: Bool {
        return isSubscribingToChannels || isSubscribingToChannelGroups
    }
}
