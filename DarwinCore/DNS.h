//
//  DNS.h
//  DarwinCore
//
//  Created by 孔祥波 on 16/11/2016.
//  Copyright © 2016 Kong XiangBo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DNS : NSObject
+(NSArray<NSString*> *)loadSystemDNSServer;
@end
