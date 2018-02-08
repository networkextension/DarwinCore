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
typedef void (^didWrite) (Boolean success, int fd,size_t count);
@interface GCDSocketServer : NSObject

@property (nonatomic) dispatch_queue_t  _Nonnull  dispatchQueue;
@property (nonatomic) dispatch_queue_t  _Nonnull  socketQueue;
@property (nonatomic) int sfd;
@property (nonatomic, copy) didAcceptSocket _Nonnull accept;
@property (nonatomic, copy) didClosedSocket _Nonnull colse;
@property (nonatomic, copy) incomingData _Nonnull incoming;
@property (nonatomic) dispatch_source_t _Nonnull as;
//+(GCDSocketServer*_Nonnull)shared;


-(void)startServer:(int)port dispatchQueue:(dispatch_queue_t  _Nonnull)dqueue socketQueue:(dispatch_queue_t  _Nonnull)squeue share:(BOOL)share;
-(void)server_write_request:(int)fd  data:(NSData*_Nullable)data  finish:(didWrite _Nonnull )finish;
-(void)stopServer;
-(BOOL)running;
-(void)pauseRestartServer;
-(bool)server_read:(int)fd buff:(unsigned char *_Nullable)buff size:(size_t)buff_sz start:(void  * _Nullable *_Nullable)msgStart total:(size_t *_Nullable)total;

@end
