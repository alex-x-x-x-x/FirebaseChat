//
//  ResetPassword.swift
//  FirebaseChat
//
//  Created by Safina Lifa on 8/12/16.
//  Copyright © 2016 Safina Lifa. All rights reserved.
//

import UIKit
import Firebase 

class ResetPassword: UIViewController {
    
    let ref = Firebase(url: "https://chatchatl.firebaseio.com")

    @IBOutlet weak var resetPasswordForUser: UITextField!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ResetPassword.dismissKeyboard))
        view.addGestureRecognizer(tap)
        let swipeRec = UISwipeGestureRecognizer()
   
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    @IBAction func resetPassword(sender: AnyObject) {
        ref.resetPasswordForUser(resetPasswordForUser.text,  withCompletionBlock: { error in
            if error != nil {
                // There was an error processing the request
                print("Error processing request")
                let alertController = UIAlertController(
                    title: "Hey user!",
                    message: "There seems to be a problem with your e-mail address, make sure you typed it up correctly!",
                    preferredStyle: UIAlertControllerStyle.Alert
                )
                
                let cancelAction = UIAlertAction(
                    title: "Cancel",
                style: UIAlertActionStyle.Destructive) { (action) in
                    // ...
                }
                
                let confirmAction = UIAlertAction(
                title: "OK", style: UIAlertActionStyle.Default) { (action) in
                    // ...
                }
                
                alertController.addAction(confirmAction)
                alertController.addAction(cancelAction)
                
                self.presentViewController(alertController, animated: true, completion: nil)
            } else {
                // Password reset sent successfully
                print("Success!")
                // UIAlertController
                let alertController = UIAlertController(
                    title: "Hey user!",
                    message: "Your password has been reset! Check your email!",
                    preferredStyle: UIAlertControllerStyle.Alert
                )
                
                let cancelAction = UIAlertAction(
                    title: "Cancel",
                style: UIAlertActionStyle.Destructive) { (action) in
                    // ...
                }
                
                let confirmAction = UIAlertAction(
                    title: "OK", style: UIAlertActionStyle.Default, handler: {
                        (action) in self.performSegueWithIdentifier("reset", sender: self)
                })
                
                alertController.addAction(confirmAction)
                alertController.addAction(cancelAction)
                
                self.presentViewController(alertController, animated: true, completion: nil)
            }
            
                 

        })

    }
}