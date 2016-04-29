# Banking App for iOS

This sample app illustrates how to integrate Skype for Business to an iOS application to do a anonymous meeting join with text chat and audio/video conversations.

# How to run this app

Open the BankingApp.xcodeproj and embed the Skype for Business SDK framework and SfBConversationHelper from the SDK download.
Please read [Use the SDK to join a meeting with an iOS device](HowToJoinMeeting.md) for more details. 

To join the conversation, check Info.plist and replace value of __Skype meeting URL__ and __Skype meeting display name__.

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

