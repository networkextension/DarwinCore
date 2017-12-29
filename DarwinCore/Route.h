//
//  Route.h
//  DarwinCore
//
//  Created by 孔祥波 on 16/11/2016.
//  Copyright © 2016 Kong XiangBo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Route : NSObject
+ ( NSString* _Nonnull ) currntRouterInet4:(BOOL)isV4 defaultRouter:(BOOL)d;

@end

