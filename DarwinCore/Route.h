//
//  Route.h
//  DarwinCore
//
//  Created by 孔祥波 on 16/11/2016.
//  Copyright © 2016 Kong XiangBo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Route : NSObject
+ (NSString*) currntRouter;
@end
NSData* ipHeader(int len,__uint32_t src,__uint32_t dst,__uint16_t iden, u_char p);
