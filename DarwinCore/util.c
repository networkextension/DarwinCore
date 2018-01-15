//
//  util.c
//  tls_client
//
//  Created by yarshure on 2018/1/15.
//  Copyright © 2018年 yarshure. All rights reserved.
//

#include "util.h"
#include <sys/time.h>
#include <Security/SecKey.h>
void printSslErrStr(const char *op, OSStatus err){
    printf("%s:%d",op,err);
}
/* print a '.' every few seconds to keep UI alive while connecting */
static time_t lastTime = (time_t)0;
#define TIME_INTERVAL        3

void sslOutputDot()
{
    time_t thisTime = time(0);
    
    if((thisTime - lastTime) >= TIME_INTERVAL) {
        printf("."); fflush(stdout);
        lastTime = thisTime;
    }
}

SecKeyRef create_private_key_from_der(bool ecdsa, const unsigned char *pkey_der, size_t pkey_der_len)
{
    SecKeyRef privKey;
    CFErrorRef error = NULL;
    CFDataRef keyData = CFDataCreate(kCFAllocatorDefault, pkey_der, pkey_der_len);
    CFMutableDictionaryRef parameters = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, NULL, NULL);
    CFDictionarySetValue(parameters, kSecAttrKeyType, ecdsa?kSecAttrKeyTypeECSECPrimeRandom:kSecAttrKeyTypeRSA);
    CFDictionarySetValue(parameters, kSecAttrKeyClass, kSecAttrKeyClassPrivate);
    privKey = SecKeyCreateWithData(keyData, parameters, &error);
    CFRelease(keyData);
    CFRelease(parameters);
    
    return privKey;
}
CFArrayRef chain_from_der(bool ecdsa, const unsigned char *pkey_der, size_t pkey_der_len, const unsigned char *cert_der, size_t cert_der_len)
{
    SecKeyRef pkey = NULL;
    SecCertificateRef cert = NULL;
    SecIdentityRef ident = NULL;
    CFArrayRef items = NULL;
    
//    pkey = create_private_key_from_der(ecdsa, pkey_der, pkey_der_len);
//    cert = SecCertificateCreateWithBytes(kCFAllocatorDefault, cert_der, cert_der_len);
//    //result = SecIdentityCreateWithCertificate(kCFAllocatorDefault, cert,
//    //                                          &pkey);
//
//    //SecIdentityCreateWithCertificate(nil, cert, &ident);
//    ident = SecIdentityCreate(kCFAllocatorDefault, cert, pkey);
//    items = CFArrayCreate(kCFAllocatorDefault, (const void **)&ident, 1, &kCFTypeArrayCallBacks);
//   
    
//errOut:
//    CFReleaseSafe(pkey);
//    CFReleaseSafe(cert);
//    CFReleaseSafe(ident);
    return items;
}

const char *sslGetCipherSuiteString(SSLCipherSuite cs)
{
    static char noSuite[40];
    
    switch (cs) {
            /* TLS cipher suites, RFC 2246 */
        case SSL_NULL_WITH_NULL_NULL:               return "TLS_NULL_WITH_NULL_NULL";
        case SSL_RSA_WITH_NULL_MD5:                 return "TLS_RSA_WITH_NULL_MD5";
        case SSL_RSA_WITH_NULL_SHA:                 return "TLS_RSA_WITH_NULL_SHA";
        case SSL_RSA_EXPORT_WITH_RC4_40_MD5:        return "TLS_RSA_EXPORT_WITH_RC4_40_MD5";
        case SSL_RSA_WITH_RC4_128_MD5:              return "TLS_RSA_WITH_RC4_128_MD5";
        case SSL_RSA_WITH_RC4_128_SHA:              return "TLS_RSA_WITH_RC4_128_SHA";
        case SSL_RSA_EXPORT_WITH_RC2_CBC_40_MD5:    return "TLS_RSA_EXPORT_WITH_RC2_CBC_40_MD5";
        case SSL_RSA_WITH_IDEA_CBC_SHA:             return "TLS_RSA_WITH_IDEA_CBC_SHA";
        case SSL_RSA_EXPORT_WITH_DES40_CBC_SHA:     return "TLS_RSA_EXPORT_WITH_DES40_CBC_SHA";
        case SSL_RSA_WITH_DES_CBC_SHA:              return "TLS_RSA_WITH_DES_CBC_SHA";
        case SSL_RSA_WITH_3DES_EDE_CBC_SHA:         return "TLS_RSA_WITH_3DES_EDE_CBC_SHA";
        case SSL_DH_DSS_EXPORT_WITH_DES40_CBC_SHA:  return "TLS_DH_DSS_EXPORT_WITH_DES40_CBC_SHA";
        case SSL_DH_DSS_WITH_DES_CBC_SHA:           return "TLS_DH_DSS_WITH_DES_CBC_SHA";
        case SSL_DH_DSS_WITH_3DES_EDE_CBC_SHA:      return "TLS_DH_DSS_WITH_3DES_EDE_CBC_SHA";
        case SSL_DH_RSA_EXPORT_WITH_DES40_CBC_SHA:  return "TLS_DH_RSA_EXPORT_WITH_DES40_CBC_SHA";
        case SSL_DH_RSA_WITH_DES_CBC_SHA:           return "TLS_DH_RSA_WITH_DES_CBC_SHA";
        case SSL_DH_RSA_WITH_3DES_EDE_CBC_SHA:      return "TLS_DH_RSA_WITH_3DES_EDE_CBC_SHA";
        case SSL_DHE_DSS_EXPORT_WITH_DES40_CBC_SHA: return "TLS_DHE_DSS_EXPORT_WITH_DES40_CBC_SHA";
        case SSL_DHE_DSS_WITH_DES_CBC_SHA:          return "TLS_DHE_DSS_WITH_DES_CBC_SHA";
        case SSL_DHE_DSS_WITH_3DES_EDE_CBC_SHA:     return "TLS_DHE_DSS_WITH_3DES_EDE_CBC_SHA";
        case SSL_DHE_RSA_EXPORT_WITH_DES40_CBC_SHA: return "TLS_DHE_RSA_EXPORT_WITH_DES40_CBC_SHA";
        case SSL_DHE_RSA_WITH_DES_CBC_SHA:          return "TLS_DHE_RSA_WITH_DES_CBC_SHA";
        case SSL_DHE_RSA_WITH_3DES_EDE_CBC_SHA:     return "TLS_DHE_RSA_WITH_3DES_EDE_CBC_SHA";
        case SSL_DH_anon_EXPORT_WITH_RC4_40_MD5:    return "TLS_DH_anon_EXPORT_WITH_RC4_40_MD5";
        case SSL_DH_anon_WITH_RC4_128_MD5:          return "TLS_DH_anon_WITH_RC4_128_MD5";
        case SSL_DH_anon_EXPORT_WITH_DES40_CBC_SHA: return "TLS_DH_anon_EXPORT_WITH_DES40_CBC_SHA";
        case SSL_DH_anon_WITH_DES_CBC_SHA:          return "TLS_DH_anon_WITH_DES_CBC_SHA";
        case SSL_DH_anon_WITH_3DES_EDE_CBC_SHA:     return "TLS_DH_anon_WITH_3DES_EDE_CBC_SHA";
            
            /* SSLv3 Fortezza cipher suites, from NSS */
        case SSL_FORTEZZA_DMS_WITH_NULL_SHA:        return "SSL_FORTEZZA_DMS_WITH_NULL_SHA";
        case SSL_FORTEZZA_DMS_WITH_FORTEZZA_CBC_SHA:return "SSL_FORTEZZA_DMS_WITH_FORTEZZA_CBC_SHA";
            
            /* TLS addenda using AES-CBC, RFC 3268 */
        case TLS_RSA_WITH_AES_128_CBC_SHA:          return "TLS_RSA_WITH_AES_128_CBC_SHA";
        case TLS_DH_DSS_WITH_AES_128_CBC_SHA:       return "TLS_DH_DSS_WITH_AES_128_CBC_SHA";
        case TLS_DH_RSA_WITH_AES_128_CBC_SHA:       return "TLS_DH_RSA_WITH_AES_128_CBC_SHA";
        case TLS_DHE_DSS_WITH_AES_128_CBC_SHA:      return "TLS_DHE_DSS_WITH_AES_128_CBC_SHA";
        case TLS_DHE_RSA_WITH_AES_128_CBC_SHA:      return "TLS_DHE_RSA_WITH_AES_128_CBC_SHA";
        case TLS_DH_anon_WITH_AES_128_CBC_SHA:      return "TLS_DH_anon_WITH_AES_128_CBC_SHA";
        case TLS_RSA_WITH_AES_256_CBC_SHA:          return "TLS_RSA_WITH_AES_256_CBC_SHA";
        case TLS_DH_DSS_WITH_AES_256_CBC_SHA:       return "TLS_DH_DSS_WITH_AES_256_CBC_SHA";
        case TLS_DH_RSA_WITH_AES_256_CBC_SHA:       return "TLS_DH_RSA_WITH_AES_256_CBC_SHA";
        case TLS_DHE_DSS_WITH_AES_256_CBC_SHA:      return "TLS_DHE_DSS_WITH_AES_256_CBC_SHA";
        case TLS_DHE_RSA_WITH_AES_256_CBC_SHA:      return "TLS_DHE_RSA_WITH_AES_256_CBC_SHA";
        case TLS_DH_anon_WITH_AES_256_CBC_SHA:      return "TLS_DH_anon_WITH_AES_256_CBC_SHA";
            
            /* ECDSA addenda, RFC 4492 */
        case TLS_ECDH_ECDSA_WITH_NULL_SHA:          return "TLS_ECDH_ECDSA_WITH_NULL_SHA";
        case TLS_ECDH_ECDSA_WITH_RC4_128_SHA:       return "TLS_ECDH_ECDSA_WITH_RC4_128_SHA";
        case TLS_ECDH_ECDSA_WITH_3DES_EDE_CBC_SHA:  return "TLS_ECDH_ECDSA_WITH_3DES_EDE_CBC_SHA";
        case TLS_ECDH_ECDSA_WITH_AES_128_CBC_SHA:   return "TLS_ECDH_ECDSA_WITH_AES_128_CBC_SHA";
        case TLS_ECDH_ECDSA_WITH_AES_256_CBC_SHA:   return "TLS_ECDH_ECDSA_WITH_AES_256_CBC_SHA";
        case TLS_ECDHE_ECDSA_WITH_NULL_SHA:         return "TLS_ECDHE_ECDSA_WITH_NULL_SHA";
        case TLS_ECDHE_ECDSA_WITH_RC4_128_SHA:      return "TLS_ECDHE_ECDSA_WITH_RC4_128_SHA";
        case TLS_ECDHE_ECDSA_WITH_3DES_EDE_CBC_SHA: return "TLS_ECDHE_ECDSA_WITH_3DES_EDE_CBC_SHA";
        case TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA:  return "TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA";
        case TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA:  return "TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA";
        case TLS_ECDH_RSA_WITH_NULL_SHA:            return "TLS_ECDH_RSA_WITH_NULL_SHA";
        case TLS_ECDH_RSA_WITH_RC4_128_SHA:         return "TLS_ECDH_RSA_WITH_RC4_128_SHA";
        case TLS_ECDH_RSA_WITH_3DES_EDE_CBC_SHA:    return "TLS_ECDH_RSA_WITH_3DES_EDE_CBC_SHA";
        case TLS_ECDH_RSA_WITH_AES_128_CBC_SHA:     return "TLS_ECDH_RSA_WITH_AES_128_CBC_SHA";
        case TLS_ECDH_RSA_WITH_AES_256_CBC_SHA:     return "TLS_ECDH_RSA_WITH_AES_256_CBC_SHA";
        case TLS_ECDHE_RSA_WITH_NULL_SHA:           return "TLS_ECDHE_RSA_WITH_NULL_SHA";
        case TLS_ECDHE_RSA_WITH_RC4_128_SHA:        return "TLS_ECDHE_RSA_WITH_RC4_128_SHA";
        case TLS_ECDHE_RSA_WITH_3DES_EDE_CBC_SHA:   return "TLS_ECDHE_RSA_WITH_3DES_EDE_CBC_SHA";
        case TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA:    return "TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA";
        case TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA:    return "TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA";
        case TLS_ECDH_anon_WITH_NULL_SHA:           return "TLS_ECDH_anon_WITH_NULL_SHA";
        case TLS_ECDH_anon_WITH_RC4_128_SHA:        return "TLS_ECDH_anon_WITH_RC4_128_SHA";
        case TLS_ECDH_anon_WITH_3DES_EDE_CBC_SHA:   return "TLS_ECDH_anon_WITH_3DES_EDE_CBC_SHA";
        case TLS_ECDH_anon_WITH_AES_128_CBC_SHA:    return "TLS_ECDH_anon_WITH_AES_128_CBC_SHA";
        case TLS_ECDH_anon_WITH_AES_256_CBC_SHA:    return "TLS_ECDH_anon_WITH_AES_256_CBC_SHA";
            
            /* TLS 1.2 addenda, RFC 5246 */
        case TLS_RSA_WITH_AES_128_CBC_SHA256:       return "TLS_RSA_WITH_AES_128_CBC_SHA256";
        case TLS_RSA_WITH_AES_256_CBC_SHA256:       return "TLS_RSA_WITH_AES_256_CBC_SHA256";
        case TLS_DH_DSS_WITH_AES_128_CBC_SHA256:    return "TLS_DH_DSS_WITH_AES_128_CBC_SHA256";
        case TLS_DH_RSA_WITH_AES_128_CBC_SHA256:    return "TLS_DH_RSA_WITH_AES_128_CBC_SHA256";
        case TLS_DHE_DSS_WITH_AES_128_CBC_SHA256:   return "TLS_DHE_DSS_WITH_AES_128_CBC_SHA256";
        case TLS_DHE_RSA_WITH_AES_128_CBC_SHA256:   return "TLS_DHE_RSA_WITH_AES_128_CBC_SHA256";
        case TLS_DH_DSS_WITH_AES_256_CBC_SHA256:    return "TLS_DH_DSS_WITH_AES_256_CBC_SHA256";
        case TLS_DH_RSA_WITH_AES_256_CBC_SHA256:    return "TLS_DH_RSA_WITH_AES_256_CBC_SHA256";
        case TLS_DHE_DSS_WITH_AES_256_CBC_SHA256:   return "TLS_DHE_DSS_WITH_AES_256_CBC_SHA256";
        case TLS_DHE_RSA_WITH_AES_256_CBC_SHA256:   return "TLS_DHE_RSA_WITH_AES_256_CBC_SHA256";
        case TLS_DH_anon_WITH_AES_128_CBC_SHA256:   return "TLS_DH_anon_WITH_AES_128_CBC_SHA256";
        case TLS_DH_anon_WITH_AES_256_CBC_SHA256:   return "TLS_DH_anon_WITH_AES_256_CBC_SHA256";
            
            /* TLS addenda using AES-GCM, RFC 5288 */
        case TLS_RSA_WITH_AES_128_GCM_SHA256:       return "TLS_RSA_WITH_AES_128_GCM_SHA256";
        case TLS_RSA_WITH_AES_256_GCM_SHA384:       return "TLS_DHE_RSA_WITH_AES_128_GCM_SHA256";
        case TLS_DHE_RSA_WITH_AES_128_GCM_SHA256:   return "TLS_DHE_RSA_WITH_AES_128_GCM_SHA256";
        case TLS_DHE_RSA_WITH_AES_256_GCM_SHA384:   return "TLS_DHE_RSA_WITH_AES_256_GCM_SHA384";
        case TLS_DH_RSA_WITH_AES_128_GCM_SHA256:    return "TLS_DH_RSA_WITH_AES_128_GCM_SHA256";
        case TLS_DH_RSA_WITH_AES_256_GCM_SHA384:    return "TLS_DH_RSA_WITH_AES_256_GCM_SHA384";
        case TLS_DHE_DSS_WITH_AES_128_GCM_SHA256:   return "TLS_DHE_DSS_WITH_AES_128_GCM_SHA256";
        case TLS_DHE_DSS_WITH_AES_256_GCM_SHA384:   return "TLS_DHE_DSS_WITH_AES_256_GCM_SHA384";
        case TLS_DH_DSS_WITH_AES_128_GCM_SHA256:    return "TLS_DH_DSS_WITH_AES_128_GCM_SHA256";
        case TLS_DH_DSS_WITH_AES_256_GCM_SHA384:    return "TLS_DH_DSS_WITH_AES_256_GCM_SHA384";
        case TLS_DH_anon_WITH_AES_128_GCM_SHA256:   return "TLS_DH_anon_WITH_AES_128_GCM_SHA256";
        case TLS_DH_anon_WITH_AES_256_GCM_SHA384:   return "TLS_DH_anon_WITH_AES_256_GCM_SHA384";
            
            /* ECDSA addenda, RFC 5289 */
        case TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256:   return "TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256";
        case TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA384:   return "TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA384";
        case TLS_ECDH_ECDSA_WITH_AES_128_CBC_SHA256:    return "TLS_ECDH_ECDSA_WITH_AES_128_CBC_SHA256";
        case TLS_ECDH_ECDSA_WITH_AES_256_CBC_SHA384:    return "TLS_ECDH_ECDSA_WITH_AES_256_CBC_SHA384";
        case TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256:     return "TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256";
        case TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384:     return "TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384";
        case TLS_ECDH_RSA_WITH_AES_128_CBC_SHA256:      return "TLS_ECDH_RSA_WITH_AES_128_CBC_SHA256";
        case TLS_ECDH_RSA_WITH_AES_256_CBC_SHA384:      return "TLS_ECDH_RSA_WITH_AES_256_CBC_SHA384";
        case TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256:   return "TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256";
        case TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384:   return "TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384";
        case TLS_ECDH_ECDSA_WITH_AES_128_GCM_SHA256:    return "TLS_ECDH_ECDSA_WITH_AES_128_GCM_SHA256";
        case TLS_ECDH_ECDSA_WITH_AES_256_GCM_SHA384:    return "TLS_ECDH_ECDSA_WITH_AES_256_GCM_SHA384";
        case TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256:     return "TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256";
        case TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384:     return "TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384";
        case TLS_ECDH_RSA_WITH_AES_128_GCM_SHA256:      return "TLS_ECDH_RSA_WITH_AES_128_GCM_SHA256";
        case TLS_ECDH_RSA_WITH_AES_256_GCM_SHA384:      return "TLS_ECDH_RSA_WITH_AES_256_GCM_SHA384";
            
            /*
             * Tags for SSL 2 cipher kinds which are not specified for SSL 3.
             */
        case SSL_RSA_WITH_RC2_CBC_MD5:              return "TLS_RSA_WITH_RC2_CBC_MD5";
        case SSL_RSA_WITH_IDEA_CBC_MD5:             return "TLS_RSA_WITH_IDEA_CBC_MD5";
        case SSL_RSA_WITH_DES_CBC_MD5:              return "TLS_RSA_WITH_DES_CBC_MD5";
        case SSL_RSA_WITH_3DES_EDE_CBC_MD5:         return "TLS_RSA_WITH_3DES_EDE_CBC_MD5";
        case SSL_NO_SUCH_CIPHERSUITE:               return "SSL_NO_SUCH_CIPHERSUITE";
            
        default:
            snprintf(noSuite, sizeof(noSuite), "Unknown ciphersuite 0x%04x", (unsigned)cs);
            return noSuite;
    }
}
