//
//  OnlineUsersTableViewController.swift
//  FirebaseChat
//
//  Created by Safina Lifa on 8/12/16.
//  Copyright © 2016 Safina Lifa. All rights reserved.
//
import UIKit
import Firebase

class OnlineUsersTableViewController: UITableViewController {
    let ref = Firebase(url: "https://chatchatl.firebaseio.com/")
    let usersRef = Firebase(url: "https://chatchatl.firebaseio.com/online")
    var user: User!
    var currentUsers: [String] = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    ref.observeAuthEventWithBlock { authData in
            if authData != nil {
                self.user = User(authData: authData)
                // 1
                let currentUserRef = self.usersRef.childByAppendingPath(self.user.uid)
                // 2
                currentUserRef.setValue(self.user.email)
                // 3
                currentUserRef.onDisconnectRemoveValue()
            }
        }
        
       
        usersRef.observeEventType(.ChildAdded, withBlock: { (snap: FDataSnapshot!) in
            
            // Add the new user to the local array
            self.currentUsers.append(snap.value as! String)
            
            // Get the index of the current row
            let row = self.currentUsers.count - 1
            
            // Create an NSIndexPath for the row
            let indexPath = NSIndexPath(forRow: row, inSection: 0)
            
            // Insert the row for the table with an animation
            self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Top)
            
        })
        
        // Create a listener for the delta deletions to animate removes from the table view
        usersRef.observeEventType(.ChildRemoved, withBlock: { (snap: FDataSnapshot!) -> Void in
            
            // Get the email to find
            let emailToFind: String! = snap.value as! String
            
            // Loop to find the email in the array
           for(index, email) in self.currentUsers.enumerate() {
                
                // If the email is found, delete it from the table with an animation
                if email == emailToFind {
                    let indexPath = NSIndexPath(forRow: index, inSection: 0)
                    self.currentUsers.removeAtIndex(index)
                    self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                }
                
            }
            
        })
        
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentUsers.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell")!
        let onlineUserEmail = currentUsers[indexPath.row]
        cell.textLabel?.text = onlineUserEmail
        let image : UIImage = UIImage(named: "online.png")!
        print("The loaded image: \(image)")
        cell.imageView!.image = image
        return cell
    }
    
    
    
}