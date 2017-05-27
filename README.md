# <img src="https://cloud.githubusercontent.com/assets/5389084/26520121/0385adbc-42ff-11e7-8fbf-e9a0a97f0d2f.png" width="24" height="24"/> ProxySwitcher
ProxySwitcher is meant to give an easy way to toggle proxy on / off. Since the proxy settings are on a per-WiFi basis, ProxySwitcher listens to changes to the WiFi network, and makes sure those settings are persisted through switching of active WiFi network.

<p align="center">
	<img src="https://cloud.githubusercontent.com/assets/5389084/26522886/ff38f384-433c-11e7-8c76-0cb2e088f630.png" width="216" height="384"/>
	<img src="https://cloud.githubusercontent.com/assets/5389084/26522887/ff38e88a-433c-11e7-88a4-76e2958a822d.png" width="216" height="384"/>
	<img src="https://cloud.githubusercontent.com/assets/5389084/26522885/ff32a128-433c-11e7-9cb4-141b12fafa65.png" width="216" height="384"/>
</p>

## TODO:
- Handle app switcher / screen lock / app open events when showing dropdown menu
- Saving proxy username and password credentials to the KeyChain properly (so that it gets assosiated with configured proxy server)
- Dropdown menu compability for below iOS 10

## Installation

### 1. Theos
Make sure you have [Theos](https://github.com/theos/theos) installed (guide found [here](http://iphonedevwiki.net/index.php/Theos/Setup)), with the `$THEOS` and `$THEOS_DEVICE_IP` variables configured. 

### 2. Private headers
Theos needs to point to an iOS SDK including private headers (required for using Preferences). The newer versions of the iOS SDK does not include those anymore. A few ways to solve that has been suggested in this [thread](https://github.com/theos/theos/issues/146).

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
dpkg-deb -c ./packages/com.mikaelbo.proxyswitcher_X+debug_iphoneos-arm.deb
```
```
drwxr-xr-x root/wheel        0 2017-05-23 16:35 ./
drwxr-xr-x root/wheel        0 2017-05-22 17:20 ./Library/
drwxr-xr-x root/wheel        0 2017-05-22 21:08 ./Library/LaunchDaemons/
-rw-r--r-- root/wheel      504 2017-05-22 21:08 ./Library/LaunchDaemons/
com.mikaelbo.proxyswitcherd.plist
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