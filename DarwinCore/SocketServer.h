//
//  SocketServer.h
//  DarwinCore
//
//  Created by yarshure on 2017/9/26.
//  Copyright © 2017年 Kong XiangBo. All rights reserved.
//

#import <Foundation/Foundation.h>

// socket server basic class
@interface SocketServer : NSObject
//use for shutdown

@property (nonatomic) dispatch_queue_t  dispatchQueue;



@end
