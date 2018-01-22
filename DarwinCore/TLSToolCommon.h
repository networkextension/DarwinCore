//
//  TLSToolCommon.h
//  DarwinCore
//
//  Created by yarshure on 2018/1/20.
//  Copyright © 2018年 Kong XiangBo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Security/Security.h>
@interface TLSToolCommon : NSObject
- (NSSet *)certificatesFromHandshake:(SSLContextRef)context;
- (void)logCertificateInfoForTrust:(SecTrustRef)trust context:(SSLContextRef)context;
-(NSMutableArray<NSData*>*)logCertificateDataForTrust:(SecTrustRef)trust ;
- (void)logTrustDetails:(SecTrustRef)trust context:(SSLContextRef)context ;
-(void)importCertificateToKeychain:(NSURL *)url
                      withPassword:(NSString *)password
                              name:(NSString *)name;
@end
static int ParseIdentityNamed(const char * arg, SecIdentityRef * identityPtr);
static int ParseAndAddCertificate(const char * arg, NSMutableArray * certificates);
