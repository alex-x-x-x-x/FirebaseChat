//
//  ViewController.swift
//  FirebaseChat
//
//  Created by Safina Lifa on 8/11/16.
//  Copyright © 2016 Safina Lifa. All rights reserved.
//

import UIKit
import Firebase
import AVFoundation



class LoginViewController: UIViewController {
    
    
    let ref = Firebase(url: "https://chatchatl.firebaseio.com")
    
    @IBOutlet weak var textFieldLoginEmail: UITextField!
    
    @IBOutlet weak var textFieldLoginPassword: UITextField!
    
    var player: AVPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        let path = NSBundle.mainBundle().pathForResource("Street-View", ofType: "mp4")
        player = AVPlayer(URL: NSURL(fileURLWithPath: path!))
        player!.actionAtItemEnd = AVPlayerActionAtItemEnd.None;
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.view.frame
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        self.view.layer.insertSublayer(playerLayer, atIndex: 0)
         NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginViewController.continueVideo(_:)), name: "continueVideo", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginViewController.playerItemDidReachEnd), name: AVPlayerItemDidPlayToEndTimeNotification, object: player!.currentItem)
        player!.seekToTime(kCMTimeZero)
        player!.play()
        
        
        // Set vertical effect
        let verticalMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.y", type: .TiltAlongVerticalAxis)
        verticalMotionEffect.minimumRelativeValue = -10
        verticalMotionEffect.maximumRelativeValue = 10
        
        // Set horizontal effect
        let horizontalMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.x", type: .TiltAlongHorizontalAxis)
        horizontalMotionEffect.minimumRelativeValue = -10
        horizontalMotionEffect.maximumRelativeValue = 10
        
        // Create group to combine both
        let group = UIMotionEffectGroup()
        group.motionEffects = [horizontalMotionEffect, verticalMotionEffect]
        
        // Add both effects to your view
        self.view.addMotionEffect(group)
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func playerItemDidReachEnd() {
        player!.seekToTime(kCMTimeZero)
        player!.play()
    }
    
    func continueVideo(notification: NSNotification) {
        player!.play()
    }
    
    func applicationWillResignActive(application: UIApplication) {
        player!.pause()
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        player!.play()
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        player!.pause()
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        player!.play() 
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    @IBAction func loginDidTouch(sender: AnyObject) {
        let email = textFieldLoginEmail.text
        let password = textFieldLoginPassword.text
        
        ref.authUser(email, password: password, withCompletionBlock: { error, authData in
            
            if error != nil {
                print("Can't log in!")
            // There was an error logging in to this account!
                let alertController = UIAlertController(
                    title: "Hey user!",
                    message: "There seems to be a problem with your password or e-mail address. Try again!",
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
                print("Successful login!")
            self.performSegueWithIdentifier("LoginToChat", sender: nil)
            }
        })
    }
}