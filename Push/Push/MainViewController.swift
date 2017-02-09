//
//  MainViewController.swift
//  Push
//
//  Created by Jordan Zucker on 1/9/17.
//  Copyright © 2017 PubNub. All rights reserved.
//

import UIKit
import PubNub
import CoreData

class MainViewController: UIViewController, UITextFieldDelegate, ClientConsoleViewDelegate {
    
    struct ProfileViewUpdate {
        let name: String?
        let image: UIImage?
    }
    
    class ProfileView: UIView {
        
        let nameLabel: UILabel
        let profileImageView: UIImageView
        let stackView: UIStackView
        
        override init(frame: CGRect) {
            self.stackView = UIStackView(frame: .zero)
            self.nameLabel = UILabel(frame: .zero)
            self.profileImageView = UIImageView(frame: .zero)
            super.init(frame: frame)
            stackView.forceAutoLayout()
            addSubview(stackView)
            stackView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
            stackView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
            stackView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.85).isActive = true
            stackView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.85).isActive = true
            stackView.axis = .horizontal
            stackView.alignment = .center
            stackView.distribution = .fill
            stackView.addArrangedSubview(profileImageView)
            stackView.addArrangedSubview(nameLabel)
            profileImageView.forceAutoLayout()
            profileImageView.layer.masksToBounds = true
            profileImageView.layer.cornerRadius = 5.0
            nameLabel.forceAutoLayout()
            let constraint = profileImageView.widthAnchor.constraint(lessThanOrEqualTo: heightAnchor)
            constraint.isActive = true
            nameLabel.adjustsFontSizeToFitWidth = true
            nameLabel.textAlignment = .center
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func update(with update: ProfileViewUpdate) {
            if let updatedName = update.name {
                nameLabel.text = updatedName
            }
            if let updatedImage = update.image {
                profileImageView.image = updatedImage
            }
            setNeedsLayout()
        }
    }
    
    var dismissInputAccessoryGR: UITapGestureRecognizer!
    
    func dismissInputAccessoryTapped(sender: UITapGestureRecognizer) {
        inputAccessoryView?.resignFirstResponder()
    }
    
    private var mainViewContext = 0
        
    var stackView: UIStackView!
        
    let fetchRequest: NSFetchRequest<Event> = {
        let request: NSFetchRequest<Event> = Event.fetchRequest()
        request.predicate = NSPredicate(format: "self.entity == %@", Message.entity())
        let creationDateSortDescriptor = NSSortDescriptor(key: #keyPath(Event.creationDate), ascending: true)
        request.sortDescriptors = [creationDateSortDescriptor]
        return request
    }()
    
    func publishButtonTapped(sender: UIButton) {
        publish()
    }
    
    // MARK: - Publish Action
    
    func publish() {
        inputAccessoryView?.resignFirstResponder()
        // TODO: Should we show anything to the user if there is nothing to publish?
        guard let publishTextField = inputAccessoryView as? PublishInputAccessoryView else {
            fatalError("Expected to find text field")
        }
        guard let message = publishTextField.text else {
            navigationItem.setPrompt(with: "There is nothing to publish")
            return
        }
        publishTextField.text = nil
        print("message: \(message)")
        Network.sharedNetwork.publish(chat: message)
    }
    
    internal lazy var customAccessoryView: PublishInputAccessoryView = {
        let bounds = UIScreen.main.bounds
        let frame = CGRect(x: 0, y: 0, width: bounds.width, height: self.inputAccessoryHeight)
        let publishView = PublishInputAccessoryView(target: self, action: #selector(publishButtonTapped(sender:)), frame: frame)
        publishView.delegate = self
        return publishView
    }()
    
    var consoleView: ClientConsoleView!
    var profileView: ProfileView!
    
    let inputAccessoryHeight = CGFloat(integerLiteral: 50)
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let bounds = UIScreen.main.bounds
        var topPadding = UIApplication.shared.statusBarFrame.height
        if let navBarHeight = navigationController?.navigationBar.frame.height {
            topPadding += navBarHeight
        }
        let stackViewFrame = CGRect(x: bounds.origin.x, y: bounds.origin.y + topPadding, width: bounds.size.width, height: bounds.size.height - topPadding - inputAccessoryHeight)
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
    
    public override var inputAccessoryView: UIView? {
        return customAccessoryView
    }
    
    public override var canBecomeFirstResponder: Bool {
        return true
    }
    
    var backgroundView: UIImageView!
    
    override func loadView() {
        stackView = UIStackView(frame: .zero)
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
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
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var colorSegmentedControl: ColorSegmentedControl!
    
    func colorSegmentedControlValueChanged(sender: ColorSegmentedControl) {
        inputAccessoryView?.resignFirstResponder()
        Network.sharedNetwork.publish(color: sender.selectedColor)
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = .white
        
        dismissInputAccessoryGR = UITapGestureRecognizer(target: self, action: #selector(dismissInputAccessoryTapped(sender:)))
        profileView = ProfileView()
        profileView.isUserInteractionEnabled = true
        profileView.addGestureRecognizer(dismissInputAccessoryGR)
        profileView.forceAutoLayout()
        stackView.addArrangedSubview(profileView)
        colorSegmentedControl = ColorSegmentedControl()
        colorSegmentedControl.addTarget(self, action: #selector(colorSegmentedControlValueChanged(sender:)), for: .valueChanged)
        stackView.addArrangedSubview(colorSegmentedControl)
        colorSegmentedControl.forceAutoLayout()
        let colorSegmentedControlVerticalConstraints = NSLayoutConstraint(item: colorSegmentedControl, attribute: .height, relatedBy: .equal, toItem: stackView, attribute: .height, multiplier: 0.10, constant: 0)
        let profileViewVerticalConstraints = NSLayoutConstraint(item: profileView, attribute: .height, relatedBy: .equal, toItem: stackView, attribute: .height, multiplier: 0.20, constant: 0)
        NSLayoutConstraint.activate([profileViewVerticalConstraints, colorSegmentedControlVerticalConstraints])
        
        consoleView = ClientConsoleView(fetchRequest: fetchRequest)
        stackView.addArrangedSubview(consoleView)
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Profile", style: .done, target: self, action: #selector(updateUserButtonPressed(sender:)))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Options", style: .plain, target: self, action: #selector(optionsButtonPressed(sender:)))
        view.setNeedsLayout()
        consoleView.scrollToBottom()
        consoleView.delegate = self
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
    
    var navigationTitleView: ColorTitleView!
    
    
    
    func optionsButtonPressed(sender: UIBarButtonItem) {
        let optionsAlertController = UIAlertController.optionsAlertController(in: DataController.sharedController.viewContext) { (action) in
            
        }
        present(optionsAlertController, animated: true)
    }
    
    func updateUserButtonPressed(sender: UIBarButtonItem) {
        let profileViewController = ProfileViewController()
        navigationController?.pushViewController(profileViewController, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UITextFieldDelegate
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        publish()
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        currentUser = DataController.sharedController.fetchCurrentUser()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        currentUser = nil
        inputAccessoryView?.resignFirstResponder()
    }
    
    deinit {
        currentUser = nil
    }
    
    var currentUser: User? {
        didSet {
            let observingKeyPaths = [#keyPath(User.name), #keyPath(User.thumbnail), #keyPath(User.rawBackgroundColor)]
            observingKeyPaths.forEach { (keyPath) in
                oldValue?.removeObserver(self, forKeyPath: keyPath, context: &mainViewContext)
                self.currentUser?.addObserver(self, forKeyPath: keyPath, options: [.new, .old, .initial], context: &mainViewContext)
            }
        }
    }
    
    func updateProfileView() {
        DataController.sharedController.viewContext.perform {
            guard let actualUser = self.currentUser else {
                return
            }
            let update = ProfileViewUpdate(name: actualUser.name, image: actualUser.thumbnail)
            DispatchQueue.main.async {
                self.profileView.update(with: update)
            }
        }
    }
    
//    func updateNavigationTitle() {
//        DataController.sharedController.viewContext.perform {
//            guard let actualUser = self.currentUser else {
//                return
//            }
//            let updatedTitleView = ColorTitleView(name: actualUser.lastColorUpdaterName, image: actualUser.lastColorUpdaterThumbnail)
//            DispatchQueue.main.async {
//                guard let navBar = self.navigationController?.navigationBar else {
//                    return
//                }
//                
//                var updatedSize = navBar.frame.size
//                updatedSize.width = updatedSize.width / 2.0
//                updatedSize.height -= 5.0
//                let titleViewFrame = CGRect(origin: navBar.frame.origin, size: updatedSize)
//                updatedTitleView.frame = titleViewFrame
//                print(titleViewFrame.debugDescription)
//                updatedTitleView.center = navBar.center
//                updatedTitleView.layoutIfNeeded()
//                self.navigationItem.titleView = updatedTitleView
//            }
//        }
//    }
    func updateNavigationTitle() {
        DataController.sharedController.viewContext.perform {
            guard let actualUser = self.currentUser else {
                return
            }
            //            let updatedTitleView = ColorTitleView(name: actualUser.lastColorUpdaterName, image: actualUser.lastColorUpdaterThumbnail)
            DispatchQueue.main.async {
                let update = ColorTitleUpdate(image: actualUser.lastColorUpdaterThumbnail, name: actualUser.lastColorUpdaterName)
                self.navigationTitleView.update(with: update)
                //                guard let navBar = self.navigationController?.navigationBar else {
                //                    return
                //                }
                
                //                var updatedSize = navBar.frame.size
                //                updatedSize.width = updatedSize.width / 2.0
                //                updatedSize.height -= 5.0
                //                let titleViewFrame = CGRect(origin: navBar.frame.origin, size: updatedSize)
                //                print(titleViewFrame.debugDescription)
                //                updatedTitleView.frame = titleViewFrame
                //                updatedTitleView.center = navBar.center
                //                updatedTitleView.layoutIfNeeded()
                //                self.navigationItem.titleView = updatedTitleView
                //                self.navigationItem.titleView = updatedTitleView
                //                updatedTitleView.forceAutoLayout()
                //                updatedTitleView.center(in: navBar)
                //                updatedTitleView.widthAnchor.constraint(equalTo: navBar.widthAnchor, multiplier: 0.5).isActive = true
                //                updatedTitleView.heightAnchor.constraint(equalTo: navBar.heightAnchor, constant: -5.0).isActive = true
            }
        }
    }
    
    func receivedColorUpdate() {
        updateBackgroundView()
        updateNavigationTitle()
    }
    
    // MARK: - KVO
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &mainViewContext {
            guard let existingKeyPath = keyPath else {
                return
            }
            switch existingKeyPath {
            case #keyPath(User.name):
                fallthrough
            case #keyPath(User.thumbnail):
                updateProfileView()
            case #keyPath(User.rawBackgroundColor):
                receivedColorUpdate()
            default:
                fatalError("what wrong in KVO?")
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    // MARK: - ClientConsoleViewDelegate
    
    func consoleViewDidMove(_ consoleView: ClientConsoleView) {
        inputAccessoryView?.resignFirstResponder()
    }

}
