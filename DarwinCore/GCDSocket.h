//
//  GCDSocket.h
//  DarwinCore
//
//  Created by yarshure on 2017/9/26.
//  Copyright © 2017年 Kong XiangBo. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GCDSocketServer.h"
@class GCDSocket;
typedef void (^socketIncomingData)(GCDSocket *socket,NSData *  data);
typedef void (^socketDidClosedSocket)(GCDSocket *socket);

@interface GCDSocket : NSObject
@property (nonatomic) int sfd;
@property (nonatomic,strong ) NSString *remote;
@property (nonatomic) int port;
@property (nonatomic) dispatch_queue_t  dispatchQueue;
@property (nonatomic) dispatch_queue_t  socketQueue;
@property (nonatomic,copy) socketIncomingData incoming;
@property (nonatomic,copy) socketDidClosedSocket didClosedSocket;
@property (nonatomic) dispatch_source_t socketSource;
-(instancetype)initWithFD:(int)fd remoteaddr:(NSString*)addr port:(int)port;
-(void)startWithIncoming:(socketDidClosedSocket)incoming;
-(void)close;
@end
