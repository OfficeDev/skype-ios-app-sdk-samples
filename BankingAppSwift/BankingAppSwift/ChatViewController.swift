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
        NotificationCenter.default.removeObserver(self)
        
        }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.setHidesBackButton(true, animated: true)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
    }
    
    //MARK: Keyboard Handling
    
    func registerForNotifications() {

        
       NotificationCenter.default.addObserver(self, selector:#selector(ChatViewController.leaveMeetingWhenAppTerminates(_:)), name:NSNotification.Name.UIApplicationWillTerminate, object:nil)
        

        NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.keyboardWillBeHidden(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func leaveMeetingWhenAppTerminates(_ aNotification:Notification) {
        if let conversation = self.chatHandler?.conversation{
            leaveMeetingWithSuccess(conversation)
        }
    }

    
    func keyboardWillShow(_ aNotification:Notification) {
        
        let info:NSDictionary = aNotification.userInfo! as NSDictionary
        let keyboardFrame: CGRect = ((info[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue)!
        self.spaceConstraint.constant = keyboardFrame.size.height
        self.view.layoutIfNeeded()
        // To scroll table up
        //let newOffSet: CGPoint = CGPointMake(0, (self.chatTableViewController?.tableView.contentOffset.y)! + keyboardFrame.size.height)
        // self.chatTableViewController?.tableView.setContentOffset(newOffSet, animated: true)
        
    }
    
    func keyboardWillBeHidden(_ aNotification:Notification) {
        self.spaceConstraint.constant = 0
        self.view.layoutIfNeeded()
    }
    
    //MARK: - Button actions
    
    @IBAction func sendMessage(_ sender: AnyObject) {
        self.messageTextField.resignFirstResponder()
        self.sendChatMessage(self.messageTextField.text!)
    }
    
    @IBAction func endChat(_ sender: AnyObject) {
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
        if(viewController.isKind(of: OnlineMainViewController.self)){
            presentedFromOnlineMeetingViewController = true
            self.navigationController?.popToViewController(viewController, animated: true)
        break;
        }
       }
        if(!presentedFromOnlineMeetingViewController){
            self.navigationController?.popViewController(animated: true)
        }
        
      
    }

    
    func sendChatMessage(_ message: String) {
        var error: NSError? = nil
        if let chatHandler = self.chatHandler{
            chatHandler.sendMessage(message, error: &error)
            if (error != nil) {
                self.navigationController!.popViewController(animated: true)
            }
            else {
                self.messageTextField.text = ""
                self.chatTableViewController?.addMessage(message, from: (chatHandler.userInfo as! Dictionary)[DisplayNameInfo]!, origin: .mySelf)
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
        
        
        conversation!.addObserver(self, forKeyPath: "canLeave", options: [.initial, .new] , context: nil)
        
    }
    func didReceive(_ alert: SfBAlert){
        
        alert.showSfBAlertInController(self)
    }
    
    
    //MARK - Skype ChatHandlerDelegate Functions
    
    // Notify the user when connection is established and message can be sent.
    func chatHandler(_ chatHandler: ChatHandler, chatService: SfBChatService, didChangeCanSendMessage canSendMessage: Bool) {
        if (canSendMessage) {
            self.sendButton.isEnabled = true
            self.sendButton.alpha = 1
            self.chatTableViewController?.addStatus("now you can send a message")
        }
        else{
            self.sendButton.isEnabled = false
        }
    }
    
    //Handle message received from other meeting participant.
    func chatHandler(_ chatHandler: ChatHandler, didReceiveMessage message: SfBMessageActivityItem) {
        self.chatTableViewController?.addMessage(message.text,
                                                 from: (message.sender?.displayName)!, origin:.participant)
    }
    
    
    
    //MARK: -  Additional KVO
    
    // Monitor canLeave property of a conversation to prevent leaving prematurely
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if (keyPath == "canLeave") {
            self.endButton.isEnabled = (self.chatHandler?.conversation.canLeave)!
        }
    }
    
    //MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "chatTable") {
            self.chatTableViewController = segue.destination as? ChatTableViewController
        }
    }
    
    //MARK: - Helper UI
    
    func handleError(_ readableErrorDescription:String)  {
        let alertController:UIAlertController = UIAlertController(title: "ERROR!", message: readableErrorDescription, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
        present(alertController, animated: true, completion:nil)
    }
    
    
    
}
