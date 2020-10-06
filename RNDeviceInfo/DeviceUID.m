// Initial work from:
// https://gist.github.com/miguelcma/e8f291e54b025815ca46
// Modified as the original version crashes.

#import "DeviceUID.h"

@import UIKit;

@interface DeviceUID ()

@property(nonatomic, strong, readonly) NSString *uidKey;
@property(nonatomic, strong, readonly) NSString *uid;

@end

@implementation DeviceUID

@synthesize uid = _uid;

/*! Service namespace for ISR constants
 */
NSString *const StorageSecureNameSpace = @"lottonz";

/*! Key for deviceID constant in ISR
 */
NSString *const LnzDeviceIdKey = @"lnz-uuid";


#pragma mark - Public methods

+ (NSString *)uid {
    return [[[DeviceUID alloc] initWithKey:@"deviceUID"] uid];
}

#pragma mark - Instance methods

- (id)initWithKey:(NSString *)key {
    self = [super init];
    if (self) {
        _uidKey = key;
        _uid = nil;
    }
    return self;
}

/*! Returns the Device UID.
    The UID is obtained in a chain of fallbacks:
      - Keychain
      - NSUserDefaults
      - Generate a random UUID if everything else is unavailable
    At last, the UID is persisted if needed to.
 */
- (NSString *)uid {
    if (!_uid) _uid = [[self class] valueForKeychainKey:_uidKey service:_uidKey];
    if (!_uid) _uid = [[self class] valueForUserDefaultsKey:_uidKey];
    /*
    * Remove reliance on IFV
    if (!_uid) _uid = [[self class] appleIFV]; 
    */
    if (!_uid) _uid = [[self class] randomUUID];
    [self save];
    [self saveSecureStorage];
    return _uid;
}

/*! Persist UID to NSUserDefaults and Keychain, if not yet saved
 */
- (void)save {
  if (![DeviceUID valueForUserDefaultsKey:_uidKey]) {
    [DeviceUID setValue:_uid forUserDefaultsKey:_uidKey];
  }
  if (![DeviceUID valueForKeychainKey:_uidKey service:_uidKey]) {
    [DeviceUID setValue:_uid forKeychainKey:_uidKey inService:_uidKey];
  }
}

/*! Persist UID in a way that can be retrieved with cordova-plugin-secure-storage-echo
 */
- (void)saveSecureStorage {
  NSString *appIdentifierPrefix = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"AppIdentifierPrefix"];

  NSString *bundleAccessGroupSuffix = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"];
  NSString *defaultAccessGroupSuffix = @"co.nz.mylotto";

  NSString *bundleAccessGroup = [appIdentifierPrefix stringByAppendingString:bundleAccessGroupSuffix];
  NSString *defaultAccessGroup = [appIdentifierPrefix stringByAppendingString:defaultAccessGroupSuffix];

  // Save for default access group
  if (![DeviceUID valueForKeychainKey:LnzDeviceIdKey service:StorageSecureNameSpace accessGroup:defaultAccessGroup]) {
     [DeviceUID setValue:_uid forKeychainKey:LnzDeviceIdKey inService:StorageSecureNameSpace withAccessGroup:defaultAccessGroup];
  }
  else {
     [DeviceUID updateValue:_uid forKeychainKey:LnzDeviceIdKey inService:StorageSecureNameSpace withAccessGroup:defaultAccessGroup];
  }
  // Save for bundle access group
  if (![DeviceUID valueForKeychainKey:LnzDeviceIdKey service:StorageSecureNameSpace accessGroup:bundleAccessGroup]) {
    OSStatus status;
    status = [DeviceUID setValue:_uid forKeychainKey:LnzDeviceIdKey inService:StorageSecureNameSpace withAccessGroup:bundleAccessGroup];
      // Adding fails try to update as well
      if (status != noErr) {
          [DeviceUID updateValue:_uid forKeychainKey:LnzDeviceIdKey inService:StorageSecureNameSpace withAccessGroup:bundleAccessGroup];
      }
  }
  else {
     [DeviceUID updateValue:_uid forKeychainKey:LnzDeviceIdKey inService:StorageSecureNameSpace withAccessGroup:bundleAccessGroup];
  }
}

#pragma mark - Keychain methods

/*! Create as generic NSDictionary to be used to query and update Keychain items.
 *  param1
 *  param2
 */
+ (NSMutableDictionary *)keychainItemForKey:(NSString *)key service:(NSString *)service {
    NSMutableDictionary *keychainItem = [[NSMutableDictionary alloc] init];
    keychainItem[(__bridge id)kSecClass] = (__bridge id)kSecClassGenericPassword;
    keychainItem[(__bridge id)kSecAttrAccessible] = (__bridge id)kSecAttrAccessibleAlways;
    keychainItem[(__bridge id)kSecAttrAccount] = key;
    keychainItem[(__bridge id)kSecAttrService] = service;
    return keychainItem;
}

/*! Create as generic NSDictionary to be used to query and update Keychain items. Also allow querying via Keychain access groups.
 *  param1
 *  param2
 */
+ (NSMutableDictionary *)keychainItemForKey:(NSString *)key service:(NSString *)service accessGroup:(NSString *)accessGroup {
    NSMutableDictionary *keychainItem = [[NSMutableDictionary alloc] init];
    keychainItem[(__bridge id)kSecClass] = (__bridge id)kSecClassGenericPassword;
    keychainItem[(__bridge id)kSecAttrAccessible] = (__bridge id)kSecAttrAccessibleAlways;
    keychainItem[(__bridge id)kSecAttrAccount] = key;
    keychainItem[(__bridge id)kSecAttrService] = service;
    keychainItem[(__bridge id)kSecAttrAccessGroup] = accessGroup;

    return keychainItem;
}


/*! Sets
 *  param1
 *  param2
 */
+ (OSStatus)setValue:(NSString *)value forKeychainKey:(NSString *)key inService:(NSString *)service {
    NSMutableDictionary *keychainItem = [[self class] keychainItemForKey:key service:service];
    keychainItem[(__bridge id)kSecValueData] = [value dataUsingEncoding:NSUTF8StringEncoding];
    return SecItemAdd((__bridge CFDictionaryRef)keychainItem, NULL);
}

+ (OSStatus)setValue:(NSString *)value forKeychainKey:(NSString *)key inService:(NSString *)service withAccessGroup:(NSString *)accessGroup {
    NSMutableDictionary *keychainItem = [[self class] keychainItemForKey:key service:service accessGroup:accessGroup];
    keychainItem[(__bridge id)kSecValueData] = [value dataUsingEncoding:NSUTF8StringEncoding];
    return SecItemAdd((__bridge CFDictionaryRef)keychainItem, NULL);
}


+ (OSStatus)updateValue:(NSString *)value forKeychainKey:(NSString *)key inService:(NSString *)service withAccessGroup:(NSString *)accessGroup {
    NSDictionary *query = [NSDictionary dictionaryWithObjectsAndKeys:
                           (__bridge id)kSecClassGenericPassword, kSecClass,
                           key, kSecAttrAccount,
                           service, kSecAttrService,
                           accessGroup, kSecAttrAccessGroup,
                           nil];

    NSDictionary *attributesToUpdate = [NSDictionary dictionaryWithObjectsAndKeys:
                                       [value dataUsingEncoding:NSUTF8StringEncoding], kSecValueData,
                                       nil];

    return SecItemUpdate((__bridge CFDictionaryRef)query, (__bridge CFDictionaryRef)attributesToUpdate);
}

+ (NSString *)valueForKeychainKey:(NSString *)key service:(NSString *)service {
    OSStatus status;
    NSMutableDictionary *keychainItem = [[self class] keychainItemForKey:key service:service];
    keychainItem[(__bridge id)kSecReturnData] = (__bridge id)kCFBooleanTrue;
    keychainItem[(__bridge id)kSecReturnAttributes] = (__bridge id)kCFBooleanTrue;
    CFDictionaryRef result = nil;
    status = SecItemCopyMatching((__bridge CFDictionaryRef)keychainItem, (CFTypeRef *)&result);
    if (status != noErr) {
        return nil;
    }
    NSDictionary *resultDict = (__bridge_transfer NSDictionary *)result;
    NSData *data = resultDict[(__bridge id)kSecValueData];
    if (!data) {
        return nil;
    }
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

+ (NSString *)valueForKeychainKey:(NSString *)key service:(NSString *)service accessGroup:(NSString *)accessGroup {
    OSStatus status;
    NSMutableDictionary *keychainItem = [[self class] keychainItemForKey:key service:service accessGroup:accessGroup];
    keychainItem[(__bridge id)kSecReturnData] = (__bridge id)kCFBooleanTrue;
    keychainItem[(__bridge id)kSecReturnAttributes] = (__bridge id)kCFBooleanTrue;
    CFDictionaryRef result = nil;
    status = SecItemCopyMatching((__bridge CFDictionaryRef)keychainItem, (CFTypeRef *)&result);
    if (status != noErr) {
        return nil;
    }
    NSDictionary *resultDict = (__bridge_transfer NSDictionary *)result;
    NSData *data = resultDict[(__bridge id)kSecValueData];
    if (!data) {
        return nil;
    }
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

#pragma mark - NSUserDefaults methods

+ (BOOL)setValue:(NSString *)value forUserDefaultsKey:(NSString *)key {
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
    return [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)valueForUserDefaultsKey:(NSString *)key {
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

#pragma mark - UID Generation methods

/*
* Remove reliance on IFV
*
+ (NSString *)appleIFV {
    if(NSClassFromString(@"UIDevice") && [UIDevice instancesRespondToSelector:@selector(identifierForVendor)]) {
        // only available in iOS >= 6.0
        return [[UIDevice currentDevice].identifierForVendor UUIDString];
    }
    return nil;
}
*/

+ (NSString *)randomUUID {
    if(NSClassFromString(@"NSUUID")) {
        return [[[NSUUID UUID] UUIDString] uppercaseString];
    }
    CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef cfuuid = CFUUIDCreateString(kCFAllocatorDefault, uuidRef);
    CFRelease(uuidRef);
    NSString *uuid = [((__bridge NSString *) cfuuid) copy];
    CFRelease(cfuuid);
    return [uuid uppercaseString];
}

@end
