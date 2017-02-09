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
    case white = -1
    case red = 0
    case orange
    case yellow
    case green
    case blue
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
        case .white:
            return UIColor.white
        case .yellow:
            return UIColor.yellow
        case .orange:
            return UIColor.orange
        }
    }
    
    var title: String {
        switch self {
        case .white:
            return "White"
        case .red:
            return "Red"
        case .blue:
            return "Blue"
        case .green:
            return "Green"
        case .purple:
            return "Purple"
        case .orange:
            return "Orange"
        case .yellow:
            return "Yellow"
        }
    }
    
    
    var image: UIImage {
        let size = CGSize(width: 20.0, height: 20.0)
        return UIImage(color: uiColor, size: size)!
    }
    
    static var allColors: [Color] {
        return [.white, .red, .blue, .green, .purple, .orange, .yellow]
    }
    
    static var selectableColors: [Color] {
        return [.red, .orange, .yellow, .green, .blue, .purple]
    }
    
    static var segmentedControlImages: [Any] {
        return selectableColors.map { $0.image }
    }
    
    static var segmentedControlTitles: [String] {
        return selectableColors.map { $0.title }
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

