//
//  MemeEditor.swift
//  meme
//
//  Created by Ioannis Tornazakis on 12/3/15.
//  Copyright (c) 2015 polarbear.gr. All rights reserved.
//

import UIKit

class MemeEditor:   UIViewController, UINavigationControllerDelegate {

    // MARK: - Variables
    
    // Text Field Delegate objects
    let topTextFieldDelegate = TopTextFieldDelegate()

    // MARK: - Outlets
    
    @IBOutlet weak var ImagePickerView: UIImageView!
    @IBOutlet weak var topText: UITextField!
    @IBOutlet weak var bottomText: UITextField!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var topToolBar: UIToolbar!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Disable the share button until a meme is saved
        shareButton.isEnabled = false
        
        // Prepare the top and bottom Text Fields
        
        // Disable the fields until a meme an image is selected
        topText.isEnabled = false
        bottomText.isEnabled = false
        
        // Default attributes for text fields
        let memeTextAttributes = [
            NSStrokeColorAttributeName : UIColor.black,
            NSForegroundColorAttributeName : UIColor.white,
            NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSStrokeWidthAttributeName : -3.0 // Negative value to fill the text
        ] as [String : Any]
        
        // topText properties
        topText.delegate = topTextFieldDelegate
        topText.text = "Top"
        topText.defaultTextAttributes = memeTextAttributes
        topText.textAlignment = NSTextAlignment.center
        
        // bottomText properties
        bottomText.delegate = self // Using the delegate here in MemeEditor
        bottomText.text = "Bottom"
        bottomText.defaultTextAttributes = memeTextAttributes
        bottomText.textAlignment = NSTextAlignment.center
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Enable the camera button only on devices that have one
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)
    }
    
    // MARK: - Actions
    
    @IBAction func PickImageFromAlbum(_ sender: AnyObject) {
        
        // Initialize the image picker controller
        let picker = UIImagePickerController()
        
        // Assign the ViewController delegate methods to the picker
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = UIImagePickerControllerSourceType.savedPhotosAlbum
        
        // Launch the picker
        self.present(picker, animated: true, completion: nil)
    }
    
    /**
        Available only on devices that have a camera
    */
    @IBAction func PickImageFromCamera(_ sender: AnyObject) {
        
        // Initialize the image picker controller
        let picker = UIImagePickerController()
        
        // Assign the ViewController delegate methods to the picker
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = UIImagePickerControllerSourceType.camera
        
        // Launch the picker
        self.present(picker, animated: true, completion: nil)
    }
    
    @IBAction func shareMeme(_ sender: AnyObject) {
        
        // Generate a memed image
        let image = self.generateMemedImage()
        
        // Define an instance of the ActivityViewController and pass the ActivityViewController a memedImage as an activity item
        let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        
        // Present the ActivityViewController
        self.present(activityViewController, animated: true,
            completion: nil)
        
        // Control flow when the activity controller exits
        activityViewController.completionWithItemsHandler = {
            
            // Save the meme just before dismissing the activity view
            (s: UIActivityType?, ok: Bool, items: [Any]?, err:Error?) -> Void in
            
            // Save the meme only if a valid action is selected, do not save if the user selects the Cancel option
            if ok {
                self.saveMeme()
                self.dismiss(animated: true, completion: nil)
            }
            
            // Go to the Sent Meme View options with modal presentation
            OperationQueue.main.addOperation {
                let storyboard = UIStoryboard (name: "Main", bundle: nil)
                let nextVC = storyboard.instantiateViewController(withIdentifier: "MemeTable") as! MemeTable
                self.present(nextVC, animated: true, completion: nil)
            }
        }
    }
    
    /// Dismiss the editor in order to get back to the sent memes being the presenting view controller
    @IBAction func exitEditor(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Image Capture Methods
    
    func generateMemedImage() -> UIImage {
        
        // Hide the toolbars
        self.topToolBar.isHidden = true
        self.toolBar.isHidden = true
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        self.view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // Show the toolbars
        self.topToolBar.isHidden = false
        self.toolBar.isHidden = false
        
        return memedImage
    }
    
    func saveMeme() {
        
        // Check that an image exists on the picker before attempting to greate a meme
        if ((self.ImagePickerView.image) != nil ) {
            
            // Save the meme into the model struct
            let meme = Meme(
                topText: topText.text!,
                bottomText: bottomText.text!,
                originalImage: self.ImagePickerView.image!,
                memedImage: self.generateMemedImage()
            )
            
            // Add it to the memes array in the Application Delegate
            let object = UIApplication.shared.delegate
            let appDelegate = object as! AppDelegate
            appDelegate.memes.append(meme)
        }
    }
    
    // MARK: - Keyboard Methods
    
    func keyboardWillShow(_ notification: Notification) {
        
        // Reset the view to it's original position every time the keyboard is about to show to counter for different keyboard heights (ie when changing language or emoticons) during the same runtime
        self.view.frame.origin.y = 0.0
        
        // Move the keyboard out of the way
        self.view.frame.origin.y -= getKeyboardHeight(notification)
    }
    
    /// Reset the frame to its original position
    func keyboardWillHide(_ notification: Notification) {
        self.view.frame.origin.y = 0.0
    }
    
    /// Get keyboard height from the notification service
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = (notification as NSNotification).userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    // MARK: - Notification subscriptions
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(MemeEditor.keyboardWillShow(_:)),
            name: NSNotification.Name.UIKeyboardWillShow,
            object:nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(MemeEditor.keyboardWillHide(_:)),
            name: NSNotification.Name.UIKeyboardWillHide,
            object:nil
        )
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
}

extension MemeEditor: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            
            // Force the text to be on the image by using aspect fill
            self.ImagePickerView.contentMode = .scaleAspectFill
            self.ImagePickerView.image = image
            
            // Enable the share button
            shareButton.isEnabled = true
            
            // Enable the text fields
            topText.isEnabled = true
            bottomText.isEnabled = true
        }
        
        // Opt to dismiss the picker
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        // Opt to dismiss the picker
        self.dismiss(animated: true, completion: nil)
    }
}

extension MemeEditor: UITextFieldDelegate {

    /// In this delegate the keyboard subscriptions are integrated. They are intended to be used only from the bottomText which requires the view to move when the keyboard is about to show
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        // Enable the view to raise only for the bottom text field
        self.subscribeToKeyboardNotifications()
        
        // Removing default text only, not user text
        textField.text = ""
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        // Hides the keyboard
        textField.resignFirstResponder()
        
        // Disable the view raise for other text fields
        self.unsubscribeFromKeyboardNotifications()
        return true
    }
    
}
