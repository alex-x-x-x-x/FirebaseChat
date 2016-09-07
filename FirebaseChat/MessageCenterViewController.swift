//
//  MessageCenterViewController.swift
//  FirebaseChat
//
//  Created by Safina Lifa on 8/11/16.
//  Copyright © 2016 Safina Lifa. All rights reserved.
//
import UIKit
import JSQMessagesViewController
import Firebase

class MessageCenterViewController:  JSQMessagesViewController {
    
    let userRef = Firebase(url: "https://chatchatl.firebaseio.com/online")
    let rootRef = Firebase(url: "https://chatchatl.firebaseio.com/")
    let defaults = NSUserDefaults.standardUserDefaults()
   
    
    var messageRef: Firebase!
    var messages = [JSQMessage]()
    var avatars = [String: JSQMessagesAvatarImage]()
 
    
    var incomingBubbleImageView: JSQMessagesBubbleImage!
    var outgoingBubbleImageView: JSQMessagesBubbleImage!
    
    var usersTypingQuery: FQuery!
    
    @IBOutlet var MessageView: UIView!
    @IBOutlet weak var leftBarButtonItem: UINavigationItem!
    
    var userIsTypingRef: Firebase!
    private var localTyping = false
    var isTyping: Bool {
        get {
            return localTyping
        }
        set {
            localTyping = newValue
            userIsTypingRef.setValue(newValue)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // UUIDString
        self.senderId = UIDevice.currentDevice().identifierForVendor?.UUIDString
        self.senderDisplayName = UIDevice.currentDevice().identifierForVendor?.UUIDString
        // Avatar
        collectionView.collectionViewLayout.outgoingAvatarViewSize = .zero
        collectionView.collectionViewLayout.incomingAvatarViewSize = .zero
        // leftBarButtonItem
        self.inputToolbar.contentView.leftBarButtonItem = nil
        
        messageRef = rootRef.childByAppendingPath("messages")
        collectionView.collectionViewLayout.springinessEnabled = true
        automaticallyScrollsToMostRecentMessage = true
        // Toolbar UI
        self.inputToolbar?.barStyle = .BlackTranslucent
        self.inputToolbar?.contentView?.textView?.keyboardAppearance = .Dark
        //self.collectionView?.backgroundColor = UIColor.lightGrayColor()
        self.collectionView?.layoutIfNeeded()
        self.collectionView?.reloadData()
       
        setupBubbles()
        observeMessages()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        collectionView.collectionViewLayout.springinessEnabled = true
        automaticallyScrollsToMostRecentMessage = true
  
          
        self.collectionView?.layoutIfNeeded()
        
        observeTyping()
       
    }
    
    private func setupBubbles() {
        let factory = JSQMessagesBubbleImageFactory()
        
        outgoingBubbleImageView = factory.outgoingMessagesBubbleImageWithColor(UIColor(red: 0.498, green: 0.0863, blue: 0.2784, alpha: 1.0))
        incomingBubbleImageView = factory.incomingMessagesBubbleImageWithColor(UIColor(red: 0.7373, green: 0.1294, blue: 0.2941, alpha: 1.0))
    }
   
    
    
    func addMessage(id: String, text: String) {
        let message = JSQMessage(senderId: id, displayName: "", text: text)
        messages.append(message)
        
    }
    
    func reloadMessagesView() {
        self.collectionView?.reloadData()
    }
    
    
    private func observeMessages() {
        let messagesQuery = messageRef.queryLimitedToLast(25)
        messagesQuery.observeEventType(.ChildAdded) { (snapshot: FDataSnapshot!) in
            
            let id = snapshot.value["senderId"] as! String
            let text = snapshot.value["text"] as! String
            
            self.addMessage(id, text: text)
          
            self.finishReceivingMessage()
        JSQSystemSoundPlayer.jsq_playMessageReceivedAlert()
    }
        // Enable local notifications for receiving messages
        let notification = UILocalNotification()
        notification.alertBody = "New Message"
        notification.alertAction = "Be Awesome"
        notification.soundName = UILocalNotificationDefaultSoundName
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
}
    override func textViewDidChange(textView: UITextView) {
        super.textViewDidChange(textView)
        // If the text is not empty, the user is typing
        print(textView.text != "")
        isTyping = textView.text != ""
    }
    
    private func observeTyping() {
        let typingIndicatorRef = rootRef.childByAppendingPath("typingIndicator")
        userIsTypingRef = typingIndicatorRef.childByAppendingPath(senderId)
        userIsTypingRef.onDisconnectRemoveValue()
        
        usersTypingQuery = typingIndicatorRef.queryOrderedByValue().queryEqualToValue(true)
        
        usersTypingQuery.observeEventType(.Value) { (data: FDataSnapshot!) in
            
            if data.childrenCount == 1 && self.isTyping {
                return
            }
            
            self.showTypingIndicator = data.childrenCount > 0
            self.scrollToBottomAnimated(true)
        }
    }
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        
        let itemRef = messageRef.childByAutoId()
        let messageItem = [
            "text": text,
            "senderId": senderId
        ]
        itemRef.setValue(messageItem)
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        finishSendingMessage()
        isTyping = false
    }
    
    override func didPressAccessoryButton(sender: UIButton!) {
       // Leave empty
        
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {


        return messages.count
        
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        
       
       return self.messages[indexPath.item]
        
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didDeleteMessageAtIndexPath indexPath: NSIndexPath!) {
        self.messages.removeAtIndex(indexPath.row)
    }

    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        
        let data = messages[indexPath.row]
        switch(data.senderId) {
        case self.senderId:
            return self.outgoingBubbleImageView
        default:
            return self.incomingBubbleImageView
            
        }
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        
        let message = messages[indexPath.row]
        
        if message.senderId == senderId {
            cell.textView!.textColor = UIColor.whiteColor()
        } else {
            cell.textView!.textColor = UIColor.whiteColor()
        }
        
        return cell
    }
    
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath) -> JSQMessageAvatarImageDataSource! {
        
        let message = messages[indexPath.row]
        return avatars[message.senderId]
    }
    

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}