//
//  TopTextDelegate.swift
//  meme
//
//  Created by Ioannis Tornazakis on 23/3/15.
//  Copyright (c) 2015 polarbear.gr. All rights reserved.
//

import Foundation
import UIKit

/// This delegate is used from the topText. Its intended use is to do the text operations without moving the view while the keyboard shows up, as is the case for the bottomText
class TopTextFieldDelegate: NSObject, UITextFieldDelegate {
    
    /// Removing default text
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
    }
    
    /// Hides the keyboard uppon return
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
