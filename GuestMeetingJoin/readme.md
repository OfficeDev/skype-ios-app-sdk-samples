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

5. Build and run the sample.

6. Enter the [**meeting URL**](https://msdn.microsoft.com/en-us/skype/appsdk/getmeetingurl) and a display name of your choice.

7. Join the meeting.

   > Note: To test the app, you need to join the meeting as the remote "agent" yourself by using the Skype for Business application installed on your desktop or mobile device. Join the same [**meeting URL**](https://msdn.microsoft.com/en-us/skype/appsdk/getmeetingurl) that you configured in the app above.

### Conversation Screen

Once you join the meeting, you enter the conversation screen. On this screen, you can send text message to other meeting participants and view chat history.

- Conversation Screen shows:
 - The "Leave" button to leave the meeting.
 - The "Loudspeaker/Handset" toggle button.
 - The "held/Unheld" toggle button to hold call.
 - The "Participants" button that takes you to the **Participants Screen**.
 
###Participants Screen
 
Here you can view the list of meeting participants identified by name, along with their live video stream (if available).
- Participants Screen shows:
  - The "Play" button to start outgoing video. 
  - The "Pause" button to pause outgoing video.
  - The "Close" button to stop outgoing video.
  - The "Camera" icon to switch front-to-back camera option. 
  - The "Mute/Audio" toggle button to handle outgoing audio.
  - The remote participant list is available, with an indication of who is speaking.
  - The "Chat" button to go back to **Conversation Screen**.
 