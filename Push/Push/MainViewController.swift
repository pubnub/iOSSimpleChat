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

class MainViewController: UIViewController {
    
    private var mainViewContext = 0
        
    var stackView: UIStackView!
    var pushTokenLabel: UILabel!
    var pushChannelsButton: UIButton!
    var clientConfigurationButton: UIButton!
    var pushChannelsAuditButton: UIButton!
    let pushChannelsAuditButtonTitle = "Get push channels for token"
    let pushChannelsButtonPlaceholder = "Tap here to add push channels"
    let pushTokenLabelPlaceholder = "No push token currently"
    let configButtonPlaceholder = "Tap here to set pub key and sub key"
    
    var pushTokenLabelGR: UITapGestureRecognizer!
    
    let fetchRequest: NSFetchRequest<Event> = {
        let request: NSFetchRequest<Event> = Event.fetchRequest()
        let creationDateSortDescriptor = NSSortDescriptor(key: #keyPath(Event.creationDate), ascending: false)
        request.sortDescriptors = [creationDateSortDescriptor]
        return request
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
    }
    
    override func loadView() {
        stackView = UIStackView(frame: .zero)
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateConfigButton()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationItem.title = "Push!"
        
        clientConfigurationButton = UIButton(type: .system)
        clientConfigurationButton.setTitle("Client info", for: .normal)
        guard let clientConfigImage = UIImage(color: .yellow) else {
            fatalError("Couldn't create one color UIImage!")
        }
        clientConfigurationButton.setBackgroundImage(clientConfigImage, for: .normal)
        clientConfigurationButton.titleLabel?.numberOfLines = 2
        clientConfigurationButton.titleLabel?.adjustsFontSizeToFitWidth = true
        clientConfigurationButton.addTarget(self, action: #selector(clientConfigurationButtonPressed(sender:)), for: .touchUpInside)
        clientConfigurationButton.forceAutoLayout()
        stackView.addArrangedSubview(clientConfigurationButton)
        
        pushTokenLabel = UILabel(frame: .zero)
        pushTokenLabel.backgroundColor = .red
        pushTokenLabel.adjustsFontSizeToFitWidth = true
        pushTokenLabel.textAlignment = .center
        pushTokenLabel.numberOfLines = 2
        pushTokenLabel.isUserInteractionEnabled = true
        pushTokenLabel.forceAutoLayout()
        stackView.addArrangedSubview(pushTokenLabel)
        
        pushTokenLabelGR = UITapGestureRecognizer(target: self, action: #selector(pushTokenLabelTapped(sender:)))
        pushTokenLabel.addGestureRecognizer(pushTokenLabelGR)
        
        pushChannelsAuditButton = UIButton(type: .system)
        guard let pushChannelsAuditImage = UIImage(color: .green) else {
            fatalError("Couldn't create one color UIImage!")
        }
        pushChannelsAuditButton.setTitle(pushChannelsAuditButtonTitle, for: .normal)
        pushChannelsAuditButton.setBackgroundImage(pushChannelsAuditImage, for: .normal)
        pushChannelsAuditButton.addTarget(self, action: #selector(pushChannelsAuditButtonPressed(sender:)), for: .touchUpInside)
        pushChannelsAuditButton.forceAutoLayout()
        stackView.addArrangedSubview(pushChannelsAuditButton)
        
        pushChannelsButton = UIButton(type: .custom)
        guard let pushBackgroundImage = UIImage(color: .cyan) else {
            fatalError("Couldn't create one color UIImage!")
        }
        pushChannelsButton.setBackgroundImage(pushBackgroundImage, for: .normal)
//        pushChannelsButton.addTarget(self, action: #selector(pushChannelsButtonPressed(sender:)), for: .touchUpInside)
        stackView.addArrangedSubview(pushChannelsButton)
        consoleView = ClientConsoleView(fetchRequest: fetchRequest)
        stackView.addArrangedSubview(consoleView)
        
        let pushTokenLabelVerticalConstraints = NSLayoutConstraint(item: pushTokenLabel, attribute: .height, relatedBy: .equal, toItem: stackView, attribute: .height, multiplier: 0.10, constant: 0)
        let pushChannelsButtonVerticalConstraints = NSLayoutConstraint(item: pushChannelsButton, attribute: .height, relatedBy: .equal, toItem: stackView, attribute: .height, multiplier: 0.20, constant: 0)
        let pushChannelsAuditButtonVerticalConstraints = NSLayoutConstraint(item: pushChannelsAuditButton, attribute: .height, relatedBy: .equal, toItem: stackView, attribute: .height, multiplier: 0.15, constant: 0)
        let clientConfigButtonVerticalConstraints = NSLayoutConstraint(item: clientConfigurationButton, attribute: .height, relatedBy: .equal, toItem: stackView, attribute: .height, multiplier: 0.125, constant: 0)
        
        NSLayoutConstraint.activate([pushChannelsButtonVerticalConstraints, pushTokenLabelVerticalConstraints, pushChannelsAuditButtonVerticalConstraints, clientConfigButtonVerticalConstraints])
        
//        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Clear", style: .done, target: self, action: #selector(clearConsoleButtonPressed(sender:)))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Options", style: .plain, target: self, action: #selector(optionsButtonPressed(sender:)))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Publish", style: .plain, target: self, action: #selector(publishButtonPressed(sender:)))
        
        updateConfigButton()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Actions
    
    func clientConfigurationButtonPressed(sender: UIButton) {
        let configurationController = ConfigurationViewController()
        configurationController.configuration = Network.sharedNetwork.currentConfiguration
        navigationController?.pushViewController(configurationController, animated: true)
        
    }
    
    func pushTokenLabelTapped(sender: UITapGestureRecognizer) {
        guard let pushTokenText = pushTokenLabel.text, pushTokenText != pushTokenLabelPlaceholder else {
            return
        }
        copyToClipboard(text: pushTokenText)
    }
    
    func copyToClipboard(text: String) {
        UIPasteboard.general.string = text
        navigationItem.setPrompt(with: "Copied push token to clipboard")
    }
    
    func publishButtonPressed(sender: UIBarButtonItem) {
        let alertController = Network.sharedNetwork.publishAlertController()
        present(alertController, animated: true)
    }
    
    func pushChannelsAuditButtonPressed(sender: UIButton) {
        Network.sharedNetwork.requestPushChannelsForCurrentPushToken()
    }
    
    func optionsButtonPressed(sender: UIBarButtonItem) {
        let optionsAlertController = UIAlertController.optionsAlertController()
        present(optionsAlertController, animated: true)
    }
    
    func pushChannelsButtonPressed(sender: UIButton) {
        let viewContext = DataController.sharedController.viewContext
        let pushChannelsAlertController = DataController.sharedController.fetchCurrentUser().alertControllerForPushChannels(in: viewContext)
        present(pushChannelsAlertController, animated: true)
    }
    
    // MARK: - KVO
    
    // Properties
    
    func configButtonTitle() -> String {
        guard let pubKeyTitle = Network.sharedNetwork.pubKeyString, let subKeyTitle = Network.sharedNetwork.subKeyString else {
            return configButtonPlaceholder
        }
        return "Pub: \(pubKeyTitle)\nSub: \(subKeyTitle)"
    }
    
    func pushChannelsButtonTitle() -> String {
        var finalTitle: String? = nil
        DataController.sharedController.viewContext.performAndWait {
            guard let currentPushChannelsString = DataController.sharedController.fetchCurrentUser().pushChannelsString else {
                finalTitle = self.pushChannelsButtonPlaceholder
                return
            }
            finalTitle = "Push channels: \(currentPushChannelsString)"
        }
        return finalTitle!
    }
    
    func pushTokenTitle() -> String {
        var finalTitle: String? = nil
        DataController.sharedController.viewContext.performAndWait {
//            finalTitle = (DataController.sharedController.fetchCurrentUser().pushTokenString ?? self.pushTokenLabelPlaceholder)
            guard let currentPushTokenTitle = DataController.sharedController.fetchCurrentUser().pushTokenString else {
                finalTitle = self.pushTokenLabelPlaceholder
                return
            }
            finalTitle = "Push Device Token\n\(currentPushTokenTitle)"
        }
        return finalTitle!
    }
    
    func updatePushChannelsButton() {
        let title = pushChannelsButtonTitle()
        DispatchQueue.main.async {
            self.pushChannelsButton.setTitle(title, for: .normal)
            self.pushChannelsButton.setNeedsLayout()
        }
    }
    
    func updateConfigButton() {
        let title = configButtonTitle()
        DispatchQueue.main.async {
            self.clientConfigurationButton.setTitle(title, for: .normal)
            self.clientConfigurationButton.setNeedsLayout()
        }
    }
    
    func updatePushTokenLabel() {
        let title = pushTokenTitle()
        DispatchQueue.main.async {
            self.pushTokenLabel.text = title
            self.pushTokenLabel.setNeedsLayout()
        }
    }
    
    var currentUser: User? {
        didSet {
            if let existingOldValue = oldValue {
                existingOldValue.removeObserver(self, forKeyPath: #keyPath(User.pushChannels), context: &mainViewContext)
                existingOldValue.removeObserver(self, forKeyPath: #keyPath(User.pushToken), context: &mainViewContext)
            }
            currentUser?.addObserver(self, forKeyPath: #keyPath(User.pushToken), options: [.new, .old, .initial], context: &mainViewContext)
            currentUser?.addObserver(self, forKeyPath: #keyPath(User.pushChannels), options: [.new, .old, .initial], context: &mainViewContext)
        }
    }
    
    // Deinit
    
    deinit {
        self.currentUser = nil
    }
    
    // KVO
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &mainViewContext {
            guard let existingKeyPath = keyPath else {
                return
            }
            switch existingKeyPath {
            case #keyPath(User.pushChannels):
                updatePushChannelsButton()
            case #keyPath(User.pushToken):
                updatePushTokenLabel()
            default:
                fatalError("what wrong in KVO?")
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    

}
