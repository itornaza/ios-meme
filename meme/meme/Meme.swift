//
//  Meme.swift
//  meme
//
//  Created by Ioannis Tornazakis on 12/3/15.
//  Copyright (c) 2015 polarbear.gr. All rights reserved.
//

import Foundation
import UIKit

/// Meme struct is used as the model of the app. It stores all neccessary data for the memes
struct Meme {
    
    // MARK: - Properties
    
    var topText: String!
    var bottomText: String!
    var originalImage: UIImage!
    var memedImage: UIImage!
    
    // MARK: - Constructors
    
    init(topText: String, bottomText: String, originalImage: UIImage, memedImage: UIImage) {
        self.topText = topText
        self.bottomText = bottomText
        self.originalImage = originalImage
        self.memedImage = memedImage
    }
}
