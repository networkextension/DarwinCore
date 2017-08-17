//
//  GCDSocketServer.h
//  DarwinCore
//
//  Created by yarshure on 2017/8/17.
//  Copyright © 2017年 Kong XiangBo. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^didAcceptSocket)(int fd,NSString* ipaddr,int port);
typedef void (^didClosedSocket)(int fd);
typedef void (^incomingData)(int fd,NSData *  data);

@interface GCDSocketServer : NSObject

@property (nonatomic) dispatch_queue_t  dispatchQueue;
@property (nonatomic) int sfd;
@property (nonatomic, copy) didAcceptSocket accept;
@property (nonatomic, copy) didClosedSocket colse;
@property (nonatomic, copy) incomingData incoming;
@property (nonatomic) dispatch_source_t as;
+(GCDSocketServer*)shared;


-(void)startServer:(int)port queue:(dispatch_queue_t  )queue;
-(void)server_write_request:(int)fd buffer:(const void *)buffer total:(size_t)total;
-(void)stopServer;
-(BOOL)running;
@end
