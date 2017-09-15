//
//  XTLS.h
//  DarwinCore
//
//  Created by yarshure on 2017/9/15.
//  Copyright © 2017年 Kong XiangBo. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <Security/Security.h>
#include <Security/SecureTransport.h>



#import "ioSock.h"
@interface XTLS : NSObject {
    NSString *_deviceToken, *_payload;
    otSocket _socket;
    SSLContextRef _contextRef;
    SecKeychainRef _keychainRef;
    SecCertificateRef _certificateRef;
    SecIdentityRef _identityRef;
    NSString * _aps;
    NSString * _apsDevelopment;
    NSInteger _app;
    BOOL _production;
    NSString * _certificatePath;
}
@property(nonatomic, retain) NSString *deviceToken, *payload;
@end
