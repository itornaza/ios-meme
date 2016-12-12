//
//  MemeTable.swift
//  meme
//
//  Created by Ioannis Tornazakis on 24/3/15.
//  Copyright (c) 2015 polarbear.gr. All rights reserved.
//

import Foundation
import UIKit

class MemeTable: UITableViewController {
    
    // MARK: - Model
    
    var memes: [Meme]!
    
    // MARK: - Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Get the meme data from the AppDelegate
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        memes = appDelegate.memes
        
        // If there are no images, goto the Edit Memes without implying any animation
        if (memes.count == 0) {
            self.switchToEditMode(false)
        } else {
            tableView.reloadData()
        }
    }
    
    // MARK: - Actions
    
    /// Modally present the Meme editor
    @IBAction func EditMeme(_ sender: AnyObject) {
        self.switchToEditMode(true)
    }
    
    // MARK: - Table View Delegate
    
    /// Number of rows
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.memes.count
    }
    
    /// Cell for row at index path
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // 1. Dequeue a reusable cell from the table, using the correct “reuse identifier”
        let cell = tableView.dequeueReusableCell(withIdentifier: "memeCell")! as UITableViewCell
        
        // 2. Find the model object that corresponds to that row
        let sentMemeForRow = self.memes[(indexPath as NSIndexPath).row]

        // 3. Set the images and labels in the cell with the data from the model object
        cell.textLabel?.text = sentMemeForRow.topText + "..." + sentMemeForRow.bottomText
        cell.imageView?.image = sentMemeForRow.memedImage
        
        // 4. return the cell
        return cell
    }

    /// Detail view
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailController = self.storyboard!.instantiateViewController(withIdentifier: "MemeDetails") as! MemeDetails
        detailController.meme = self.memes[(indexPath as NSIndexPath).row]
        self.navigationController?.pushViewController(detailController, animated: true)
    }
    
    // MARK: - Segues
    
    func switchToEditMode(_ animation: Bool) {
        OperationQueue.main.addOperation {
            let storyboard = UIStoryboard (name: "Main", bundle: nil)
            let nextVC = storyboard.instantiateViewController(withIdentifier: "MemeEditor") as! MemeEditor
            self.present(nextVC, animated: animation, completion: nil)
        }
    }

}
