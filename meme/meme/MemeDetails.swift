//
//  MemeDetails.swift
//  meme
//
//  Created by Ioannis Tornazakis on 24/3/15.
//  Copyright (c) 2015 polarbear.gr. All rights reserved.
//

import Foundation
import UIKit

class MemeDetails: UIViewController {
    
    // MARK: Model
    
    var meme: Meme!

    // MARK: Life cycle methods
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.imageView!.image = self.meme.memedImage
        
        //==> Console info
        println("--> Enter details view")
    }
    
    override func viewWillDisappear(animated: Bool) {
        //==> Console info
        println("--> Exit details view")
    }
    
    deinit {
        //==> Console info
        println("--> Deconstruct details view")
    }
    
    // MARK: Outlets
    
    @IBOutlet weak var imageView: UIImageView!
}