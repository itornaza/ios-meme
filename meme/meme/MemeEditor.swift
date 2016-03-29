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
        shareButton.enabled = false
        
        // Prepare the top and bottom Text Fields
        
        // Disable the fields until a meme an image is selected
        topText.enabled = false
        bottomText.enabled = false
        
        // Default attributes for text fields
        let memeTextAttributes = [
            NSStrokeColorAttributeName : UIColor.blackColor(),
            NSForegroundColorAttributeName : UIColor.whiteColor(),
            NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSStrokeWidthAttributeName : -3.0 // Negative value to fill the text
        ]
        
        // topText properties
        topText.delegate = topTextFieldDelegate
        topText.text = "Top"
        topText.defaultTextAttributes = memeTextAttributes
        topText.textAlignment = NSTextAlignment.Center
        
        // bottomText properties
        bottomText.delegate = self // Using the delegate here in MemeEditor
        bottomText.text = "Bottom"
        bottomText.defaultTextAttributes = memeTextAttributes
        bottomText.textAlignment = NSTextAlignment.Center
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Enable the camera button only on devices that have one
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
    }
    
    // MARK: - Actions
    
    @IBAction func PickImageFromAlbum(sender: AnyObject) {
        
        // Initialize the image picker controller
        let picker = UIImagePickerController()
        
        // Assign the ViewController delegate methods to the picker
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum
        
        // Launch the picker
        self.presentViewController(picker, animated: true, completion: nil)
    }
    
    /**
        Available only on devices that have a camera
    */
    @IBAction func PickImageFromCamera(sender: AnyObject) {
        
        // Initialize the image picker controller
        let picker = UIImagePickerController()
        
        // Assign the ViewController delegate methods to the picker
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = UIImagePickerControllerSourceType.Camera
        
        // Launch the picker
        self.presentViewController(picker, animated: true, completion: nil)
    }
    
    @IBAction func shareMeme(sender: AnyObject) {
        
        // Generate a memed image
        let image = self.generateMemedImage()
        
        // Define an instance of the ActivityViewController and pass the ActivityViewController a memedImage as an activity item
        let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        
        // Present the ActivityViewController
        self.presentViewController(activityViewController, animated: true,
            completion: nil)
        
        // Control flow when the activity controller exits
        activityViewController.completionWithItemsHandler = {
            
            // Save the meme just before dismissing the activity view
            (s: String?, ok: Bool, items: [AnyObject]?, err:NSError?) -> Void in
            
            // Save the meme only if a valid action is selected, do not save if the user selects the Cancel option
            if ok {
                self.saveMeme()
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            
            // Go to the Sent Meme View options with modal presentation
            NSOperationQueue.mainQueue().addOperationWithBlock {
                let storyboard = UIStoryboard (name: "Main", bundle: nil)
                let nextVC = storyboard.instantiateViewControllerWithIdentifier("MemeTable") as! MemeTable
                self.presentViewController(nextVC, animated: true, completion: nil)
            }
        }
    }
    
    /// Dismiss the editor in order to get back to the sent memes being the presenting view controller
    @IBAction func exitEditor(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Image Capture Methods
    
    func generateMemedImage() -> UIImage {
        
        // Hide the toolbars
        self.topToolBar.hidden = true
        self.toolBar.hidden = true
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        self.view.drawViewHierarchyInRect(self.view.frame, afterScreenUpdates: true)
        let memedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Show the toolbars
        self.topToolBar.hidden = false
        self.toolBar.hidden = false
        
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
            let object = UIApplication.sharedApplication().delegate
            let appDelegate = object as! AppDelegate
            appDelegate.memes.append(meme)
        }
    }
    
    // MARK: - Keyboard Methods
    
    func keyboardWillShow(notification: NSNotification) {
        
        // Reset the view to it's original position every time the keyboard is about to show to counter for different keyboard heights (ie when changing language or emoticons) during the same runtime
        self.view.frame.origin.y = 0.0
        
        // Move the keyboard out of the way
        self.view.frame.origin.y -= getKeyboardHeight(notification)
    }
    
    /// Reset the frame to its original position
    func keyboardWillHide(notification: NSNotification) {
        self.view.frame.origin.y = 0.0
    }
    
    /// Get keyboard height from the notification service
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
    
    // MARK: - Notification subscriptions
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(MemeEditor.keyboardWillShow(_:)),
            name: UIKeyboardWillShowNotification,
            object:nil
        )
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(MemeEditor.keyboardWillHide(_:)),
            name: UIKeyboardWillHideNotification,
            object:nil
        )
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
}

extension MemeEditor: UIImagePickerControllerDelegate {
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            
            // Force the text to be on the image by using aspect fill
            self.ImagePickerView.contentMode = .ScaleAspectFill
            self.ImagePickerView.image = image
            
            // Enable the share button
            shareButton.enabled = true
            
            // Enable the text fields
            topText.enabled = true
            bottomText.enabled = true
        }
        
        // Opt to dismiss the picker
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        
        // Opt to dismiss the picker
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension MemeEditor: UITextFieldDelegate {

    /// In this delegate the keyboard subscriptions are integrated. They are intended to be used only from the bottomText which requires the view to move when the keyboard is about to show
    func textFieldDidBeginEditing(textField: UITextField) {
        
        // Enable the view to raise only for the bottom text field
        self.subscribeToKeyboardNotifications()
        
        // Removing default text only, not user text
        textField.text = ""
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        // Hides the keyboard
        textField.resignFirstResponder()
        
        // Disable the view raise for other text fields
        self.unsubscribeFromKeyboardNotifications()
        return true
    }
    
}
