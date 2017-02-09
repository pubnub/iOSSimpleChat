//
//  ProfileViewController.swift
//  Push
//
//  Created by Jordan Zucker on 2/7/17.
//  Copyright © 2017 PubNub. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var stackView: UIStackView!
    
    var profileImageButton: UIButton!
    var profileNameButton: UIButton!
    var profileImageInstructionsLabel: UILabel!
    var profileNameInstructionsLabel: UILabel!
    
    func dismiss(sender: UIBarButtonItem) {
        guard let mainNavController = parent?.presentingViewController as? UINavigationController, let mainViewController = mainNavController.topViewController as? MainViewController else {
            return
        }
        dismiss(animated: true) { 
            mainViewController.becomeFirstResponder()
        }
    }
    
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
//        let accessorySize = CGSize(width: bounds.size.width, height: 100.0)
        //        accessoryView.frame = CGRect(origin: bounds.origin, size: accessorySize)
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    private var profileViewContext = 0
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        stackView = UIStackView(frame: .zero)
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        //        stackView.distribution = .fillProportionally
        let backgroundView = UIView(frame: .zero)
        backgroundView.backgroundColor = .white
        backgroundView.addSubview(stackView)
        self.view = backgroundView
        self.view.setNeedsLayout()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        profileNameInstructionsLabel = UILabel(frame: .zero)
        profileNameInstructionsLabel.forceAutoLayout()
        profileNameInstructionsLabel.adjustsFontSizeToFitWidth = true
        profileNameInstructionsLabel.text = "Tap below to set your name"
        profileNameInstructionsLabel.textAlignment = .center
        profileNameInstructionsLabel.textColor = .darkGray
        stackView.addArrangedSubview(profileNameInstructionsLabel)
        
        profileNameButton = UIButton(type: .system)
        profileNameButton.forceAutoLayout()
        profileNameButton.setTitle("Enter name here ...", for: .normal)
        profileNameButton.addTarget(self, action: #selector(profileNameButtonTapped(sender:)), for: .touchUpInside)
        stackView.addArrangedSubview(profileNameButton)
        
        profileImageInstructionsLabel = UILabel(frame: .zero)
        profileImageInstructionsLabel.forceAutoLayout()
        profileImageInstructionsLabel.textColor = .darkGray
        profileImageInstructionsLabel.adjustsFontSizeToFitWidth = true
        profileImageInstructionsLabel.text = "Tap below to set your avatar image"
        profileImageInstructionsLabel.textAlignment = .center
        stackView.addArrangedSubview(profileImageInstructionsLabel)
        
        profileImageButton = UIButton(type: .custom)
        profileImageButton.layer.masksToBounds = true
        profileImageButton.layer.cornerRadius = 5.0
        profileImageButton.autoresizesSubviews = false
        profileImageButton.forceAutoLayout()
        profileImageButton.addTarget(self, action: #selector(profileImageButtonTapped(sender:)), for: .touchUpInside)
        profileImageButton.setImage(UIImage(named: "pubnub.png"), for: .normal)
        stackView.addArrangedSubview(profileImageButton)
    
//        profileNameButton.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 0.5).isActive = true
//        profileNameButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 100).isActive = true
//        profileNameInstructionsLabel.heightAnchor.constraint(lessThanOrEqualToConstant: 20.0).isActive = true
//        profileNameInstructionsLabel.heightAnchor.constraint(equalToConstant: 20.0).isActive = true
//        profileNameButton.heightAnchor.constraint(equalTo: stackView.heightAnchor, multiplier: 0.20).isActive = true
//        profileImageInstructionsLabel.heightAnchor.constraint(equalToConstant: 20.0).isActive = true
        
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
        
        view.setNeedsLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        currentUser = DataController.sharedController.fetchCurrentUser()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        currentUser = nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Actions
    
    func profileNameButtonTapped(sender: UIButton) {
        guard let actualUser = currentUser else {
            return
        }
        let profileAlertController = actualUser.changeNameAlertController(in: DataController.sharedController.viewContext, handler: { (action, updatedName) in
        })
        present(profileAlertController, animated: true)
    }
    
    func imageSourceAlertController() -> UIAlertController {
        let alertController = UIAlertController(title: "Choose a source", message: "Select a source below", preferredStyle: .alert)
        let cameraTitle = "Camera"
        let photosTitle = "Photo Library"
//        let imagePickerController = UIImagePickerController()
        let handler: (UIAlertAction) -> Void = { (action) in
            let imagePickerController = UIImagePickerController()
            var sourceType: UIImagePickerControllerSourceType
            guard let actionTitle = action.title else {
                return
            }
            switch actionTitle {
            case cameraTitle:
                sourceType = .camera
            case photosTitle:
                sourceType = .photoLibrary
            default:
                fatalError("How did we get \(actionTitle)")
            }
            imagePickerController.sourceType = sourceType
            imagePickerController.delegate = self
            DispatchQueue.main.async {
                self.present(imagePickerController, animated: true)
            }
        }
        
        let cameraAction = UIAlertAction(title: cameraTitle, style: .default, handler: handler)
        let photosAction = UIAlertAction(title: photosTitle, style: .default, handler: handler)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.addAction(cameraAction)
        alertController.addAction(photosAction)
        alertController.addAction(cancelAction)
        
        return alertController
    }
    
    func profileImageButtonTapped(sender: UIButton) {
        let imageAlertController = imageSourceAlertController()
        present(imageAlertController, animated: true)
    }
    
    var canSave: Bool = false {
        didSet {
            DispatchQueue.main.async {
                self.navigationItem.rightBarButtonItem?.isEnabled = self.canSave
            }
        }
    }
    
    var currentUser: User? {
        didSet {
            let observingKeyPath = #keyPath(User.name)
            let otherPath = #keyPath(User.thumbnail)
            oldValue?.removeObserver(self, forKeyPath: observingKeyPath, context: &profileViewContext)
            currentUser?.addObserver(self, forKeyPath: observingKeyPath, options: [.new, .old, .initial], context: &profileViewContext)
            oldValue?.removeObserver(self, forKeyPath: otherPath, context: &profileViewContext)
            currentUser?.addObserver(self, forKeyPath: otherPath, options: [.new, .old, .initial], context: &profileViewContext)
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &profileViewContext {
            guard let existingKeyPath = keyPath else {
                return
            }
            switch existingKeyPath {
            case #keyPath(User.name):
                updateName()
            case #keyPath(User.thumbnail):
                updateImage()
            default:
                fatalError("what wrong in KVO?")
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    func updateName() {
        guard let actualUser = currentUser else {
            canSave = false
            return
        }
        DataController.sharedController.viewContext.perform {
            defer {
                self.profileNameButton.setNeedsLayout()
            }
            guard let name = actualUser.name else {
                self.canSave = false
                self.profileNameButton.setTitle(nil, for: .selected)
                self.profileNameButton.isSelected = false
                return
            }
            self.canSave = true
            self.profileNameButton.setTitle(name, for: .selected)
            self.profileNameButton.isSelected = true
        }
    }
    
    func updateImage() {
        guard let actualUser = currentUser else {
            return
        }
        DataController.sharedController.viewContext.perform {
            defer {
                self.profileImageButton.setNeedsLayout()
            }
            guard let thumbnail = actualUser.thumbnail else {
//                self.profileNameButton.setTitle(nil, for: .selected)
//                self.profileImageButton.setImage(nil, for: .selected)
//                self.profileImageButton.isSelected = false
                return
            }
//            self.profileNameButton.setTitle(name, for: .selected)
            self.profileImageButton.setImage(thumbnail, for: .normal)
//            self.profileImageButton.isSelected = true
        }
    }
    

    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        defer {
            picker.dismiss(animated: true)
        }
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            return
        }
        let context = DataController.sharedController.viewContext
        context.perform {
            DataController.sharedController.currentUser?.thumbnail = image
            DataController.sharedController.save(context: context)
        }
    }

}
