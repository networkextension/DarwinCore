//
//  xsocket.h
//  DarwinCore
//
//  Created by yarshure on 2017/9/26.
//  Copyright © 2017年 Kong XiangBo. All rights reserved.
//

#ifndef xsocket_h
#define xsocket_h

#include <stdio.h>
#import "GCDSocketServer.h"
#import <Foundation/Foundation.h>
int server_check_in(int port,bool share);

//bool server_read( int fd, unsigned char *buff, size_t buff_sz, void** msgStart, size_t *total );
//void server_send_reply(int fd, dispatch_queue_t q, CFDataRef data, didWrite finish);
#endif /* xsocket_h */
