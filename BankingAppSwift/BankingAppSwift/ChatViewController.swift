//+----------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Module name: ChatViewController.swift
//----------------------------------------------------------------


import UIKit


class ChatViewController: UIViewController,ChatHandlerDelegate ,SfBAlertDelegate{
    let DisplayNameInfo: String = "displayName"
    
      var conversation:SfBConversation?
    
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var endButton: UIBarButtonItem!
    @IBOutlet weak var spaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var messageTextField: UITextField!
    
    var chatTableViewController:ChatTableViewController? = nil
    var chatHandler:ChatHandler? = nil
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.registerForNotifications()
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.joinMeeting()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
        
        }

    override func viewWillAppear(animated: Bool) {
        self.navigationItem.setHidesBackButton(true, animated: true)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
    }
    
    //MARK: Keyboard Handling
    
    func registerForNotifications() {

        
       NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(ChatViewController.leaveMeetingWhenAppTerminates(_:)), name:UIApplicationWillTerminateNotification, object:nil)
        

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChatViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChatViewController.keyboardWillBeHidden(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func leaveMeetingWhenAppTerminates(aNotification:NSNotification) {
        if let conversation = self.chatHandler?.conversation{
            leaveMeetingWithSuccess(conversation)
        }
    }

    
    func keyboardWillShow(aNotification:NSNotification) {
        
        let info:NSDictionary = aNotification.userInfo!
        let keyboardFrame: CGRect = ((info[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue())!
        self.spaceConstraint.constant = keyboardFrame.size.height
        self.view.layoutIfNeeded()
        // To scroll table up
        //let newOffSet: CGPoint = CGPointMake(0, (self.chatTableViewController?.tableView.contentOffset.y)! + keyboardFrame.size.height)
        // self.chatTableViewController?.tableView.setContentOffset(newOffSet, animated: true)
        
    }
    
    func keyboardWillBeHidden(aNotification:NSNotification) {
        self.spaceConstraint.constant = 0
        self.view.layoutIfNeeded()
    }
    
    //MARK: - Button actions
    
    @IBAction func sendMessage(sender: AnyObject) {
        self.messageTextField.resignFirstResponder()
        self.sendChatMessage(self.messageTextField.text!)
    }
    
    @IBAction func endChat(sender: AnyObject) {
        self.endMeeting()
    }
    
   
    func endMeeting() {
        if let conversation = self.chatHandler?.conversation{
            if(!leaveMeetingWithSuccess(conversation)){
                
           
                showErrorAlert("Could Not Leave Meeting", viewController: self)
               
            }
            self.chatHandler?.conversation.removeObserver(self, forKeyPath: "canLeave")

        }
        var presentedFromOnlineMeetingViewController = false
        let allViewControllers = self.navigationController?.viewControllers
        for viewController in allViewControllers!{
        if(viewController.isKindOfClass(OnlineMainViewController)){
            presentedFromOnlineMeetingViewController = true
            self.navigationController?.popToViewController(viewController, animated: true)
        break;
        }
       }
        if(!presentedFromOnlineMeetingViewController){
            self.navigationController?.popViewControllerAnimated(true)
        }
        
      
    }

    
    func sendChatMessage(message: String) {
        var error: NSError? = nil
        if let chatHandler = self.chatHandler{
            chatHandler.sendMessage(message, error: &error)
            if (error != nil) {
                self.navigationController!.popViewControllerAnimated(true)
            }
            else {
                self.messageTextField.text = ""
                self.chatTableViewController?.addMessage(message, from: (chatHandler.userInfo as! Dictionary)[DisplayNameInfo]!, origin: .MySelf)
            }
        }
    }
    
    
    //MARK: Joins a Skype Meeting
    
    //Joins a Skype meeting.
    func joinMeeting() {
        

        conversation?.alertDelegate = self
        self.chatHandler = ChatHandler(conversation: self.conversation!,
                                       delegate: self,
                                       userInfo: [DisplayNameInfo:"Jake"])
        
        
        conversation!.addObserver(self, forKeyPath: "canLeave", options: [.Initial, .New] , context: nil)
        
    }
    func didReceiveAlert(alert: SfBAlert){
        
        alert.showSfBAlertInController(self)
    }
    
    
    //MARK - Skype ChatHandlerDelegate Functions
    
    // Notify the user when connection is established and message can be sent.
    func chatHandler(chatHandler: ChatHandler, chatService: SfBChatService, didChangeCanSendMessage canSendMessage: Bool) {
        if (canSendMessage) {
            self.sendButton.enabled = true
            self.sendButton.alpha = 1
            self.chatTableViewController?.addStatus("now you can send a message")
        }
        else{
            self.sendButton.enabled = false
        }
    }
    
    //Handle message received from other meeting participant.
    func chatHandler(chatHandler: ChatHandler, didReceiveMessage message: SfBMessageActivityItem) {
        self.chatTableViewController?.addMessage(message.text,
                                                 from: (message.sender?.displayName)!, origin:.Participant)
    }
    
    
    
    //MARK: -  Additional KVO
    
    // Monitor canLeave property of a conversation to prevent leaving prematurely
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if (keyPath == "canLeave") {
            self.endButton.enabled = (self.chatHandler?.conversation.canLeave)!
        }
    }
    
    //MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "chatTable") {
            self.chatTableViewController = segue.destinationViewController as? ChatTableViewController
        }
    }
    
    //MARK: - Helper UI
    
    func handleError(readableErrorDescription:String)  {
        let alertController:UIAlertController = UIAlertController(title: "ERROR!", message: readableErrorDescription, preferredStyle: .Alert)
        
        alertController.addAction(UIAlertAction(title: "Close", style: .Cancel, handler: nil))
        presentViewController(alertController, animated: true, completion:nil)
    }
    
    
    
}
