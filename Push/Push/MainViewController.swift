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

class MainViewController: UIViewController, UITextFieldDelegate {
    
    private var mainViewContext = 0
        
    var stackView: UIStackView!
        
    let fetchRequest: NSFetchRequest<Event> = {
        let request: NSFetchRequest<Event> = Event.fetchRequest()
        request.predicate = NSPredicate(format: "self.entity == %@", Message.entity())
        let creationDateSortDescriptor = NSSortDescriptor(key: #keyPath(Event.creationDate), ascending: false)
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
        publishTextField.resignFirstResponder()
        guard let message = publishTextField.text else {
            navigationItem.setPrompt(with: "There is nothing to publish")
            return
        }
        print("message: \(message)")
        Network.sharedNetwork.publishChat(message: message)
//        let alertController = UIAlertController.publishAlertController(withCurrent: message) { (action, channel) -> (Void) in
//            // TODO: This should probably throw an error
//            guard let actualChannel = channel else {
//                self.navigationItem.setPrompt(with: "Must enter a channel to publish")
//                return
//            }
//            self.console.publish(message, toChannel: actualChannel)
//        }
//        present(alertController, animated: true)
    }
    
    internal lazy var customAccessoryView: PublishInputAccessoryView = {
        let bounds = UIScreen.main.bounds
        let frame = CGRect(x: 0, y: 0, width: bounds.width, height: 50.0)
        let publishView = PublishInputAccessoryView(target: self, action: #selector(publishButtonTapped(sender:)), frame: frame)
        publishView.delegate = self
        return publishView
    }()
    
    var consoleView: ClientConsoleView!
    
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
        let accessorySize = CGSize(width: bounds.size.width, height: 100.0)
//        accessoryView.frame = CGRect(origin: bounds.origin, size: accessorySize)
    }
    
    public override var inputAccessoryView: UIView? {
        return customAccessoryView
    }
    
    public override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func loadView() {
        stackView = UIStackView(frame: .zero)
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
//        stackView.distribution = .fillProportionally
        let backgroundView = UIView(frame: .zero)
        backgroundView.addSubview(stackView)
        self.view = backgroundView
        self.view.setNeedsLayout()
    }
    
    required init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var colorSegmentedControl: ColorSegmentedControl!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationItem.title = "Push!"
        
        colorSegmentedControl = ColorSegmentedControl()
        stackView.addArrangedSubview(colorSegmentedControl)
        colorSegmentedControl.forceAutoLayout()
//        colorSegmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
//        colorSegmentedControl.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
//        let colorSegmentedControlHeightConstant = CGFloat(floatLiteral: 100.0)
//        colorSegmentedControl.heightAnchor.constraint(equalTo: stackView.heightAnchor, multiplier: 0.0, constant: colorSegmentedControlHeightConstant)
        let colorSegmentedControlVerticalConstraints = NSLayoutConstraint(item: colorSegmentedControl, attribute: .height, relatedBy: .equal, toItem: stackView, attribute: .height, multiplier: 0.10, constant: 0)
        NSLayoutConstraint.activate([colorSegmentedControlVerticalConstraints])
        
        consoleView = ClientConsoleView(fetchRequest: fetchRequest)
        stackView.addArrangedSubview(consoleView)
//        consoleView.forceAutoLayout()
//        consoleView.heightAnchor.constraint(equalTo: stackView.heightAnchor, multiplier: 1.0, constant: -colorSegmentedControlHeightConstant).isActive = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Profile", style: .done, target: self, action: #selector(updateUserButtonPressed(sender:)))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Options", style: .plain, target: self, action: #selector(optionsButtonPressed(sender:)))
        view.setNeedsLayout()
    }
    
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
    }
    
    deinit {
        currentUser = nil
    }
    
    var currentUser: User? {
        didSet {
//            let observingKeyPath = #keyPath(User.showDebug)
//            oldValue?.removeObserver(self, forKeyPath: observingKeyPath, context: &mainViewContext)
//            currentUser?.addObserver(self, forKeyPath: observingKeyPath, options: [.new, .old, .initial], context: &mainViewContext)
        }
    }
    
//    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
//        if context == &mainViewContext {
//            guard let existingKeyPath = keyPath else {
//                return
//            }
//            switch existingKeyPath {
//            case #keyPath(User.showDebug):
//                updateShowDebug()
//            default:
//                fatalError("what wrong in KVO?")
//            }
//        } else {
//            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
//        }
//    }

}
