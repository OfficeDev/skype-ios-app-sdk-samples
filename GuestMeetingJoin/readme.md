# Skype for Business IOS SDK - Guest Meeting Join sample

The Guest meeting join sample provides further technology details of you how to join a guest meeting, start chatting, and connect to the audio/video stream of the meeting.

##Prerequisites

1. Download the [**Skype for Business App SDK for iOS**](https://www.microsoft.com/en-us/download/confirmation.aspx?id=51962).

2. Obtain a [**meeting URL**](https://msdn.microsoft.com/en-us/skype/appsdk/getmeetingurl) for a Skype Business meeting.

##How to get started

1. Clone or copy the Guest Meeting Join sample app to your local machine.

2. Copy the SkypeForBusiness.framework in the parent directory of your sample application.
 
   > **Note**: The SDK comes with a SkypeForBusiness.framework for use on physical devices (recommended) and a SkypeForBusiness.framework for running the iOS simulator (limited because audio and video function won't work correctly). The binaries have the same name but are in separate folders. To run your app on a device, navigate to the location where you downloaded the App SDK and select the SkypeForBusiness.framework file in the AppSDKiOS folder. To run your app in a simulator, selec the SkypeForBusiness.framework file in the AppSDKiOSSimulator folder.

3. In the Project Navigator, select your project. In the Editor pane, go to General tab -> Open Embedded Binaries.  Click the + button to add a new framework. Click Add Other to navigate to where you just copied the SkypeforBusiness.framework.

   > **Note**: Add SkypeForBusiness.framework as an "Embedded Binary" (not a "Linked Framework").

4. Change the project **Bundle Identifier**. In the Project Navigator select your project. In the Editor pane, go to General tab -> Change Bundle Identifier under Identity section. 

5. Run the sample.  You will be prompted for [**meeting URL**](https://msdn.microsoft.com/en-us/skype/appsdk/getmeetingurl) and a display name of your choice.
