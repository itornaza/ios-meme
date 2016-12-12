//
//  MemeCollection.swift
//  meme
//
//  Created by Ioannis Tornazakis on 24/3/15.
//  Copyright (c) 2015 polarbear.gr. All rights reserved.
//

import Foundation
import UIKit

class MemeCollection: UICollectionViewController {
    
    // MARK: - Properties
    
    var memes: [Meme]!
    
    // MARK: - Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Reload the data here in order to fix the bug that caused only the first meme to appear on the collection view
        collectionView?.reloadData()
        
        // Get the meme data from the AppDelegate
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        memes = appDelegate.memes
    }
    
    // MARK: - Actions
    
    /// Modally present the Meme editor
    @IBAction func switchToEditMode(_ sender: AnyObject) {
        OperationQueue.main.addOperation {
            let storyboard = UIStoryboard (name: "Main", bundle: nil)
            let nextVC = storyboard.instantiateViewController(withIdentifier: "MemeEditor") as! MemeEditor
            self.present(nextVC, animated: true, completion: nil)
        }
    }
    
    // MARK: - Collection View Delegate
    
    /// Items count
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.memes.count
    }
    
    /// Cell at index path
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) ->
        UICollectionViewCell {
        
        // 1. Dequeue a reusable cell from the table, using the correct “reuse identifier”
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MemeCollectionCell", for: indexPath)
            as! MemeCollectionCell
        
        // 2. Find the model object that corresponds to that item
        let meme = self.memes[(indexPath as NSIndexPath).item]
        
        // 3. Set the image in the cell with the data from the model object
        cell.memeImageView?.image = meme.memedImage
        
        // 4. return the cell
        return cell
    }
    
    /// Detail view
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath:IndexPath) {
        OperationQueue.main.addOperation {
            // Grab the detail controller from the storyboard
            let detailController = self.storyboard!.instantiateViewController(withIdentifier: "MemeDetails") as! MemeDetails
            // Assign the respective meme at index
            detailController.meme = self.memes[(indexPath as NSIndexPath).item]
            // Go to the details view
            self.navigationController?.pushViewController(detailController, animated: true)
        }
    }
}
