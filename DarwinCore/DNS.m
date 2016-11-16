//
//  DNS.m
//  DarwinCore
//
//  Created by 孔祥波 on 16/11/2016.
//  Copyright © 2016 Kong XiangBo. All rights reserved.
//

#import "DNS.h"
#import <resolv.h>
#include <dns_sd.h>
#include <arpa/inet.h>
#include <pthread.h>
#include <libkern/OSAtomic.h>
#include <execinfo.h>
@implementation DNS
+(NSArray<NSString*> *)loadSystemDNSServer
{
    res_state res = malloc(sizeof(struct __res_state));
    int result = res_ninit(res);
    
    NSMutableArray *servers = [[NSMutableArray alloc] init];
    if (result == 0) {
        union res_9_sockaddr_union *addr_union = malloc(res->nscount * sizeof(union res_9_sockaddr_union));
        res_getservers(res, addr_union, res->nscount);
        
        for (int i = 0; i < res->nscount; i++) {
            if (addr_union[i].sin.sin_family == AF_INET) {
                char ip[INET_ADDRSTRLEN];
                inet_ntop(AF_INET, &(addr_union[i].sin.sin_addr), ip, INET_ADDRSTRLEN);
                NSString *dnsIP = [NSString stringWithUTF8String:ip];
                [servers addObject:dnsIP];
                NSLog(@"IPv4 DNS IP: %@", dnsIP);
            } else if (addr_union[i].sin6.sin6_family == AF_INET6) {
                char ip[INET6_ADDRSTRLEN];
                inet_ntop(AF_INET6, &(addr_union[i].sin6.sin6_addr), ip, INET6_ADDRSTRLEN);
                NSString *dnsIP = [NSString stringWithUTF8String:ip];
                [servers addObject:dnsIP];
                NSLog(@"IPv6 DNS IP: %@", dnsIP);
            } else {
                NSLog(@"Undefined family.");
            }
        }
        if (addr_union != NULL) {
            free(addr_union);
        }
    }
    res_nclose(res);
    res_ndestroy(res);
    free(res);
    
    return [NSArray arrayWithArray:servers];
}
@end
