//
//  STTraffic.h
//  Surf
//
//  Created by 孔祥波 on 7/7/16.
//  Copyright © 2016 yarshure. All rights reserved.
//

#import <Foundation/Foundation.h>
static NSString *const DataCounterKeyWWANSent = @"WWANSent";
static NSString *const DataCounterKeyWWANReceived = @"WWANReceived";
static NSString *const DataCounterKeyWiFiSent = @"WiFiSent";
static NSString *const DataCounterKeyWiFiReceived = @"WiFiReceived";
static NSString *const DataCounterKeyTunSent = @"TunSent";
static NSString *const DataCounterKeyTunReceived = @"TunReceived";

@interface STTraffic : NSObject

@property (nonatomic) NSUInteger    WiFiSent;
@property (nonatomic) NSUInteger    WiFiReceived;
@property (nonatomic) NSUInteger    WWANSent;
@property (nonatomic) NSUInteger    WWANReceived;
@property (nonatomic) NSUInteger    TunSent;
@property (nonatomic) NSUInteger    TunReceived;
@property (nonatomic) BOOL show;
@end
NSString *tunname(NSString *ipaddress);
STTraffic *DataCounters(NSString *ipaddress);
