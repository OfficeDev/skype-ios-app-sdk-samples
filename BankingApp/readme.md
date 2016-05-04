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

5. Change the project **Bundle Identifier**. In the Project Navigator select your project. In the Editor pane, go to General tab -> Change Bundle Identifier under Identity section. 

6. Edit Info.plist and replace value of __Skype meeting URL__ and __Skype meeting display name__ with a [**meeting URL**](https://msdn.microsoft.com/en-us/skype/appsdk/getmeetingurl) and any desired name respectively.

## Sample app walkthrough

Here's how the sample app works:

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
AV conversation takes advantage of a convinient helper class included in the SDK.
In **SfBConversation.h** and **.m**, using initializer sets up everything needed in the AV conversation.

For details on how it was used, see **VideoViewController.m**.
 
### Handling Chat conversation
Chat feature handling is done in **ChatHandler.m**. This is a convinence class much like the SfBConversationHelper that handles only the text chat functionality.

For details on how the above class was used, see **ChatViewController.m**. 

### Leaving a conversation
In order to leave the conversaion, __canLeave__ property of SfBConversation must be checked. In this case, it is monitored through Key-Value Observation in **VideoViewController.m** and **ChatViewController.m**.
```objective-c
...
[conversation addObserver:self forKeyPath:@"canLeave" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:nil];
...     

```

