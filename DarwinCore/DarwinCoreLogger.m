//
//  DarwinCore.m
//  DarwinCore
//
//  Created by yarshure on 2017/12/29.
//  Copyright © 2017年 Kong XiangBo. All rights reserved.
//

#import "DarwinCoreLogger.h"

@implementation DarwinCoreLogger 
+ (DarwinCoreLogger*)sharedManager{
    static DarwinCoreLogger *logger = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        logger = [[self alloc] init];
        logger.debugEnable = false;
    });
    return logger;
}
@end
