//
//  SocketServer.m
//  DarwinCore
//
//  Created by yarshure on 2017/9/26.
//  Copyright © 2017年 Kong XiangBo. All rights reserved.
//

#import "SocketServer.h"
#include "xsocket.h"
#include "shared.h"

#include <os/log.h>
@implementation SocketServer
-(instancetype)initWith:(int)port dispatchQueue:(dispatch_queue_t)queue socketQueue:(dispatch_queue_t)squeue share:(BOOL)share
{
    if (self = [super init]){
        self.socket = [[GCDSocket alloc] initWithPort:port share:share];
        self.socket.dispatchQueue = queue;
        self.socket.socketQueue = squeue;
        self.dispatchQueue = queue;
        self.share = share;
        
    }
    return self;
}

-(void)startWith:(serverDidAcceptSocket)block;
{
    [self.socket accept:^(GCDSocket * _Nonnull s) {
        block(s);
    }];
    
}
-(void)stop
{
    //server socket don't read
    [self.socket closeReadWithError:nil];
    
}
-(void)pause
{
    self.socket.g_accepting_requests = !self.socket.g_accepting_requests;
}
@end
