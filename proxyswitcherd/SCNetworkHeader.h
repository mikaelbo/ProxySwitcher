#ifndef __SCNetworkHeader
#define __SCNetworkHeader

#import <Foundation/Foundation.h>

typedef const struct __SCPreferences *SCPreferencesRef;

extern const CFStringRef kSCPrefNetworkServices;
extern const CFStringRef kSCPrefCurrentSet;
extern const CFStringRef kSCEntNetProxies;
extern const CFStringRef kSCPropNetProxiesHTTPEnable;
extern const CFStringRef kSCPropNetProxiesHTTPProxy;
extern const CFStringRef kSCPropNetProxiesHTTPPort;
extern const CFStringRef kSCPropNetProxiesHTTPSEnable;
extern const CFStringRef kSCPropNetProxiesHTTPSProxy;
extern const CFStringRef kSCPropNetProxiesHTTPSPort;
extern const CFStringRef kSCPrefSets;
extern const CFStringRef kSCPropUserDefinedName;

extern const CFStringRef kSCCompNetwork;
extern const CFStringRef kSCCompService;


extern SCPreferencesRef SCPreferencesCreate ( CFAllocatorRef allocator, CFStringRef name, CFStringRef prefsID );

extern CFArrayRef SCPreferencesCopyKeyList ( SCPreferencesRef prefs );

extern CFPropertyListRef SCPreferencesGetValue ( SCPreferencesRef prefs, CFStringRef key );

extern Boolean SCPreferencesSetValue ( SCPreferencesRef prefs, CFStringRef key, CFPropertyListRef value );

extern Boolean SCPreferencesLock ( SCPreferencesRef prefs, Boolean wait );

extern Boolean SCPreferencesUnlock ( SCPreferencesRef prefs );

extern Boolean SCPreferencesApplyChanges ( SCPreferencesRef prefs );

extern Boolean SCPreferencesCommitChanges ( SCPreferencesRef prefs );

extern CFDictionaryRef SCPreferencesPathGetValue ( SCPreferencesRef prefs, CFStringRef path );

#define cfs2nss(cfs) ((__bridge NSString *)(cfs))

#endif
