//
//  SocketServer.h
//  DarwinCore
//
//  Created by yarshure on 2017/9/26.
//  Copyright © 2017年 Kong XiangBo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import  "GCDSocket.h"
// socket server basic class
typedef void (^didAcceptSocket)(GCDSocket *socket);


@interface SocketServer : NSObject
//use for shutdown

@property (nonatomic) dispatch_queue_t  dispatchQueue;
//@property (nonatomic) dispatch_queue_t  socketQueue;
@property (nonatomic) dispatch_source_t socketSource;
@property (nonatomic) int sfd;
@property (nonatomic) NSInteger lport;
@property (nonatomic, copy) didAcceptSocket accept;
@property (nonatomic) bool accepting_requests;
-(instancetype)initWith:(NSInteger)port queue:(dispatch_queue_t)queue;
-(void)start;
-(void)stop;

@end
