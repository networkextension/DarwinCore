//
//  GCDSocketServer.h
//  DarwinCore
//
//  Created by yarshure on 2017/8/17.
//  Copyright © 2017年 Kong XiangBo. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^didAcceptSocket)(int fd, NSString  * _Nonnull ipaddr,int port);
typedef void (^didClosedSocket)(int fd);
typedef void (^incomingData)(int fd,NSData * _Nonnull  data);

@interface GCDSocketServer : NSObject

@property (nonatomic) dispatch_queue_t  _Nonnull  dispatchQueue;
@property (nonatomic) int sfd;
@property (nonatomic, copy) didAcceptSocket _Nonnull accept;
@property (nonatomic, copy) didClosedSocket _Nonnull colse;
@property (nonatomic, copy) incomingData _Nonnull incoming;
@property (nonatomic) dispatch_source_t _Nonnull as;
+(GCDSocketServer*_Nonnull)shared;


-(void)startServer:(int)port queue:(dispatch_queue_t  _Nonnull)queue;
-(void)server_write_request:(int)fd buffer:(const void *_Nonnull)buffer total:(size_t)total;
-(void)stopServer;
-(BOOL)running;
@end
