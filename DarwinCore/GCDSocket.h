//
//  GCDSocket.h
//  DarwinCore
//
//  Created by yarshure on 2017/9/26.
//  Copyright © 2017年 Kong XiangBo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GCDSocket : NSObject
@property (nonatomic) int sfd;
@property (nonatomic) dispatch_queue_t  dispatchQueue;
@property (nonatomic) dispatch_queue_t  socketQueue;
-(instancetype)initWithFD:(int)fd;
@end
