//
//  KeyValueLabelCollectionViewCell.swift
//  Push
//
//  Created by Jordan Zucker on 1/25/17.
//  Copyright © 2017 PubNub. All rights reserved.
//

import UIKit
import PubNub

protocol KeyValueAlertControllerUpdates: KeyValue {
    mutating func updateAlertController(handler: ((UIAlertAction, KeyValue?) -> Swift.Void)?) -> UIAlertController
}

extension KeyValueAlertControllerUpdates {
    mutating func updateAlertController(handler: ((UIAlertAction, KeyValue?) -> Swift.Void)? = nil) -> UIAlertController {
        let message = displayKeyName
        let alertController = UIAlertController(title: "Update configuration", message: message, preferredStyle: .alert)
        
        let textFieldText = displayValue
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Enter value ..."
            textField.text = textFieldText
        }
        let valueTextField = alertController.textFields![0] // we just added above, so can forcibly unwrap
        
        
        var updatedKeyValue = self
        let updateAction = UIAlertAction(title: "Update", style: .default) { (action) in
            updatedKeyValue.value = valueTextField.text
            
            handler?(action, updatedKeyValue)
        }
        alertController.addAction(updateAction)
        
        let resetAction = UIAlertAction(title: "Reset", style: .destructive) { (action) in
            handler?(action, nil)
        }
        alertController.addAction(resetAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            handler?(action, nil)
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
