//
//  MemeCollection.swift
//  meme
//
//  Created by Ioannis Tornazakis on 24/3/15.
//  Copyright (c) 2015 polarbear.gr. All rights reserved.
//

import Foundation
import UIKit

class MemeCollection: UICollectionViewController, UICollectionViewDataSource {
    
    // MARK: Model
    
    var memes: [Meme]!
    
    // MARK: Life cycle
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Reload the data here in order to fix the bug that caused only the first
        // meme to appear on the collection view
        collectionView?.reloadData()
        
        // Get the meme data from the AppDelegate
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as AppDelegate
        memes = appDelegate.memes
        
        //==> Console info
        println("-> Enter collection view with #memes = \(memes.count)")
    }
    
    override func viewWillDisappear(animated: Bool) {
        //==> Console info
        println("-> Exit collection view")
    }
    
    deinit {
        //==> Console info
        println("-> Deconstruct collection view")
    }
    
    // MARK: Actions
    
    @IBAction func switchToEditMode(sender: AnyObject) {
        // Modally present the Meme editor:
        // Grab the storyboard
        var storyboard = UIStoryboard (name: "Main", bundle: nil)
        // Get the destination view controller from the storyboard id
        var nextVC = storyboard.instantiateViewControllerWithIdentifier("MemeEditor") as MemeEditor
        // Go to the editor controller
        self.presentViewController(nextVC, animated: true, completion: nil)
    }
    
    // MARK: Collection View Data Source
    
    /**
        Items count
    */
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.memes.count
    }
    
    /**
        Cell at index path
    */
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        //==> Console info
        println("--> IndexPath item: \(indexPath.item)" )
        
        // 1. Dequeue a reusable cell from the table, using the correct “reuse identifier”
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MemeCollectionCell", forIndexPath: indexPath)
            as MemeCollectionCell
        
        // 2. Find the model object that corresponds to that item
        let meme = self.memes[indexPath.item]
        
        // 3. Set the image in the cell with the data from the model object
        cell.memeImageView?.image = meme.memedImage
        
        // 4. return the cell
        return cell
    }
    
    /**
        Detail view
    */
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath:NSIndexPath) {
        // Grab the detail controller from the storyboard
        let detailController = self.storyboard!.instantiateViewControllerWithIdentifier("MemeDetails")! as MemeDetails
        // Assign the respective meme at index
        detailController.meme = self.memes[indexPath.item]
        // Go to the details view
        self.navigationController?.pushViewController(detailController, animated: true)
    }
    
}
