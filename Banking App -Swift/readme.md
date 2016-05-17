# Banking App for iOS (Swift)

This sample app illustrates how to integrate Skype for Business text chat, audio/video chat into an iOS application, via "Join Meeting Url".
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

5. Go to **"BankingAppSwift-Bridging-Header.h"** file in your source code and uncomment **#import "SfBConversationHelper.h"**

6. Edit Info.plist and replace value of __Skype meeting URL__ and __Skype meeting display name__ with a [**meeting URL**](https://msdn.microsoft.com/en-us/skype/appsdk/getmeetingurl) and any desired name respectively.

7. Build and run the app.

8. Press the **"Sign in"** button to login.  This is a pseudo login screen and does not require a real email and password. 

9. Once you sign in, you enter the main screen where you can view pseudo bank account details and can contact a "bank agent" via text or video call.

   > Note: To test the app, you need to join the meeting as a "bank agent" yourself by using the Skype for Business application installed on your desktop or mobile device. Join the same [**meeting URL**](https://msdn.microsoft.com/en-us/skype/appsdk/getmeetingurl) that you configured in the app above.

## Sample code walkthrough

Here's how the sample source code works:

### Initializing Skype for Business
In **MainViewController.swift**, initialization of Skype is done. Application level Skype configurations can be handeled here, e.g.  requireWifiForAudio, requireWifiForVideo, cameras list etc.
```swift
func initializeSkype(){
        let sfb:SfBApplication? = SfBApplication.sharedApplication()
        if let sfb = sfb{
            sfb.configurationManager.maxVideoChannels = 1
            sfb.devicesManager.selectedSpeaker.activeEndpoint = .Loudspeaker
        }
}
```

### Handling Audio/Video conversation  
AV conversation takes advantage of a convenient helper class included in the SDK.
In **SfBConversation.h** and **.m**, using initializer sets up everything needed in the AV conversation.

For details on how it was used, see **VideoViewController.swift**.
 
### Handling Chat conversation
Chat feature handling is done in **ChatHandler.swift**. This is a convinence class much like the SfBConversationHelper that handles only the text chat functionality.

For details on how the above class was used, see **ChatViewController.m**. 

### Leaving a conversation
In order to leave the conversaion, __canLeave__ property of SfBConversation must be checked. In this case, it is monitored through Key-Value Observation in **VideoViewController.swift** and **ChatViewController.swift**.

```swift
 conversation.addObserver(self, forKeyPath: "canLeave", options: [.Initial, .New] , context: nil)
```

