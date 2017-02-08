//
//  UserExtensions.swift
//  Push
//
//  Created by Jordan Zucker on 2/7/17.
//  Copyright © 2017 PubNub. All rights reserved.
//

import UIKit
import CoreData

@objc(Color)
public enum Color: Int16 {
    case red = 0
    case blue
    case green
    case purple
    
    var uiColor: UIColor {
        switch self {
        case .red:
            return UIColor.red
        case .blue:
            return UIColor.blue
        case .green:
            return UIColor.green
        case .purple:
            return UIColor.purple
        }
    }
    
    var title: String {
        switch self {
        case .red:
            return "Red"
        case .blue:
            return "Blue"
        case .green:
            return "Green"
        case .purple:
            return "Purple"
        }
    }
    
    
    var image: UIImage {
        let size = CGSize(width: 20.0, height: 20.0)
        return UIImage(color: uiColor, size: size)!
    }
    
    static var allColors: [Color] {
        return [.red, .blue, .green, .purple]
    }
    
    static var segmentedControlImages: [Any] {
        return allColors.map { $0.image }
    }
    
    static var segmentedControlTitles: [String] {
        return allColors.map { $0.title }
    }
}

extension User {
    
    func changeNameAlertController(in context: NSManagedObjectContext, handler: ((UIAlertAction, String?) -> Void)?) -> UIAlertController {
        let alertController = UIAlertController(title: "Change name", message: "Change your name here!", preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Name ..."
        }
        let textField = alertController.textFields![0]
        context.perform {
            guard let currentName = self.name else {
                return
            }
            DispatchQueue.main.async {
                textField.text = currentName
                textField.setNeedsLayout()
            }
        }
        
        let setAction = UIAlertAction(title: "Set", style: .default) { (action) in
            guard let actualName = textField.text, !actualName.isEmpty else {
                handler?(action, textField.text)
                return
            }
            defer {
                handler?(action, actualName)
            }
            context.performAndWait {
                DataController.sharedController.fetchCurrentUser(in: context).name = actualName
                DataController.sharedController.save(context: context)
            }
        }
        alertController.addAction(setAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            handler?(action, nil)
        }
        alertController.addAction(cancelAction)
        
        return alertController
    }
    
}

