//
//  Message+CoreDataClass.swift
//  Push
//
//  Created by Jordan Zucker on 1/26/17.
//  Copyright © 2017 PubNub. All rights reserved.
//

import Foundation
import CoreData
import PubNub

class ImageHandler: NSObject {
    
    static func resizedImage(_ image: UIImage, targetWidth: CGFloat) -> UIImage {
        
        let scale = targetWidth / image.size.width
        let targetHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: targetWidth, height: targetHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: targetWidth, height: targetHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    static func base64String(for image: UIImage, compressed: Bool = true) -> String? {
        let compressedImage = UIImageJPEGRepresentation(image, 0.25)
        return compressedImage?.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: UInt(0)))
    }
    
}

@objc(Message)
public class Message: Result {
    
    @objc
    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    public required init(object: NSObject, entity: NSEntityDescription, context: NSManagedObjectContext) {
        super.init(object: object, entity: entity, context: context)
        guard let messageResult = object as? PNMessageResult else {
            fatalError()
        }
        timetoken = messageResult.data.timetoken.int64Value
        channel = messageResult.data.channel
        subscription = messageResult.data.subscription
        publisher = messageResult.data.publisher
        guard let actualMessage = messageResult.data.message as? [String: Any] else {
            message = "There is not message"
            return
        }
        if let thumbnailDataString = actualMessage["image"] as? String {
            if let imageData = Data(base64Encoded: thumbnailDataString, options: []) {
                
                thumbnail = UIImage(data: imageData)
            }
        }
        if let messageText = actualMessage["text"] as? String {
            message = messageText
        } else {
            message = "There is no text!"
        }
        if let senderName = actualMessage["name"] as? String {
            publisherName = senderName
        }
    }
    
    public override var textViewDisplayText: String {
        let superText = super.textViewDisplayText
        return superText + "\nTimetoken: \(timetoken)\nChannel: \(channel)\nSubscription: \(subscription)\nPublisher: \(publisher)\nMessage: \(message)"
    }

}
