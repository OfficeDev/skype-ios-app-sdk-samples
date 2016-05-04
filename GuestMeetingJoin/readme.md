# Skype for Business IOS SDK - Guest Meeting Join sample

Guest Meeting Join sample demonstrates the power of ** Skype for Business – App SDK API** to start or join a meeting, participate in chat, and start sharing audio/video. The user has to provide a **Join Meeting URL** to participate. 

##Prerequisites

1. Download [**Skype for Business App SDK for iOS**](https://www.microsoft.com/en-us/download/confirmation.aspx?id=51962) 

2. Have a [**Join Meeting URL**](https://msdn.microsoft.com/en-us/skype/appsdk/getmeetingurl) for an established Skype Business meeting.

##How to get started

1. Clone the Guest Meeting Join sample application in your local directory
2. Copy the SkypeForBusiness.framework in the parent directory of your sample application. 
3. Change the project **Bundle Identifier**. In the Project Navigator, Select your project. -> In Editor, Go to General tab -> Change Bundle Identifier under Identity section. 
```console
NOTE: The SDK comes with a SkypeForBusiness.framework for use on physical devices (recommended) and a SkypeForBusiness.framework for running the iOS simulator (limited because audio and video function won't work correctly). The binaries have the same name but are in separate folders. To run your app on a device, navigate to the location where you downloaded the App SDK and select the SkypeForBusiness.framework file in the AppSDKiOS folder. To run your app in a simulator, selec the SkypeForBusiness.framework file in the AppSDKiOSSimulator folder.
```

##Run the sample

On running the sample, you will be prompted for Meeting URL. To join the meeting, Use [**Join Meeting URL**](https://msdn.microsoft.com/en-us/skype/appsdk/getmeetingurl) for an established Skype Business meeting.
```console 
Note: Depending on the framework added, sample application can run on simulator or an iOS device.
```
##Copyright

Copyright (c) 2016 Microsoft. All rights reserved.
