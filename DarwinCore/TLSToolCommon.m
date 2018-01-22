//
//  TLSToolCommon.m
//  DarwinCore
//
//  Created by yarshure on 2018/1/20.
//  Copyright © 2018年 Kong XiangBo. All rights reserved.
//

#import "TLSToolCommon.h"
#import "QHex.h"
#import "TLSUtilities.h"
@implementation TLSToolCommon
/*! Returns the set of certificates from the TLS handshake.
 
 When you get a trust object via `kCFStreamPropertySSLPeerTrust`, someone has already
 evaluated that trust for you (that's not API, btw, but a compatibility measure).  That
 makes it hard to distinguish between the certificates given to you by the server and
 the certificates found via trust evaluation.  That's distinction is important because
 trust evaluation can work differently on different platforms.  For example, iOS doesn't
 automatically find intermediate certificates via the Authority Information Access
 (1.3.6.1.5.5.7.1.1) extension but OS X, where this code is running, does.  There's no
 way to ask the trust object for the set of certificates it was created with, so instead
 we get that set from the SSLContext.  That requires us to use a deprecated, and not
 available on iOS, API, SSLCopyPeerCertificates.  That's not a big deal here because
 we're just a debugging tool.
 */
- (NSSet *)certificatesFromHandshake:(SSLContextRef)context {
    OSStatus        err;
    NSSet *         result;
    
    CFArrayRef      contextCertificates;
    
    result = nil;
    
   
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    
    err = SSLCopyPeerCertificates(context, &contextCertificates);
    
#pragma clang diagnostic pop
    
    if (err == errSecSuccess) {
        result = [NSSet setWithArray:(__bridge NSArray *) contextCertificates];
        
        CFRelease(contextCertificates);
    }
    
    if (result == nil) {
        result = [NSSet set];
    }
    
    return result;
}
- (void)logCertificateInfoForTrust:(SecTrustRef)trust context:(SSLContextRef)context  {
    NSSet *             handshakeCertificates;
    CFIndex             certificateCount;
    CFIndex             certificateIndex;
    
    [self logWithFormat:@"certificate info:"];
    handshakeCertificates = [self certificatesFromHandshake:context];
    certificateCount = SecTrustGetCertificateCount(trust);
    for (certificateIndex = 0; certificateIndex < certificateCount; certificateIndex++) {
        SecCertificateRef   certificate;
        BOOL                cameFromHandshake;
        
        certificate = SecTrustGetCertificateAtIndex(trust, certificateIndex);
        
        cameFromHandshake = [handshakeCertificates containsObject:(__bridge id) certificate];
        
        [self logWithFormat:@"  %zu %@ %@ %@ %@ '%@'",
         (size_t) certificateIndex,
         cameFromHandshake ? @"+" : @" ",
         [TLSUtilities keyAlgorithmStringForCertificate:certificate],
         [TLSUtilities keyBitSizeStringForCertificate:certificate],
         [TLSUtilities signatureAlgorithmStringForCertificate:certificate],
         CFBridgingRelease( SecCertificateCopySubjectSummary( certificate ) )
         ];
    }
}
- (NSMutableArray<NSData*>*)logCertificateDataForTrust:(SecTrustRef)trust{
    CFIndex             certificateCount;
    CFIndex             certificateIndex;
    
    
    certificateCount = SecTrustGetCertificateCount(trust);
    NSMutableArray<NSData*> *array= [NSMutableArray arrayWithCapacity:certificateCount];
    for (certificateIndex = 0; certificateIndex < certificateCount; certificateIndex++) {
       
         
        NSData *d=CFBridgingRelease( SecCertificateCopyData( SecTrustGetCertificateAtIndex(trust, certificateIndex) ) );
        [array addObject:d];
        
    }
    return array;
}
- (void)logTrustDetails:(SecTrustRef)trust context:(SSLContextRef)context {
    OSStatus            err;
    
    SecTrustResultType  trustResult;
    if (trust == nil) {
        [self logWithFormat:@"no trust"];
    } else {
        err = SecTrustEvaluate(trust, &trustResult);
        if (err != errSecSuccess) {
            [self logWithFormat:@"trust evaluation failed: %d", (int) err];
        } else {
            [self logWithFormat:@"trust result: %@", [TLSUtilities stringForTrustResult:trustResult]];
            [self logCertificateInfoForTrust:trust context:context];
            [self logCertificateDataForTrust:trust];
        }
    }
}
- (void)logWithFormat:(NSString *)format, ... {
    va_list             ap;
    NSString *          str;
    NSMutableArray *    lines;
    
    // assert([self runningOnOwnQueue]);        -- We specifically allow this off the standard queue.
    
    va_start(ap, format);
    str = [[NSString alloc] initWithFormat:format arguments:ap];
    va_end(ap);
    
    lines = [[NSMutableArray alloc] init];
    [str enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
#pragma unused(stop)
        [lines addObject:[[NSString alloc] initWithFormat:@"* %@\n", line]];
    }];
    (void) fprintf(stdout, "%s", [lines componentsJoinedByString:@""].UTF8String);
    (void) fflush(stdout);
}
-(void)importCertificateToKeychain:(NSData *)data
                      withPassword:(NSString *)password
                              name:(NSString *)name {
    CFArrayRef importedItems = NULL;
    OSStatus err;
  
    err = SecPKCS12Import(
                          (__bridge CFDataRef) data,
                          (__bridge CFDictionaryRef) [NSDictionary dictionaryWithObjectsAndKeys:
                                                      password, kSecImportExportPassphrase,
                                                      nil
                                                      ],
                          &importedItems
                          );
    if (err == noErr) {
        
        for (NSDictionary * itemDict in (__bridge id) importedItems) {
            SecIdentityRef  identity;
            
            identity = (__bridge SecIdentityRef) [itemDict objectForKey:(__bridge NSString *) kSecImportItemIdentity];
            
            NSMutableDictionary *addItemDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                      (__bridge id)identity, kSecValueRef,
                                                      nil
                                                      ];
            [addItemDictionary setValue:name forKey:(__bridge NSString *)kSecAttrLabel];
            
            err = SecItemAdd((__bridge CFDictionaryRef)addItemDictionary, NULL);
        }
    }
}
@end
/*! Searches the keychain and returns an identity for the specified name.
 *  \details It first looks for an exact match, then looks for a fuzzy
 *  match (a case and diacritical insensitive substring).
 *  \param arg The name to look for; may be NULL, which guarantees failure.
 *  \param identityPtr A pointer to a place to store the identity; must not be NULL;
 *  on call, the value is ignored; on success, this will be an identity that the
 *  caller must release; on failure, the value is unmodified.
 *  \returns EXIT_SUCCESS on success; EXIT_FAILURE otherwise.
 */

static int ParseIdentityNamed(const char * arg, SecIdentityRef * identityPtr) {
    NSString *      argStr;
    OSStatus        err;
    CFArrayRef      copyMatchingResult;
    SecIdentityRef  identity;
    
    identity = nil;
    
    if (arg != NULL) {
        argStr = @(arg);
        if (argStr != nil) {
            err = SecItemCopyMatching((__bridge CFDictionaryRef) @{
                                                                   (__bridge id) kSecClass:            (__bridge id) kSecClassIdentity,
                                                                   (__bridge id) kSecReturnRef:        @YES,
                                                                   (__bridge id) kSecReturnAttributes: @YES,
                                                                   (__bridge id) kSecMatchLimit:       (__bridge id) kSecMatchLimitAll
                                                                   },
                                      (CFTypeRef *) &copyMatchingResult
                                      );
            if (err == errSecSuccess) {
                NSArray *       matchResults;
                NSUInteger      matchIndex;
                
                matchResults = CFBridgingRelease( copyMatchingResult );
                
                // First look for an exact match.
                
                matchIndex = [matchResults indexOfObjectPassingTest:^BOOL(NSDictionary * matchDict, NSUInteger idx, BOOL *stop) {
#pragma unused(idx)
#pragma unused(stop)
                    return [matchDict[ (__bridge id) kSecAttrLabel ] isEqual:argStr];
                }];
                
                // If that fails, try a fuzzy match.
                
                if (matchIndex == NSNotFound) {
                    matchIndex = [matchResults indexOfObjectPassingTest:^BOOL(NSDictionary * matchDict, NSUInteger idx, BOOL *stop) {
#pragma unused(idx)
#pragma unused(stop)
                        return [matchDict[ (__bridge id) kSecAttrLabel ] rangeOfString:argStr options:NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch].location != NSNotFound;
                    }];
                }
                
                if (matchIndex != NSNotFound) {
                    identity = (__bridge SecIdentityRef) matchResults[matchIndex][ (__bridge id) kSecValueRef];
                    assert(CFGetTypeID(identity) == SecIdentityGetTypeID());
                    CFRetain(identity);
                }
            }
        }
    }
    
    if (identity != NULL) {
        *identityPtr = identity;
    }
    return identity != NULL ? EXIT_SUCCESS : EXIT_FAILURE;
}
/*! Parse a certificate name, search the keychain for that certificate, and
 *  add it to the specified array.
 *  \param arg The protocol string; may be NULL, which guarantees failure.
 *  \param certificates An array to add the certificate too; must not be NULL.
 *  \returns EXIT_SUCCESS on success; EXIT_FAILURE otherwise.
 */

static int ParseAndAddCertificate(const char * arg, NSMutableArray * certificates) {
    SecCertificateRef   certificate;
    NSString *          argStr;
    OSStatus            err;
    
    certificate = NULL;
    if (arg != NULL) {
        argStr = @(arg);
        if (argStr != nil) {
            err = SecItemCopyMatching( (__bridge CFDictionaryRef) @{
                                                                    (__bridge id) kSecClass:            (__bridge id) kSecClassCertificate,
                                                                    (__bridge id) kSecReturnRef:        @YES,
                                                                    (__bridge id) kSecAttrLabel:        argStr
                                                                    }, (CFTypeRef *) &certificate);
            if (err == errSecSuccess) {
                [certificates addObject:(__bridge id) certificate];
                CFRelease(certificate);
            }
        }
    }
    return certificate != NULL ? EXIT_SUCCESS : EXIT_FAILURE;
}

