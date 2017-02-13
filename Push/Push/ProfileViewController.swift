//
//  ProfileViewController.swift
//  Push
//
//  Created by Jordan Zucker on 2/7/17.
//  Copyright © 2017 PubNub. All rights reserved.
//

import UIKit

class ProfileViewController: ColorViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
    
    override class var formattedStackView: UIStackView {
        let creatingStackView = UIStackView(frame: .zero)
        creatingStackView.axis = .vertical
        creatingStackView.alignment = .fill
        creatingStackView.distribution = .equalSpacing
        return creatingStackView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.backgroundView.image = UIImage(color: .white)
        
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
        profileImageButton.roundCorners()
        profileImageButton.autoresizesSubviews = false
        profileImageButton.forceAutoLayout()
        profileImageButton.addTarget(self, action: #selector(profileImageButtonTapped(sender:)), for: .touchUpInside)
        profileImageButton.setImage(UIImage(named: "pubnub.png"), for: .normal)
        stackView.addArrangedSubview(profileImageButton)
        
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)

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
            DispatchQueue.main.async { [weak self] in
                guard let actualCanSave = self?.canSave else {
                    return
                }
                self?.navigationItem.rightBarButtonItem?.isEnabled = actualCanSave
            }
        }
    }
    
    func updateName() {
        guard let actualUser = currentUser else {
            canSave = false
            return
        }
        DataController.sharedController.viewContext.perform { [weak self] in
            defer {
                self?.profileNameButton.setNeedsLayout()
            }
            guard let name = actualUser.name else {
                self?.canSave = false
                self?.profileNameButton.setTitle(nil, for: .selected)
                self?.profileNameButton.isSelected = false
                return
            }
            self?.canSave = true
            self?.profileNameButton.setTitle(name, for: .selected)
            self?.profileNameButton.isSelected = true
        }
    }
    
    func updateImage() {
        guard let actualUser = currentUser else {
            return
        }
        DataController.sharedController.viewContext.perform { [weak self] in
            defer {
                self?.profileImageButton.setNeedsLayout()
            }
            guard let thumbnail = actualUser.thumbnail else {
                return
            }
            self?.profileImageButton.setImage(thumbnail, for: .normal)
        }
    }
    
    override class var observerResponses: [String:Selector] {
        var finalObserverResponses = super.observerResponses
        let addingObserverResponses = [#keyPath(User.name): #selector(updateName),
                                       #keyPath(User.thumbnail): #selector(updateImage)]
        finalObserverResponses.merge(with: addingObserverResponses)
        return finalObserverResponses
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
