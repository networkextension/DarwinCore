//
//  Header.h
//  DarwinCore
//
//  Created by yarshure on 2017/12/29.
//  Copyright © 2017年 Kong XiangBo. All rights reserved.
//

#ifndef Header_h
#define Header_h
#import <Foundation/Foundation.h>
//Value type      Custom specifier         Example output
//BOOL            %{BOOL}d                 YES
//bool            %{bool}d                 true
//darwin.errno    %{darwin.errno}d         [32: Broken pipe]
//darwin.mode     %{darwin.mode}d          drwxr-xr-x
//darwin.signal   %{darwin.signal}d        [sigsegv: Segmentation Fault]
//time_t          %{time_t}d               2016-01-12 19:41:37
//timeval         %{timeval}.*P            2016-01-12 19:41:37.774236
//timespec        %{timespec}.*P           2016-01-12 19:41:37.2382382823
//bitrate         %{bitrate}d              123 kbps
//iec-bitrate     %{iec-bitrate}d          118 Kibps
//uuid_t          %{uuid_t}.16P            10742E39-0657-41F8-AB99-878C5EC2DCAA
//sockaddr        %{network:sockaddr}.*P   fe80::f:86ff:fee9:5c16
//in_addr         %{network:in_addr}d      127.0.0.1
//in6_addr        %{network:in6_addr}.16P  fe80::f:86ff:fee9:5c16
@interface DarwinCoreLogger : NSObject
@property () BOOL debugEnable;
+ (DarwinCoreLogger*)sharedManager;
@end
#endif /* Header_h */
