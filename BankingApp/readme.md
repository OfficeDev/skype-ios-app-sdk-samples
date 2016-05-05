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

###Login Screen:

This is a pseudo login screen and does not require email and password to sign in. Simply press **"Sign in"** button to login.
```console
 Note: Before signing in, make sure that you edit Info.plist and replace value of __Skype meeting URL__ and __Skype meeting display name__ with a valid "Meeting URL" and any desired name respectively. 
```
### Accounts Screen:

Once you sign in, You enter the Accounts screen where you can view pseudo bank account details and can contact the bank agent via text or video call.

- Accounts Screen shows:
 - The "Available balance" for Checking/Saving account.
 - The "Pay Bills" button that takes you to account detail view  .
 - The "Ask Agent" button that connects you to banking agent via text or video call.
 - The "Log off" button to log out of the sample
 
### Chat Screen:
 
Press "Ask Agent" button -> select "Ask using Text Chat" from options menu to start text Chat with the bank agent. You will be notified once the agent is available for chat. Press "End" button to exit the chat.

### Video Chat Screen:
 
 Press "Ask Agent" button -> select "Ask using Video Chat" from options menu to start Video Chat with the agent. You will be notified once you are connected to the agent. This screen will show live video stream of user and bank agent.
 
 - User can
  - Press "End" button to exit the chat. 
  - Use Mute/unMute toggle button to handle outgoing audio.
  
 

