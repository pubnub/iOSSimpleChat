//
//  ColorSegmentedControl.swift
//  Push
//
//  Created by Jordan Zucker on 2/7/17.
//  Copyright © 2017 PubNub. All rights reserved.
//

import UIKit

class ColorSegmentedControl: UISegmentedControl {
    
    override init(items: [Any]?) {
        super.init(items: items)
        isMomentary = true
        tintColor = .black
        layer.borderColor = UIColor.black.cgColor
        layer.borderWidth = 2.0
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init() {
        self.init(items: Color.segmentedControlImages)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var selectedColor: Color {
        return Color(rawValue: Int16(selectedSegmentIndex))!
    }

}
