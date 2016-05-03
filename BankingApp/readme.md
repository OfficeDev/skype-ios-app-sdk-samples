# Banking App for iOS

This sample app illustrates how to integrate Skype for Business to an iOS application to do a anonymous meeting join with text chat and audio/video conversations.

##Prerequisites

1. Download [**Skype for Business App SDK for iOS**](https://www.microsoft.com/en-us/download/confirmation.aspx?id=51962) 
2. Go through [**Use the SDK to Join a meeting with an iOS device**](https://msdn.microsoft.com/en-us/skype/appsdk/howtojoinmeeting_ios)

# How to run this app

1. Clone the sample Banking App in your local directory.
2. Copy SkypeForBusiness.framework from SkypeForBusinessAppSDKiOS folder and add to your sample application folder. 
3. In the Project Navigator select your project. -> In Editor, Go to Build Phases tab -> Open Embed Frameworks -> Click the + button to select the frameworks to add. -> Click Add Other to navigate to SkypeforBusiness.framework.
4. Drag and copy SfBConversationHelper.h and SfBConversationHelper.m to your Banking App project.
5. To join the conversation, check Info.plist and replace value of __Skype meeting URL__ and __Skype meeting display name__.

**Be Careful**: To run sample on simulator, Copy SkypeForBusiness.framework from **AppSDKiOSSimulator** folder and to run on actual device, copy from **AppSDKiOS** folder.

# Integrating Skype for Business

## Initializing Skype for Business
In **MainViewController.m**, initialization of Skype is done.
```objective-c
- (void)initializeSkype {
    SfBApplication *sfb = SfBApplication.sharedApplication;
    sfb.configurationManager.maxVideoChannels = 1;
    sfb.devicesManager.selectedSpeaker.activeEndpoint = SfBSpeakerEndpointLoudspeaker;   
}
```

## Handling Audio/Video conversation  
AV conversation takes advantage of a convinient helper class included in the SDK.
In **SfBConversation.h** and **.m**, using initializer sets up everything needed in the AV conversation.

For details on how it was used, see **VideoViewController.m**.
 
## Handling Chat conversation
Chat feature handling is done in **ChatHandler.m**. This is a convinence class much like the SfBConversationHelper that handles only the text chat functionality.

For details on how the above class was used, see **ChatViewController.m**. 

## Leaving a conversation
In order to leave the conversaion, __canLeave__ property of SfBConversation must be checked. In this case, it is monitored through Key-Value Observation in **VideoViewController.m** and **ChatViewController.m**.
```objective-c
...
[conversation addObserver:self forKeyPath:@"canLeave" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:nil];
...     

```

