---
page_type: sample
products:
- skype
- office-365
languages:
- swift
extensions:
  contentType: samples
  createdDate: 4/21/2016 10:21:45 AM
  scenarios:
  - Mobile
---
# Banking App for iOS (Objective C)

This sample app illustrates how to integrate the Skype for Business text chat, audio and video into an iOS application.

## Prerequisites

1. Download the [**Skype for Business App SDK for iOS**](https://www.microsoft.com/en-us/download/confirmation.aspx?id=51962). 

2. Obtain anonymous meeting join resource based on your [**Skype for Business topology and enable preview feature**](https://msdn.microsoft.com/en-us/skype/trusted-application-api/docs/anonymousmeetingjoin) as follow:
    
| Skype for Business (Office 365) user        | Enable preview features           | Meeting join resource  |
| ------------- |:-------------:| -----:|
| YES     | TRUE | Obtain a **[SfB Online (Office 365) meeting Url ](https://msdn.microsoft.com/en-us/skype/appsdk/getmeetingurl)** for a Skype Business meeting.|
| YES     | FALSE  |   Create and deploy **[Trusted Application API- based service application](https://msdn.microsoft.com/en-us/skype/trusted-application-api/docs/overview)** |   |
| NO | TRUE/FALSE    |    Obtain **SfB Server Meeting Url**  |

    
>[!NOTE]
Please read [Developing Trusted Application API applications for Skype for Business Online](https://msdn.microsoft.com/en-us/skype/trusted-application-api/docs/developingapplicationsforsfbonline) to learn more about Trusted Application API- based service application.
This service application will provide RESTful Trusted Application API endpoint to creates ad-hoc meetings, provides meeting join Urls, discovery Uris, and anonymous meeting tokens that will be used to run this sample.

## How to get started

1. Clone or copy the sample Banking App to your local machine.

2. Copy SkypeForBusiness.framework from the SkypeForBusinessAppSDKiOS folder in the SDK download into the sample app folder. 

   > **Note**: The SDK comes with a SkypeForBusiness.framework for use on physical devices (recommended) and a SkypeForBusiness.framework for running the iOS simulator (limited because audio and video function won't work correctly). The binaries have the same name but are in separate folders. To run your app on a device, navigate to the location where you downloaded the App SDK and select the SkypeForBusiness.framework file in the AppSDKiOS folder. To run your app in a simulator, selec the SkypeForBusiness.framework file in the AppSDKiOSSimulator folder.

3. In the Project Navigator, select your project. In the Editor pane, go to General tab -> Open Embedded Binaries.  Click the + button to add a new framework. Click Add Other to navigate to where you just copied the SkypeforBusiness.framework.

   > **Note**: Add SkypeForBusiness.framework as an "Embedded Binary" (not a "Linked Framework").

4. The sample app uses the SDK's "conversation helper" class that simplifies interaction with the core APIs in mainline scenarios. Copy SfBConversationHelper.h and SfBConversationHelper.m files from the Helpers folder in the SDK download into the sample app's source code.  Add these copied files to your project.

5. Based on your [Meeting join resource](##Prerequisites), edit the sample's Info.plist as follow: 

| Meeting join resource       |  info.plist parameters  |
| ------------- |:-------------:|
| [**SfB Online (Office 365) Meeting Url.**](https://msdn.microsoft.com/en-us/skype/appsdk/getmeetingurl)    | Replace the value of __Skype meeting URL__  with a [**SfB Online (Office 365) Meeting Url.**](https://msdn.microsoft.com/en-us/skype/appsdk/getmeetingurl)
| [**Trusted Application API- based service application**](https://msdn.microsoft.com/en-us/skype/trusted-application-api/docs/overview)    | Replace the value of __Token and discovery URI request API URL__ and __Online Meeting request API URL__ with your service application's custom listening APIs. 
| SfB Server Meeting Url |    Replace the value of __Skype meeting URL__  with you SfB server meeting Url  |

Also replace __Skype meeting display name__ in info.plist parameter with any desired name.

>[!NOTE] __TokenAndDiscoveryURIRequestURL__  and __Online Meeting request URL__ are custom listening APIs that your service application will need to implement. 
<br>__Online Meeting request URL__: POST on this link will return an adhoc-meeting Url.
</br>__TokenAndDiscoveryURIRequestURL__: POST on this link with your adhoc-meeting Url will receive a response with the DiscoverUri and token.

7. Build and run the app.

8. Press the **"Settings"** button to configure your app for **Skype for Business topology and enable preview feature**. The following table shows you what settings to use for your SfB deployment scenario.

|Skype for Business topology|Enable preview features enabled|Enable preview features disabled|Meeting join resource|
|:----|:----|:----|:----|
|CU June 2016|Chat, AV|Chat only|Meeting Url|
|CU December 2016|Chat, AV| Chat, AV|Meeting Url|
|SfB Online|Chat, AV|n/a|Meeting Url|
|SfB Online|n/a|Chat, AV|Discover Uri, Anon Token|

9. Press the **"Sign in"** button to login.  This is a pseudo login screen and does not require a real email and password. 

10. Once you sign in, you enter the main screen where you can view pseudo bank account details and can contact a "bank agent" via text or video call.

   > Note: To test the app, you need to join the meeting as a "bank agent" yourself by using the Skype for Business application installed on your desktop or mobile device. Join the same [**meeting URL**](https://msdn.microsoft.com/en-us/skype/appsdk/getmeetingurl) that you configured in the app above.

## Sample code walkthrough

Here's how the sample source code works:

### Initializing Skype for Business
In **MainViewController.m**, initialization of Skype is done. Application level Skype configurations can be handled here, e.g.  requireWifiForAudio, requireWifiForVideo, cameras list etc.

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

