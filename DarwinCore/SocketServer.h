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
typedef void (^serverDidAcceptSocket)(GCDSocket *socket);


@interface SocketServer : NSObject
//use for shutdown

@property (nonatomic) dispatch_queue_t  dispatchQueue;
//@property (nonatomic) dispatch_queue_t  socketQueue;

@property (nonatomic) GCDSocket *socket;
@property (nonatomic) BOOL share;

-(instancetype)initWith:(int)port dispatchQueue:(dispatch_queue_t)queue socketQueue:(dispatch_queue_t)squeue share:(BOOL)share;
-(void)startWith:(serverDidAcceptSocket)block;
-(void)stop;
-(void)pause;
@end
