# react-native-device-info

[![npm version](https://badge.fury.io/js/react-native-device-info@2x.png)](http://badge.fury.io/js/react-native-device-info)

Device Information for [React Native](https://github.com/facebook/react-native)

This is a fork of a fork.

	https://github.com/rebeccahughes/react-native-device-info
		=> 
		https://github.com/sphynxnz/react-native-device-info
			=> 
			https://github.com/lotto-nz/react-native-device-info
		

It has been forked and packaged up separately to enable control over device ID's. OS and device vendors may change aspects of Device ID in the future. We generate ID's in UUID format and persist them in the device key store for Android and iOS.

## Install (This forked version)

```shell
npm install --save @lotto-nz/react-native-device-info
```

## Automatically link

#### With React Native 0.27+

```shell
react-native link @lotto-nz/react-native-device-info
```

## Manually link

### iOS (via Cocoa Pods)
Add the following line to your build targets in your `Podfile`

`pod 'RNDeviceInfo', :path => '../node_modules/@lotto-nz/react-native-device-info'`

Then run `pod install`

### iOS (without Cocoa Pods)

In XCode, in the project navigator:
- Right click _Libraries_
- Add Files to _[your project's name]_
- Go to `node_modules/@lotto-nz/react-native-device-info`
- Add the `.xcodeproj` file

In XCode, in the project navigator, select your project.
- Add the `libRNDeviceInfo.a` from the _deviceinfo_ project to your project's _Build Phases ➜ Link Binary With Libraries_
- Click `.xcodeproj` file you added before in the project navigator and go the _Build Settings_ tab. Make sure _All_ is toggled on (instead of _Basic_).
- Look for _Header Search Paths_ and make sure it contains both `$(SRCROOT)/../@lotto-nz/react-native/React` and `$(SRCROOT)/../../React`
- Mark both as recursive (should be OK by default).

Run your project (Cmd+R)

(Thanks to @brysgo for writing the instructions)

### Android

- in `android/app/build.gradle`:

```diff
dependencies {
    ...
    compile "com.facebook.react:react-native:+"  // From node_modules
+   compile project(':react-native-device-info')
}
```

- in `android/settings.gradle`:

```diff
...
include ':app'
+ include ':react-native-device-info'
+ project(':react-native-device-info').projectDir = new File(rootProject.projectDir, '../node_modules/react-native-device-info/android')
```

#### With React Native 0.29+

- in `MainApplication.java`:

```diff
+ import com.learnium.RNDeviceInfo.RNDeviceInfo;

  public class MainApplication extends Application implements ReactApplication {
    //......

    @Override
    protected List<ReactPackage> getPackages() {
      return Arrays.<ReactPackage>asList(
+         new RNDeviceInfo(),
          new MainReactPackage()
      );
    }

    ......
  }
```

#### With older versions of React Native:

- in `MainActivity.java`:

```diff
+ import com.learnium.RNDeviceInfo.RNDeviceInfo;

  public class MainActivity extends ReactActivity {
    ......

    @Override
    protected List<ReactPackage> getPackages() {
      return Arrays.<ReactPackage>asList(
+       new RNDeviceInfo(),
        new MainReactPackage()
      );
    }
  }
```

(Thanks to @chirag04 for writing the instructions)

## Device Name

If you want to get the device name in Android add this to your `AndroidManifest.xml` (optional):

```xml
...
<uses-permission android:name="android.permission.BLUETOOTH"/>
```

## Release Notes

See [CHANGELOG.md](https://github.com/rebeccahughes/react-native-device-info/blob/master/CHANGELOG.md)

## Example

```js
var DeviceInfo = require('react-native-device-info');

console.log("Device Unique ID", DeviceInfo.getUniqueID());  // e.g. FCDBD8EF-62FC-4ECB-B2F5-92C9E79AC7F9
// * note this is IDFV on iOS so it will change if all apps from the current apps vendor have been previously uninstalled

console.log("Device Manufacturer", DeviceInfo.getManufacturer());  // e.g. Apple

console.log("Device Brand", DeviceInfo.getBrand());  // e.g. Apple / htc / Xiaomi

console.log("Device Model", DeviceInfo.getModel());  // e.g. iPhone 6

console.log("Device ID", DeviceInfo.getDeviceId());  // e.g. iPhone7,2 / or the board on Android e.g. goldfish

console.log("System Name", DeviceInfo.getSystemName());  // e.g. iPhone OS

console.log("System Version", DeviceInfo.getSystemVersion());  // e.g. 9.0

console.log("Bundle ID", DeviceInfo.getBundleId());  // e.g. com.learnium.mobile

console.log("Build Number", DeviceInfo.getBuildNumber());  // e.g. 89

console.log("App Version", DeviceInfo.getVersion());  // e.g. 1.1.0

console.log("App Version (Readable)", DeviceInfo.getReadableVersion());  // e.g. 1.1.0.89

console.log("Device Name", DeviceInfo.getDeviceName());  // e.g. Becca's iPhone 6

console.log("Device Locale", DeviceInfo.getDeviceLocale()); // e.g en-US

console.log("Device Country", DeviceInfo.getDeviceCountry()); // e.g US

console.log("Timezone", DeviceInfo.getTimezone()); // e.g America/Mexico_City

console.log("App Instance ID", DeviceInfo.getInstanceID()); // ANDROID ONLY - see https://developers.google.com/instance-id/
```
