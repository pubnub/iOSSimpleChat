//
//  TitleContentsCollectionViewCell.swift
//  Push
//
//  Created by Jordan Zucker on 1/24/17.
//  Copyright © 2017 PubNub. All rights reserved.
//

import UIKit
import PubNub

protocol KeyValueAlertControllerUpdates: KeyValue {
    func updateAlertController() -> UIAlertController
}

extension KeyValueAlertControllerUpdates {
    func updateAlertController(handler: ((UIAlertAction) -> Swift.Void)? = nil) -> UIAlertController {
        let message = displayKeyName
        let alertController = UIAlertController(title: "Update configuration", message: message, preferredStyle: .alert)
        
        let updateAction = UIAlertAction(title: "Update", style: .default) { (action) in
            handler?(action)
        }
        alertController.addAction(updateAction)
        
        let resetAction = UIAlertAction(title: "Reset", style: .destructive) { (action) in
            handler?(action)
        }
        alertController.addAction(resetAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            handler?(action)
        }
        alertController.addAction(cancelAction)
        
        return alertController
    }
}

protocol KeyValue {
    var key: String { get }
    var displayKeyName: String { get }
    var value: Any? { get set }
    var displayValue: String? { get }
    
    var debugDescription: String { get }
}

extension KeyValue {

    var debugDescription: String {
        return "key: " + displayKeyName + "; value: " + (displayValue ?? "")
    }
}

enum ConfigurationProperty: KeyValue {
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

//struct ConfigurationProperty: KeyValue {
//    let key: String
//    
//}

protocol KeyValueCell {
    func update(with item: KeyValue)
}

class KeyValueLabelCollectionViewCell: UICollectionViewCell, KeyValueCell {
    
    let keyLabel: UILabel
    let valueLabel: UILabel
    
    override init(frame: CGRect) {
        self.keyLabel = UILabel(frame: .zero)
        self.valueLabel = UILabel(frame: .zero)
        super.init(frame: frame)
        keyLabel.forceAutoLayout()
        keyLabel.textAlignment = .center
        keyLabel.adjustsFontSizeToFitWidth = true
        valueLabel.textAlignment = .center
        valueLabel.adjustsFontSizeToFitWidth = true
        valueLabel.forceAutoLayout()
        contentView.addSubview(keyLabel)
        contentView.addSubview(valueLabel)
        contentView.backgroundColor = .red
//        let widthConstraint = NSLayoutConstraint(item: textView, attribute: .width, relatedBy: .equal, toItem: contentView, attribute: .width, multiplier: 1.0, constant: 0.0)
//        let heightConstraint = NSLayoutConstraint(item: textView, attribute: .height, relatedBy: .equal, toItem: contentView, attribute: .height, multiplier: 1.0, constant: 0.0)
//        let centerXConstraint = NSLayoutConstraint(item: textView, attribute: .centerX, relatedBy: .equal, toItem: contentView, attribute: .centerX, multiplier: 1.0, constant: 0.0)
//        let centerYConstraint = NSLayoutConstraint(item: textView, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1.0, constant: 0.0)
//        NSLayoutConstraint.activate([widthConstraint, heightConstraint, centerXConstraint, centerYConstraint])
        let views = [
            "keyLabel": keyLabel,
            "valueLabel": valueLabel,
        ]
        let heightConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[keyLabel][valueLabel]|", options: [], metrics: nil, views: views)
        let titleWidthConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[keyLabel]|", options: [], metrics: nil, views: views)
        let contentsWidthConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[valueLabel]|", options: [], metrics: nil, views: views)
        NSLayoutConstraint.activate(heightConstraints)
        NSLayoutConstraint.activate(titleWidthConstraints)
        NSLayoutConstraint.activate(contentsWidthConstraints)
        contentView.setNeedsLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        keyLabel.text = nil
        valueLabel.text = nil
        contentView.setNeedsLayout()
    }
    
    func update(with keyValue: KeyValue) {
        keyLabel.text = keyValue.displayKeyName
        valueLabel.text = keyValue.displayValue
        contentView.setNeedsLayout()
    }
}
