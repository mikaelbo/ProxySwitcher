# <img src="https://cloud.githubusercontent.com/assets/5389084/26520121/0385adbc-42ff-11e7-8fbf-e9a0a97f0d2f.png" width="24" height="24"/> ProxySwitcher
ProxySwitcher is meant to give an easy way to toggle proxy on / off. Since the proxy settings are on a per-WiFi basis, ProxySwitcher listens to changes to the WiFi network, and makes sure those settings are persisted through switching of active WiFi network. 

Easily toggle between using proxy and non-proxy by tapping the added icon on the right side of the StatusBar. The icon is gray when it's set to not use proxy, and black/white  when proxy is active. 

The icon can be toggled to only show when WiFi is active (default), or to always be shown.

Available from iOS 9.1+

<p align="center">
	<img src="https://user-images.githubusercontent.com/5389084/28245623-b426cbdc-6a3d-11e7-9340-7bbfac0fbb30.png" width="216" height="384"/>
	<img src="https://user-images.githubusercontent.com/5389084/28245621-b3b29d7a-6a3d-11e7-8acf-ca205f7c97c3.png" width="216" height="384"/>
	<img src="https://user-images.githubusercontent.com/5389084/28245622-b3eff418-6a3d-11e7-98cf-ded2eb1f421e.png" width="216" height="384"/>
</p>

## Future wishlist:
- Saving proxy username and password credentials to the KeyChain (`SecKeychainAddInternetPassword`?)
- Multiple proxy configurations
- Overlay for toggling proxy. Something like this:

	<img src="https://cloud.githubusercontent.com/assets/5389084/26522886/ff38f384-433c-11e7-8c76-0cb2e088f630.png" width="216" height="384"/>

## Installation

### 1. Theos
Make sure you have [Theos](https://github.com/theos/theos) installed (guide found [here](http://iphonedevwiki.net/index.php/Theos/Setup)), with the `$THEOS` and `$THEOS_DEVICE_IP` variables configured. 

### 2. Private headers
Theos needs to point to an iOS SDK including private headers (required for using Preferences). The newer versions of the iOS SDK does not include those anymore. A few ways to solve that has been suggested in this [thread](https://github.com/theos/theos/issues/146). I ended up putting a separate iOS SDK including private headers in `$THEOS/sdks`.

### 3. fauxsu
The daemon must be owned by root:wheel, and to make sure that happens during the build, you can use a tool called [fauxsu](https://github.com/DHowett/fauxsu). A compiled version can be downloaded from [here](http://nix.howett.net/~dhowett/fauxsu.tar).

Extract `fauxsu` and `libfauxsu.dylib` to `$THEOS/bin/`. Run the following commands to make sure `fauxsu` and `libfauxsu.dylib` has the correct permissions:

```
sudo chmod +x $THEOS/bin/fauxsu
sudo chmod +x $THEOS/bin/libfauxsu.dylib
sudo chown root:wheel $THEOS/bin/fauxsu
sudo chown root:wheel $THEOS/bin/libfauxsu.dylib
```

`make install` to build it locally.

Check ownership by running:

```
dpkg-deb -c ./packages/com.mbo42.proxyswitcher_X+debug_iphoneos-arm.deb
```
```
drwxr-xr-x root/wheel        0 2017-05-23 16:35 ./
drwxr-xr-x root/wheel        0 2017-05-22 17:20 ./Library/
drwxr-xr-x root/wheel        0 2017-05-22 21:08 ./Library/LaunchDaemons/
-rw-r--r-- root/wheel      504 2017-05-22 21:08 ./Library/LaunchDaemons/
com.mbo42.proxyswitcherd.plist
drwxr-xr-x root/wheel        0 2017-05-23 16:35 ./usr/
drwxr-xr-x root/wheel        0 2017-05-23 16:35 ./usr/bin/
-rwxr-xr-x root/wheel   139680 2017-05-23 16:35 ./usr/bin/ProxySwitcherd
...
```

If the daemon still isn't owned by root:wheel, it might be because System Integrity Protection is turned on. You can check this by running `csrutil status` in the console.

When everything is set up and working properly, you can run `make package install` from the root directory to deploy to the device.

## Credits

* [Danny Liu](https://github.com/DYun) for his project [iOSProxyManager](https://github.com/DYun/iOSProxyManager)
* [Uroboro](https://github.com/uroboro) for his help on the #iphonedev IRC and his [iOS Daemon example project](https://github.com/uroboro/iOS-daemon/tree/Objective-C)
* [iOSre](http://bbs.iosre.com/)'s guide on [running a daemon as root](http://bbs.iosre.com/)

## Licence

This project is licensed under the [MIT Licence](https://github.com/mikaelbo/ProxySwitcher/blob/master/LICENSE). Feel free to use the code however you see fit in your own projects. However, redistribution of this tweak **as is** to Cydia is prohibited.