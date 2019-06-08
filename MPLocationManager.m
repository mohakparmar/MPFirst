//
//  MPLocationManager.m
//  MPLocationManager
//  Permission is hereby granted, free of charge, to any person obtaining
//  a copy of this software and associated documentation files (the
//  "Software"), to deal in the Software without restriction, including
//  without limitation the rights to use, copy, modify, merge, publish,
//  distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to
//  the following conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
//  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
//  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
//  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
//  Copyright © 2019 Mohak Parmar. All rights reserved.
//

#import "MPLocationManager.h"

#ifndef MP_ENABLE_LOGGING
#   ifdef DEBUG
#       define MP_ENABLE_LOGGING 1
#   else
#       define MP_ENABLE_LOGGING 0
#   endif /* DEBUG */
#endif /* MP_ENABLE_LOGGING */

#if MP_ENABLE_LOGGING
#   define MPLMLog(...)          NSLog(@"MPLocationManager: %@", [NSString stringWithFormat:__VA_ARGS__]);
#else
#   define MPLMLog(...)
#endif /* MP_ENABLE_LOGGING */

@interface MPLocationManager () <CLLocationManagerDelegate>

/** The instance of CLLocationManager encapsulated by this class. */
@property (nonatomic, strong) CLLocationManager *locationManager;
/** The most recent current location, or nil if the current location is unknown, invalid, or stale. */
@property (nonatomic, strong) CLLocation *currentLocation;
/** Time Interval in which location update will required. */
@property (nonatomic, assign) NSTimeInterval timeInterval;
/** MPLocationObject To send data. */
@property (nonatomic, retain) MPLocationObject *objMPLocation;
/** MPLocationUpdateTime To send. */
@property (nonatomic, assign) MPLocationUpdateTime objMPLocationTime;
/** MPLocationAccuracy To send. */
@property (nonatomic, assign) MPLocationAccuracy objCurrentAccuracy;

@end

@implementation MPLocationManager

static id _sharedInstance;

/*  Create the singleton instance of this class.*/
+ (instancetype)sharedInstance
{
    static dispatch_once_t _onceToken;
    dispatch_once(&_onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (instancetype)init
{
    NSAssert(_sharedInstance == nil, @"Only one instance of MPLocationManager should be created. Use +[MPLocationManager sharedInstance] instead.");
    self = [super init];
    if (self) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        self.preferredAuthorizationType = MPAuthorizationRequestsTypeAuto;
        
#ifdef __IPHONE_8_4
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_8_4
        /* iOS 9 requires setting allowsBackgroundLocationUpdates to YES in order to receive background location updates.
         We only set it to YES if the location background mode is enabled for this app, as the documentation suggests it is a
         fatal programmer error otherwise. */
        NSArray *backgroundModes = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"UIBackgroundModes"];
        if ([backgroundModes containsObject:@"location"]) {
            if (@available(iOS 9, *)) {
                [_locationManager setAllowsBackgroundLocationUpdates:YES];
            }
        }
#endif /* __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_8_4 */
#endif /* __IPHONE_8_4 */
    }
    return self;
}

/** Requests permission to use location services on devices with iOS 8+. */
- (void)requestAuthorizationIfNeeded {
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_7_1
    // As of iOS 8, apps must explicitly request location services permissions. MPLocationManager supports both levels, "Always" and "When In Use".
    // MPLocationManager determines which level of permissions to request based on which description key is present in your app's Info.plist
    // If you provide values for both description keys, the more permissive "Always" level is requested.
    
    double iOSVersion = floor(NSFoundationVersionNumber);
    BOOL isiOSVersion7to10 = iOSVersion > NSFoundationVersionNumber_iOS_7_1 && iOSVersion <= NSFoundationVersionNumber10_11_Max;
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        BOOL canRequestAlways = NO;
        BOOL canRequestWhenInUse = NO;
        if (isiOSVersion7to10) {
            canRequestAlways = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationAlwaysUsageDescription"] != nil;
            canRequestWhenInUse = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationWhenInUseUsageDescription"] != nil;
        } else {
            canRequestAlways = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationAlwaysAndWhenInUseUsageDescription"] != nil;
            canRequestWhenInUse = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationWhenInUseUsageDescription"] != nil;
        }

        BOOL needRequestAlways = NO;
        BOOL needRequestWhenInUse = NO;
        switch (self.preferredAuthorizationType) {
            case MPAuthorizationRequestsTypeAuto:
                needRequestAlways = canRequestAlways;
                needRequestWhenInUse = canRequestWhenInUse;
                break;
            case MPAuthorizationRequestsTypeAlways:
                needRequestAlways = canRequestAlways;
                break;
            case MPAuthorizationRequestsTypeWhenInUse:
                needRequestWhenInUse = canRequestWhenInUse;
                break;
                
            default:
                break;
        }
        if (needRequestAlways) {
            [self.locationManager requestAlwaysAuthorization];
        } else if (needRequestWhenInUse) {
            [self.locationManager requestWhenInUseAuthorization];
        } else {
            if (isiOSVersion7to10) {
                // At least one of the keys NSLocationAlwaysUsageDescription or NSLocationWhenInUseUsageDescription MUST be present in the Info.plist file to use location services on iOS 8+.
                NSAssert(canRequestAlways || canRequestWhenInUse, @"To use location services in iOS 8+, your Info.plist must provide a value for either NSLocationWhenInUseUsageDescription or NSLocationAlwaysUsageDescription.");
            } else {
                // Key NSLocationAlwaysAndWhenInUseUsageDescription MUST be present in the Info.plist file to use location services on iOS 11+.
                NSAssert(canRequestAlways, @"To use location services in iOS 11+, your Info.plist must provide a value for NSLocationAlwaysAndWhenInUseUsageDescription.");
            }
        }
    }
#endif
}


#pragma mark - Setting and start location methods
-(void)StartUpdatingLocation {
    [self requestAuthorizationIfNeeded];
    [self.locationManager startUpdatingLocation];
}

- (void)SetMaxAccuracy:(MPLocationAccuracy)maxAccuracy {
    switch (maxAccuracy) {
        case MPLocationAccuracyNone:
            break;
        case MPLocationAccuracyVeryFar:
            if (self.locationManager.desiredAccuracy != kCLLocationAccuracyThreeKilometers) {
                self.locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
                MPLMLog(@"Changing location services accuracy level to: low (minimum).");
            }
            break;
        case MPLocationAccuracyFar:
            if (self.locationManager.desiredAccuracy != kCLLocationAccuracyKilometer) {
                self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
                MPLMLog(@"Changing location services accuracy level to: medium low.");
            }
            break;
        case MPLocationAccuracyModerate:
            if (self.locationManager.desiredAccuracy != kCLLocationAccuracyHundredMeters) {
                self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
                MPLMLog(@"Changing location services accuracy level to: medium.");
            }
            break;
        case MPLocationAccuracyNear:
            if (self.locationManager.desiredAccuracy != kCLLocationAccuracyNearestTenMeters) {
                self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
                MPLMLog(@"Changing location services accuracy level to: medium high.");
            }
            break;
        case MPLocationAccuracyVeryNear:
            if (self.locationManager.desiredAccuracy != kCLLocationAccuracyBest) {
                self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
                MPLMLog(@"Changing location services accuracy level to: high (maximum).");
            }
            break;
        default:
            if (maxAccuracy != 0) {
                self.locationManager.desiredAccuracy = maxAccuracy;
            }
            break;
    }
}

- (void)SetMaxUpdateTime:(MPLocationUpdateTime)maxTime {
    switch (maxTime) {
        case MPLocationUpdateTimeNone:
            self.timeInterval = 1;
            break;
        case MPLocationUpdateTime1Minutes:
            self.timeInterval = 60;
            break;
        case MPLocationUpdateTime5Minutes:
            self.timeInterval = 300;
            break;
        case MPLocationUpdateTime5Seconds:
            self.timeInterval = 5;
            break;
        case MPLocationUpdateTime10Minutes:
            self.timeInterval = 600;
            break;
        case MPLocationUpdateTime30Seconds:
            self.timeInterval = 30;
            break;
        default: {
            if (maxTime != 0) {
                self.timeInterval = maxTime;
            } else {
                self.timeInterval = 1;
            }
            break;
        }
    }
}

/** To Stop Updating Location */
- (void)StopUpdatingLocation {
    [self.locationManager stopUpdatingLocation];
}

#pragma mark CLLocationManagerDelegate methods
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *mostRecentLocation = [locations lastObject];
    self.currentLocation = mostRecentLocation;
    [self sendLocationObjectWithParameter];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    MPLMLog(@"Location services error: %@", [error localizedDescription]);
}

-(void)sendLocationObjectWithParameter {
    MPLocationObject *obj = [[MPLocationObject alloc] init];
    obj.MPLocation = self.currentLocation;
    obj.MPAccuracy = self.objCurrentAccuracy;
    obj.MPUpdateTime = self.objMPLocationTime;
    obj.MPTime = [NSDate date];
    [self.delegate SendLocation:obj];
}

/**  Returns the most recent current location, or nil if the current location is unknown, invalid, or stale. */
- (CLLocation *)currentLocation {
    if (_currentLocation) {
        // Location isn't nil, so test to see if it is valid
        if (!CLLocationCoordinate2DIsValid(_currentLocation.coordinate) || (_currentLocation.coordinate.latitude == 0.0 && _currentLocation.coordinate.longitude == 0.0)) {
            // The current location is invalid; discard it and return nil
            _currentLocation = nil;
        }
    }
    // Location is either nil or valid at this point, return it
    return _currentLocation;
}



@end



