# iOSPush

This app is a debug tool for developing iOS applications using [PubNub Push](https://www.pubnub.com/solutions/push-notifications/). It is used internally and is now available for all developers. These links have more information about getting started with PubNub Push in [Objective-C](https://www.pubnub.com/docs/ios-objective-c/mobile-gateway-sdk-v4) and [Swift](https://www.pubnub.com/docs/swift/mobile-gateway).

## Features
* Handles requesting and storing device push tokens
* Properly adds and removes device push tokens from PubNub channels
* Publishes messages via PubNub (with sample APNS formats)
* Can automatically subscribe to "-pndebug" channels to track PubNub push debug messages
* Can fetch all channels for current device token
* Works with provided debug pub and sub keys
* Configurable, persisted PubNub client
* Can keep screen awake to ensure realtime logging
* Stores all results from actions unless reset by user

## Requirements

* This app will only work on iOS 10+ devices (PubNub push works on all iOS devices that are supported by Apple APNS).
* Xcode 8.3+
* Cocoapods 1.2+
* PubNub iOS SDK 4.5+

## Using this app with your account
If you want to use this app to test push with your own PubNub account, then you need provision your app with the [Apple Developer Portal](https://developer.apple.com/) before Push will work and ensure that your account is configured for Mobile Push Notifications.



To provi

### More Information

For troubleshooting with push, please try [our support article](https://support.pubnub.com/support/discussions/topics/14000006344) or contact us at support@pubnub.com

## Tasks

- [ ] Tests
- [ ] Log system events (configurable?)
- [ ] Branch for Push Notification Extension
- [ ] Write up README with instructions