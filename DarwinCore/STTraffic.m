//
//  STTraffic.m
//  Surf
//
//  Created by 孔祥波 on 7/7/16.
//  Copyright © 2016 yarshure. All rights reserved.
//

#import "STTraffic.h"
#include <arpa/inet.h>
#include <net/if.h>
#include <ifaddrs.h>
#include <net/if_dl.h>

NSString *tunname()
{
    
    struct ifaddrs *addrs;
    const struct ifaddrs *cursor;
    //STTraffic *current = [[STTraffic alloc] init];
    //    u_int32_t WiFiSent = 0;
    //    u_int32_t WiFiReceived = 0;
    //    u_int32_t WWANSent = 0;
    //    u_int32_t WWANReceived = 0;
    //    u_int32_t TunSent = 0;
    //    u_int32_t TunReceived = 0;
    NSString *tunname = @"";
    if (getifaddrs(&addrs) == 0)
    {
        cursor = addrs;
        while (cursor != NULL)
        {
            if (cursor->ifa_addr->sa_family == AF_INET) //AF_INET 取IP 没问题
            {
                //cursor->ifa_addr
#ifdef DEBUG
                const struct if_data *ifa_data = (struct if_data *)cursor->ifa_data;
                if(ifa_data != NULL)
                {
                    NSLog(@"1111 Interface name %s: sent %tu received %tu",cursor->ifa_name,ifa_data->ifi_obytes,ifa_data->ifi_ibytes);
                }
#endif
                
                
                
                NSString *address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)cursor->ifa_addr)->sin_addr)];
                NSString *name = [NSString stringWithFormat:@"%s",cursor->ifa_name];
                
                NSLog(@"%@ %@",name,address);
                if ([name hasPrefix:@"utun"] && [address isEqualToString:@"240.7.1.9"])
                {
                    tunname = name;
                }
            }
            
            cursor = cursor->ifa_next;
        }
        
        freeifaddrs(addrs);
    }
    
    return tunname;
}

STTraffic *DataCounters()
{
    
    struct ifaddrs *addrs;
    const struct ifaddrs *cursor;
    NSString *tun = tunname();
    
    STTraffic *current = [[STTraffic alloc] init];
    if (tun  == nil) {
        return  current;
    }
//    u_int32_t WiFiSent = 0;
//    u_int32_t WiFiReceived = 0;
//    u_int32_t WWANSent = 0;
//    u_int32_t WWANReceived = 0;
//    u_int32_t TunSent = 0;
//    u_int32_t TunReceived = 0;
    
    if (getifaddrs(&addrs) == 0)
    {
        cursor = addrs;
        while (cursor != NULL)
        {
            if (cursor->ifa_addr->sa_family == AF_LINK) //AF_INET 取IP 没问题
            {
                //cursor->ifa_addr
#ifdef DEBUG
                const struct if_data *ifa_data = (struct if_data *)cursor->ifa_data;
                if(ifa_data != NULL)
                {
                    NSLog(@"Interface name %s: sent %tu received %tu",cursor->ifa_name,ifa_data->ifi_obytes,ifa_data->ifi_ibytes);
                }
#endif
                
                // name of interfaces:
                // en0 is WiFi
                // pdp_ip0 is WWAN
//                struct sockaddr_in *s4 = (struct sockaddr_in *)cursor->ifa_addr;
//                
//                if (inet_ntop(s4->sa_family, (void *)&(s4->sin_addr), buf, sizeof(buf)) != NULL) {
//                    // Failed to find it
//                    
//                    IPAddress = [NSString stringWithUTF8String:buf];
//                }
                
                NSString *address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)cursor->ifa_addr)->sin_addr)];
                NSString *name = [NSString stringWithFormat:@"%s",cursor->ifa_name];
                if ([name hasPrefix:@"en"])
                {
                    const struct if_data *ifa_data = (struct if_data *)cursor->ifa_data;
                    if(ifa_data != NULL)
                    {
                        current.WiFiSent += ifa_data->ifi_obytes;
                        current.WiFiReceived += ifa_data->ifi_ibytes;
                    }
                }
                
                if ([name hasPrefix:@"pdp_ip"])
                {
                    const struct if_data *ifa_data = (struct if_data *)cursor->ifa_data;
                    if(ifa_data != NULL)
                    {
                        current.WWANSent += ifa_data->ifi_obytes;
                        current.WWANReceived += ifa_data->ifi_ibytes;
                    }
                }
                NSLog(@"%@ %@",name,address);
                if ([name isEqualToString:tun])
                {
                    const struct if_data *ifa_data = (struct if_data *)cursor->ifa_data;
                    if(ifa_data != NULL)
                    {
                        current.TunSent += ifa_data->ifi_obytes;
                        current.TunReceived += ifa_data->ifi_ibytes;
                        
                    }
                    current.show = YES;
                }
            }
            
            cursor = cursor->ifa_next;
        }
        
        freeifaddrs(addrs);
    }
    
    return current;
}
@implementation STTraffic

@end
