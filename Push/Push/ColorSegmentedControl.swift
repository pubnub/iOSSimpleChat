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
//        isMomentary = true
        let whiteImage = UIImage(color: .white)!
//        tintColor = .clear
        setBackgroundImage(whiteImage, for: .normal, barMetrics: .default)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init() {
//        self.init(items: Color.segmentedControlImages)
        self.init(items: Color.segmentedControlTitles)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
