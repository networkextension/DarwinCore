//
//  myclass.m
//  testip
//
//  Created by yarshure on 2017/6/2.
//  Copyright © 2017年 yarshure. All rights reserved.
//

#import "DCIPAddr.h"

#include <arpa/inet.h>

#include <sys/socket.h>

#include <ifaddrs.h>
@implementation DCIPAddr
+(NSDictionary *)cellAddress
{
    // On iPhone, 3G is "pdp_ipX", where X is usually 0, but may possibly be 0-3 (i'm guessing...)
    
    NSData *result = nil;
    
    struct ifaddrs *addrs;
    const struct ifaddrs *cursor;
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    if ((getifaddrs(&addrs) == 0))
    {
        cursor = addrs;
        while (cursor != NULL)
        {
            //NSLog(@"cursor->ifa_name = %s", cursor->ifa_name);
            
//            if (strncmp(cursor->ifa_name, "pdp_ip", 6) == 0)
//            {
//                
//            }
            if (cursor->ifa_addr->sa_family == AF_INET)
            {
                struct sockaddr_in *addr = (struct sockaddr_in *)cursor->ifa_addr;
                //NSLog(@"cursor->ifa_addr = %s", inet_ntoa(addr->sin_addr));
                
                result = [NSData dataWithBytes:addr length:sizeof(struct sockaddr_in)];
                
                NSString *ifname = [NSString stringWithUTF8String:cursor->ifa_name];
                [info setObject:[NSString stringWithUTF8String:inet_ntoa(addr->sin_addr)] forKey:ifname];
                cursor = cursor->ifa_next;
            }
            else
            {
                cursor = cursor->ifa_next;
            }
            
        }
        freeifaddrs(addrs);
    }
    
    return info;
}
@end
