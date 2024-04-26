#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "FBAuthorizationStatusHandler.h"
#import "FBBluetoothStateHandler.h"
#import "FBMonitoringStreamHandler.h"
#import "FBRangingStreamHandler.h"
#import "FBUtils.h"
#import "FlutterBeaconPlugin.h"

FOUNDATION_EXPORT double flutter_beaconVersionNumber;
FOUNDATION_EXPORT const unsigned char flutter_beaconVersionString[];

