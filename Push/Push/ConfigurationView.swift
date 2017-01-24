//
//  ConfigurationView.swift
//  Push
//
//  Created by Jordan Zucker on 1/24/17.
//  Copyright © 2017 PubNub. All rights reserved.
//

import UIKit
import PubNub

class ConfigurationView: UICollectionView {
    
    required init(frame: CGRect, config: PNConfiguration) {
        super.init(frame: frame, collectionViewLayout: UICollectionViewFlowLayout())
        register(TitleContentsCollectionViewCell.self, forCellWithReuseIdentifier: TitleContentsCollectionViewCell.reuseIdentifier())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
