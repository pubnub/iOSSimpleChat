//
//  ColorTitleView.swift
//  Push
//
//  Created by Jordan Zucker on 2/9/17.
//  Copyright © 2017 PubNub. All rights reserved.
//

import UIKit

struct ColorTitleUpdate {
    let image: UIImage?
    let name: String?
}

class ColorTitleView: UIView {
    
    let imageView = UIImageView(frame: .zero)
    let titleLabel = UILabel(frame: .zero)
    let stackView = UIStackView(frame: .zero)
        
    required init(name: String?, image: UIImage?) {
        super.init(frame: .zero)
        addSubview(stackView)
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillProportionally
        stackView.forceAutoLayout()
        stackView.sizeAndCenter(to: self)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(imageView)
        titleLabel.forceAutoLayout()
        titleLabel.numberOfLines = 2
        titleLabel.textAlignment = .center
        titleLabel.adjustsFontSizeToFitWidth = true
        stackView.spacing = 1.0
        imageView.forceAutoLayout()
        imageView.roundCorners()
        imageView.heightAnchor.constraint(lessThanOrEqualTo: imageView.widthAnchor).isActive = true
        update(with: ColorTitleUpdate(image: image, name: name))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(with update: ColorTitleUpdate) {
        var titleText = "Color changed by:\n"
        defer {
            titleLabel.text = titleText
            setNeedsLayout()
        }
        if let actualName = update.name {
            titleText += "\(actualName)"
        }
        if let actualImage = update.image {
            imageView.image = actualImage
        } else {
            imageView.image = nil
        }
    }

}
