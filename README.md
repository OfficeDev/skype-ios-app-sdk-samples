# Banking App for iOS

This sample app illustrates how to integrate Skype for Business to an iOS application to do a anonymous meeting join with text chat and audio/video conversations.

# How to run this app

Open the BankingApp.xcodeproj and embed the Skype for Business SDK framework and SfBConversationHelper from the SDK download.
Please read [Use the SDK to join a meeting with an iOS device](HowToJoinMeeting.md) for more details. 

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
 
> note: in order to leave the conversaion, canLeave property of SfBConversation must be checked. In this case, it is monitored through Key-Value Observation.
 
## Handling Chat conversation
Chat feature handling is done in **ChatHandler.m**. This is a convinence class much like the SfBConversationHelper that handles only the text chat functionality.

For details on how the above class was used, see **ChatViewController.m**. 

> note: in order to leave the conversaion, canLeave property of SfBConversation must be checked. In this case, it is monitored through Key-Value Observation.

## Copyright
Copyright (c) 2016 Microsoft. All rights reserved.
