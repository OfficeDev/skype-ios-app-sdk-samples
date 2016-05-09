# Banking App for iOS

This sample app illustrates how to integrate Skype for Business text chat, audio and video into an iOS application, via "guest meeting join".
##Prerequisites

1. Download the [**Skype for Business App SDK for iOS**](https://www.microsoft.com/en-us/download/confirmation.aspx?id=51962). 

2. Obtain a [**meeting URL**](https://msdn.microsoft.com/en-us/skype/appsdk/getmeetingurl) for a Skype Business meeting.

##How to get started

1. Clone or copy the sample Banking App to your local machine.

2. Copy SkypeForBusiness.framework from the SkypeForBusinessAppSDKiOS folder in the SDK download into the sample app folder. 

   > **Note**: The SDK comes with a SkypeForBusiness.framework for use on physical devices (recommended) and a SkypeForBusiness.framework for running the iOS simulator (limited because audio and video function won't work correctly). The binaries have the same name but are in separate folders. To run your app on a device, navigate to the location where you downloaded the App SDK and select the SkypeForBusiness.framework file in the AppSDKiOS folder. To run your app in a simulator, selec the SkypeForBusiness.framework file in the AppSDKiOSSimulator folder.

3. In the Project Navigator, select your project. In the Editor pane, go to General tab -> Open Embedded Binaries.  Click the + button to add a new framework. Click Add Other to navigate to where you just copied the SkypeforBusiness.framework.

   > **Note**: Add SkypeForBusiness.framework as an "Embedded Binary" (not a "Linked Framework").

4. The sample app uses the SDK's "conversation helper" class that simplifies interaction with the core APIs in mainline scenarios. Copy SfBConversationHelper.h and SfBConversationHelper.m files from the Helpers folder in the SDK download into the sample app's source code.  Add these copied files to your project.

5. Edit Info.plist and replace value of __Skype meeting URL__ and __Skype meeting display name__ with a [**meeting URL**](https://msdn.microsoft.com/en-us/skype/appsdk/getmeetingurl) and any desired name respectively.

## Sample app walkthrough

Here's how the sample app works:

###Login Screen

This is a pseudo login screen and does not require email and password to sign in. Simply press **"Sign in"** button to login.

 > **Note**: Before signing in, make sure that you edit Info.plist and replace value of __Skype meeting URL__ and __Skype meeting display name__ with a valid "Meeting URL" and any desired name respectively. 

### Main Screen

Once you sign in, You enter the Main screen where you can view pseudo bank account details and can contact the bank agent via text or video call.

- Main Screen shows:
 - The "Ask Agent" button that connects you to banking agent via text or video call.
 - The "Log off" button to log out of the sample.
 
### Chat Screen
 
Press "Ask Agent" button -> select "Ask using Text Chat" from options menu to start text Chat with the bank agent. You will be notified once the agent is available for chat. Press "End" button to exit the chat.

### Video Chat Screen:
 
 Press "Ask Agent" button -> select "Ask using Video Chat" from options menu to start Video Chat with the agent. You will be notified once you are connected to the agent. This screen will show your live video stream  and bank agent.
 
 - You can
  - Press "End" button to exit the chat. 
  - Use Mute/unMute toggle button to handle outgoing audio.
  
  > Note: You can join the meeting as a bank agent by using the Skype for Business application installed on your desktop or mobile device. Please use the same [**meeting URL**](https://msdn.microsoft.com/en-us/skype/appsdk/getmeetingurl) as above.
 
## Sample code walkthrough

Here's how the sample source code works:

### Initializing Skype for Business
In **MainViewController.m**, initialization of Skype is done.
```objective-c
- (void)initializeSkype {
    SfBApplication *sfb = SfBApplication.sharedApplication;
    sfb.configurationManager.maxVideoChannels = 1;
    sfb.devicesManager.selectedSpeaker.activeEndpoint = SfBSpeakerEndpointLoudspeaker;   
}
```

### Handling Audio/Video conversation  
AV conversation takes advantage of a convenient helper class included in the SDK.
In **SfBConversation.h** and **.m**, using initializer sets up everything needed in the AV conversation.

For details on how it was used, see **VideoViewController.m**.
 
### Handling Chat conversation
Chat feature handling is done in **ChatHandler.m**. This is a convinence class much like the SfBConversationHelper that handles only the text chat functionality.

For details on how the above class was used, see **ChatViewController.m**. 

### Leaving a conversation
In order to leave the conversaion, __canLeave__ property of SfBConversation must be checked. In this case, it is monitored through Key-Value Observation in **VideoViewController.m** and **ChatViewController.m**.

```objective-c
[conversation addObserver:self forKeyPath:@"canLeave" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:nil];
```

