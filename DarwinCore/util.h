//
//  util.h
//  tls_client
//
//  Created by yarshure on 2018/1/15.
//  Copyright © 2018年 yarshure. All rights reserved.
//

#ifndef util_h
#define util_h

#include <stdio.h>

#include <MacTypes.h>
#include <Security/Security.h>
#include <CoreFoundation/CoreFoundation.h>
CFArrayRef chain_from_der(bool ecdsa, const unsigned char *pkey_der, size_t pkey_der_len, const unsigned char *cert_der, size_t cert_der_len);
void sslOutputDot();
const char *sslGetCipherSuiteString(SSLCipherSuite cs);
//void printSslErrStr(const char *op, OSStatus err);
#endif /* util_h */
