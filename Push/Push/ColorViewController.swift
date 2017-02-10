//
//  ColorViewController.swift
//  Push
//
//  Created by Jordan Zucker on 2/9/17.
//  Copyright © 2017 PubNub. All rights reserved.
//

import UIKit
import CoreData

class ColorViewController: UIViewController {
    
    private var mainViewContext = 0
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let bounds = UIScreen.main.bounds
        var topPadding = UIApplication.shared.statusBarFrame.height
        if let navBarHeight = navigationController?.navigationBar.frame.height {
            topPadding += navBarHeight
        }
        let stackViewFrame = CGRect(x: bounds.origin.x, y: bounds.origin.y + topPadding, width: bounds.size.width, height: bounds.size.height - topPadding)
        stackView.frame = stackViewFrame
        view.frame = bounds
    }
    
    func updateBackgroundView() {
        DataController.sharedController.viewContext.perform {
            guard let actualUser = self.currentUser else {
                return
            }
            let backgroundColor = actualUser.backgroundColor.uiColor
            DispatchQueue.main.async {
                self.backgroundView.image = UIImage(color: backgroundColor)
                self.backgroundView.setNeedsLayout()
            }
        }
    }
    
    var backgroundView: UIImageView!
    
    class var formattedStackView: UIStackView {
        let superStackView = UIStackView(frame: .zero)
        superStackView.axis = .vertical
        superStackView.alignment = .fill
        superStackView.distribution = .fill
        return superStackView
    }
    
    let stackView: UIStackView!
    
    override func loadView() {
        backgroundView = UIImageView(frame: .zero)
        let baseView = UIView(frame: .zero)
        baseView.addSubview(backgroundView)
        backgroundView.sizeAndCenter(to: baseView)
        baseView.addSubview(stackView)
        baseView.bringSubview(toFront: stackView)
        self.view = baseView
        self.view.setNeedsLayout()
    }
    
    required init() {
        self.stackView = type(of: self).formattedStackView
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.backgroundColor = .white
        
        defer {
            view.setNeedsLayout()
        }
        guard let navBar = navigationController?.navigationBar else {
            return
        }
        navigationTitleView = ColorTitleView(name: nil, image: nil)
        navigationItem.titleView = navigationTitleView
        var updatedTitleViewFrame = navBar.frame
        updatedTitleViewFrame.size = CGSize(width: navBar.frame.size.width/2.0, height: navBar.frame.size.height - 5.0)
        navigationTitleView.frame = updatedTitleViewFrame
        navigationTitleView.center = navBar.center
        navigationController?.navigationBar.setNeedsLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        currentUser = DataController.sharedController.fetchCurrentUser()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        currentUser = nil
    }

    deinit {
        currentUser = nil
    }
    
    var navigationTitleView: ColorTitleView!
    
    func updateNavigationTitle() {
        DataController.sharedController.viewContext.perform {
            guard let actualUser = self.currentUser else {
                return
            }
            DispatchQueue.main.async {
                let update = ColorTitleUpdate(image: actualUser.lastColorUpdaterThumbnail, name: actualUser.lastColorUpdaterName)
                self.navigationTitleView.update(with: update)
            }
        }
    }
    
    func receivedColorUpdate() {
        updateBackgroundView()
        updateNavigationTitle()
    }
    
    class var observerResponses: [String:Selector] {
        return [#keyPath(User.rawBackgroundColor): #selector(self.receivedColorUpdate)]
    }
    
    var currentUser: User? {
        didSet {
            let observingKeyPaths = type(of: self).observerResponses
            for (keyPath, _) in observingKeyPaths {
                oldValue?.removeObserver(self, forKeyPath: keyPath, context: &mainViewContext)
                currentUser?.addObserver(self, forKeyPath: keyPath, options: [.new, .old, .initial], context: &mainViewContext)
            }
        }
    }
    
    // MARK: - KVO
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &mainViewContext {
            let observingKeyPaths = type(of: self).observerResponses
            guard let actualKeyPath = keyPath, let action = observingKeyPaths[actualKeyPath] else {
                fatalError("we should have had an action for this keypath since we are observing it")
            }
            let mainQueueUpdate = DispatchWorkItem(qos: .userInitiated, flags: [.enforceQoS], block: { [weak self] in
                _ = self?.perform(action)
            })
            DispatchQueue.main.async(execute: mainQueueUpdate)
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }

}
