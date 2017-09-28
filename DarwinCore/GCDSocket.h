//
//  GCDSocket.h
//  DarwinCore
//
//  Created by yarshure on 2017/9/26.
//  Copyright © 2017年 Kong XiangBo. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GCDSocket;
typedef void (^incomingData)(GCDSocket *socket,NSData *  data);
typedef void (^didClosedSocket)(GCDSocket *socket);

@interface GCDSocket : NSObject
@property (nonatomic) int sfd;
@property (nonatomic,strong ) NSString *remote;
@property (nonatomic) int port;
@property (nonatomic) dispatch_queue_t  dispatchQueue;
@property (nonatomic) dispatch_queue_t  socketQueue;
@property (nonatomic,copy) incomingData incoming;
@property (nonatomic,copy) didClosedSocket didClosedSocket;
@property (nonatomic) dispatch_source_t socketSource;
-(instancetype)initWithFD:(int)fd remoteaddr:(NSString*)addr port:(int)port;
-(void)startWithIncoming:(incomingData)incoming;
-(void)close;
@end
