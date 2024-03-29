//
//  MPLocationManager.h
//  MPLocationManager
//
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

#import <Foundation/Foundation.h>
#import "MPLocationDefines.h"
#import "MPLocationObject.h"

@protocol MPLocationDelegate <NSObject>

-(void)SendLocation:(MPLocationObject *)location;

@end

@interface MPLocationManager : NSObject

/** Create the singleton instance of this class. */
+ (instancetype)sharedInstance;

/** Authorization request types for the location. */
@property (nonatomic, assign) MPAuthorizationRequests preferredAuthorizationType;


#pragma mark - Setting and start location methods
/** To Start Updating Location */
- (void)StartUpdatingLocation;

/** To Set Accuracy you want for location */
- (void)SetMaxAccuracy:(MPLocationAccuracy)maxAccuracy;

/** Set location update time it will fire delegate method in your set times */
- (void)SetMaxUpdateTime:(MPLocationUpdateTime)maxTime;

/** To Stop Updating Location */
- (void)StopUpdatingLocation;

#pragma mark - To Get Currentlocation
- (CLLocation *)currentLocation;

@property (nonatomic, retain) id <MPLocationDelegate>delegate;

@end

