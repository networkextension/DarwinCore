//
//  DNSResolver.h
//  Surf
//
//  Created by 孔祥波 on 7/27/16.
//  Copyright © 2016 yarshure. All rights reserved.
//

#import <Foundation/Foundation.h>

#include <dns_sd.h>


@class DNSResolver;

@interface DNSResultRecord : NSObject
@property (nonatomic,strong) NSString *ipaddress;
@property (nonatomic) DNSServiceErrorType type;
@end
typedef void (^DNSCallback)(DNSResultRecord *r);
//DNSCallback blockName = ^void(DNSResolver *r){};


@interface DNSResolver : NSObject
@property (nonatomic,strong) NSDate *startDate;
@property (nonatomic,strong) NSString *hostname;

@property (nonatomic,copy) DNSCallback dnsRequestCompleted;



- (void)failed:(DNSServiceErrorType)theErrorCode;
-(void)querey:(NSString *)domain complete:(DNSCallback)complete;
@end
