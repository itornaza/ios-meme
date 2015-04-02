//
//  TopTextDelegate.swift
//  meme
//
//  Created by Ioannis Tornazakis on 23/3/15.
//  Copyright (c) 2015 polarbear.gr. All rights reserved.
//

import Foundation
import UIKit

/**
    This delegate is used from the topText. Its intended use is to do the
    text operations without moving the view while the keyboard shows up, as
    is the case for the bottomText
*/
class TopTextFieldDelegate: NSObject, UITextFieldDelegate {
    
    func textFieldDidBeginEditing(textField: UITextField) {
        // Removing default text
        textField.text = ""
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // Hides the keyboard uppon return
        textField.resignFirstResponder()
        return true
    }
}
