/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    Utilities routines used by various subsystems.
 */

#import "TLSUtilities.h"

@implementation TLSUtilities

+ (NSString *)stringForCipherSuite:(SSLCipherSuite)cipher {
    NSString *      result;
    
    // The following table was built from <Security/CipherSuite.h> with appropriate massaging. 
    // In cases where the SSL and TLS constants are the same, I prefer the TLS one.
    
    switch (cipher) {
        default: {
            result = [NSString stringWithFormat:@"unexpected (0x%u)", (unsigned int) cipher];
        } break;
        // case SSL_NULL_WITH_NULL_NULL: cipherStr = @"NULL_WITH_NULL_NULL"; break;
        // case SSL_RSA_WITH_NULL_MD5: cipherStr = @"RSA_WITH_NULL_MD5"; break;
        // case SSL_RSA_WITH_NULL_SHA: cipherStr = @"RSA_WITH_NULL_SHA"; break;
        case SSL_RSA_EXPORT_WITH_RC4_40_MD5: result = @"RSA_EXPORT_WITH_RC4_40_MD5"; break;
        // case SSL_RSA_WITH_RC4_128_MD5: cipherStr = @"RSA_WITH_RC4_128_MD5"; break;
        // case SSL_RSA_WITH_RC4_128_SHA: cipherStr = @"RSA_WITH_RC4_128_SHA"; break;
        case SSL_RSA_EXPORT_WITH_RC2_CBC_40_MD5: result = @"RSA_EXPORT_WITH_RC2_CBC_40_MD5"; break;
        case SSL_RSA_WITH_IDEA_CBC_SHA: result = @"RSA_WITH_IDEA_CBC_SHA"; break;
        case SSL_RSA_EXPORT_WITH_DES40_CBC_SHA: result = @"RSA_EXPORT_WITH_DES40_CBC_SHA"; break;
        case SSL_RSA_WITH_DES_CBC_SHA: result = @"RSA_WITH_DES_CBC_SHA"; break;
        // case SSL_RSA_WITH_3DES_EDE_CBC_SHA: cipherStr = @"RSA_WITH_3DES_EDE_CBC_SHA"; break;
        case SSL_DH_DSS_EXPORT_WITH_DES40_CBC_SHA: result = @"DH_DSS_EXPORT_WITH_DES40_CBC_SHA"; break;
        case SSL_DH_DSS_WITH_DES_CBC_SHA: result = @"DH_DSS_WITH_DES_CBC_SHA"; break;
        // case SSL_DH_DSS_WITH_3DES_EDE_CBC_SHA: cipherStr = @"DH_DSS_WITH_3DES_EDE_CBC_SHA"; break;
        case SSL_DH_RSA_EXPORT_WITH_DES40_CBC_SHA: result = @"DH_RSA_EXPORT_WITH_DES40_CBC_SHA"; break;
        case SSL_DH_RSA_WITH_DES_CBC_SHA: result = @"DH_RSA_WITH_DES_CBC_SHA"; break;
        // case SSL_DH_RSA_WITH_3DES_EDE_CBC_SHA: cipherStr = @"DH_RSA_WITH_3DES_EDE_CBC_SHA"; break;
        case SSL_DHE_DSS_EXPORT_WITH_DES40_CBC_SHA: result = @"DHE_DSS_EXPORT_WITH_DES40_CBC_SHA"; break;
        case SSL_DHE_DSS_WITH_DES_CBC_SHA: result = @"DHE_DSS_WITH_DES_CBC_SHA"; break;
        // case SSL_DHE_DSS_WITH_3DES_EDE_CBC_SHA: cipherStr = @"DHE_DSS_WITH_3DES_EDE_CBC_SHA"; break;
        case SSL_DHE_RSA_EXPORT_WITH_DES40_CBC_SHA: result = @"DHE_RSA_EXPORT_WITH_DES40_CBC_SHA"; break;
        case SSL_DHE_RSA_WITH_DES_CBC_SHA: result = @"DHE_RSA_WITH_DES_CBC_SHA"; break;
        // case SSL_DHE_RSA_WITH_3DES_EDE_CBC_SHA: cipherStr = @"DHE_RSA_WITH_3DES_EDE_CBC_SHA"; break;
        case SSL_DH_anon_EXPORT_WITH_RC4_40_MD5: result = @"DH_anon_EXPORT_WITH_RC4_40_MD5"; break;
        // case SSL_DH_anon_WITH_RC4_128_MD5: cipherStr = @"DH_anon_WITH_RC4_128_MD5"; break;
        case SSL_DH_anon_EXPORT_WITH_DES40_CBC_SHA: result = @"DH_anon_EXPORT_WITH_DES40_CBC_SHA"; break;
        case SSL_DH_anon_WITH_DES_CBC_SHA: result = @"DH_anon_WITH_DES_CBC_SHA"; break;
        // case SSL_DH_anon_WITH_3DES_EDE_CBC_SHA: cipherStr = @"DH_anon_WITH_3DES_EDE_CBC_SHA"; break;
        case SSL_FORTEZZA_DMS_WITH_NULL_SHA: result = @"FORTEZZA_DMS_WITH_NULL_SHA"; break;
        case SSL_FORTEZZA_DMS_WITH_FORTEZZA_CBC_SHA: result = @"FORTEZZA_DMS_WITH_FORTEZZA_CBC_SHA"; break;
        case TLS_RSA_WITH_AES_128_CBC_SHA: result = @"RSA_WITH_AES_128_CBC_SHA"; break;
        case TLS_DH_DSS_WITH_AES_128_CBC_SHA: result = @"DH_DSS_WITH_AES_128_CBC_SHA"; break;
        case TLS_DH_RSA_WITH_AES_128_CBC_SHA: result = @"DH_RSA_WITH_AES_128_CBC_SHA"; break;
        case TLS_DHE_DSS_WITH_AES_128_CBC_SHA: result = @"DHE_DSS_WITH_AES_128_CBC_SHA"; break;
        case TLS_DHE_RSA_WITH_AES_128_CBC_SHA: result = @"DHE_RSA_WITH_AES_128_CBC_SHA"; break;
        case TLS_DH_anon_WITH_AES_128_CBC_SHA: result = @"DH_anon_WITH_AES_128_CBC_SHA"; break;
        case TLS_RSA_WITH_AES_256_CBC_SHA: result = @"RSA_WITH_AES_256_CBC_SHA"; break;
        case TLS_DH_DSS_WITH_AES_256_CBC_SHA: result = @"DH_DSS_WITH_AES_256_CBC_SHA"; break;
        case TLS_DH_RSA_WITH_AES_256_CBC_SHA: result = @"DH_RSA_WITH_AES_256_CBC_SHA"; break;
        case TLS_DHE_DSS_WITH_AES_256_CBC_SHA: result = @"DHE_DSS_WITH_AES_256_CBC_SHA"; break;
        case TLS_DHE_RSA_WITH_AES_256_CBC_SHA: result = @"DHE_RSA_WITH_AES_256_CBC_SHA"; break;
        case TLS_DH_anon_WITH_AES_256_CBC_SHA: result = @"DH_anon_WITH_AES_256_CBC_SHA"; break;
        case TLS_ECDH_ECDSA_WITH_NULL_SHA: result = @"ECDH_ECDSA_WITH_NULL_SHA"; break;
        case TLS_ECDH_ECDSA_WITH_RC4_128_SHA: result = @"ECDH_ECDSA_WITH_RC4_128_SHA"; break;
        case TLS_ECDH_ECDSA_WITH_3DES_EDE_CBC_SHA: result = @"ECDH_ECDSA_WITH_3DES_EDE_CBC_SHA"; break;
        case TLS_ECDH_ECDSA_WITH_AES_128_CBC_SHA: result = @"ECDH_ECDSA_WITH_AES_128_CBC_SHA"; break;
        case TLS_ECDH_ECDSA_WITH_AES_256_CBC_SHA: result = @"ECDH_ECDSA_WITH_AES_256_CBC_SHA"; break;
        case TLS_ECDHE_ECDSA_WITH_NULL_SHA: result = @"ECDHE_ECDSA_WITH_NULL_SHA"; break;
        case TLS_ECDHE_ECDSA_WITH_RC4_128_SHA: result = @"ECDHE_ECDSA_WITH_RC4_128_SHA"; break;
        case TLS_ECDHE_ECDSA_WITH_3DES_EDE_CBC_SHA: result = @"ECDHE_ECDSA_WITH_3DES_EDE_CBC_SHA"; break;
        case TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA: result = @"ECDHE_ECDSA_WITH_AES_128_CBC_SHA"; break;
        case TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA: result = @"ECDHE_ECDSA_WITH_AES_256_CBC_SHA"; break;
        case TLS_ECDH_RSA_WITH_NULL_SHA: result = @"ECDH_RSA_WITH_NULL_SHA"; break;
        case TLS_ECDH_RSA_WITH_RC4_128_SHA: result = @"ECDH_RSA_WITH_RC4_128_SHA"; break;
        case TLS_ECDH_RSA_WITH_3DES_EDE_CBC_SHA: result = @"ECDH_RSA_WITH_3DES_EDE_CBC_SHA"; break;
        case TLS_ECDH_RSA_WITH_AES_128_CBC_SHA: result = @"ECDH_RSA_WITH_AES_128_CBC_SHA"; break;
        case TLS_ECDH_RSA_WITH_AES_256_CBC_SHA: result = @"ECDH_RSA_WITH_AES_256_CBC_SHA"; break;
        case TLS_ECDHE_RSA_WITH_NULL_SHA: result = @"ECDHE_RSA_WITH_NULL_SHA"; break;
        case TLS_ECDHE_RSA_WITH_RC4_128_SHA: result = @"ECDHE_RSA_WITH_RC4_128_SHA"; break;
        case TLS_ECDHE_RSA_WITH_3DES_EDE_CBC_SHA: result = @"ECDHE_RSA_WITH_3DES_EDE_CBC_SHA"; break;
        case TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA: result = @"ECDHE_RSA_WITH_AES_128_CBC_SHA"; break;
        case TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA: result = @"ECDHE_RSA_WITH_AES_256_CBC_SHA"; break;
        case TLS_ECDH_anon_WITH_NULL_SHA: result = @"ECDH_anon_WITH_NULL_SHA"; break;
        case TLS_ECDH_anon_WITH_RC4_128_SHA: result = @"ECDH_anon_WITH_RC4_128_SHA"; break;
        case TLS_ECDH_anon_WITH_3DES_EDE_CBC_SHA: result = @"ECDH_anon_WITH_3DES_EDE_CBC_SHA"; break;
        case TLS_ECDH_anon_WITH_AES_128_CBC_SHA: result = @"ECDH_anon_WITH_AES_128_CBC_SHA"; break;
        case TLS_ECDH_anon_WITH_AES_256_CBC_SHA: result = @"ECDH_anon_WITH_AES_256_CBC_SHA"; break;
        case TLS_NULL_WITH_NULL_NULL: result = @"NULL_WITH_NULL_NULL"; break;
        case TLS_RSA_WITH_NULL_MD5: result = @"RSA_WITH_NULL_MD5"; break;
        case TLS_RSA_WITH_NULL_SHA: result = @"RSA_WITH_NULL_SHA"; break;
        case TLS_RSA_WITH_RC4_128_MD5: result = @"RSA_WITH_RC4_128_MD5"; break;
        case TLS_RSA_WITH_RC4_128_SHA: result = @"RSA_WITH_RC4_128_SHA"; break;
        case TLS_RSA_WITH_3DES_EDE_CBC_SHA: result = @"RSA_WITH_3DES_EDE_CBC_SHA"; break;
        case TLS_RSA_WITH_NULL_SHA256: result = @"RSA_WITH_NULL_SHA256"; break;
        case TLS_RSA_WITH_AES_128_CBC_SHA256: result = @"RSA_WITH_AES_128_CBC_SHA256"; break;
        case TLS_RSA_WITH_AES_256_CBC_SHA256: result = @"RSA_WITH_AES_256_CBC_SHA256"; break;
        case TLS_DH_DSS_WITH_3DES_EDE_CBC_SHA: result = @"DH_DSS_WITH_3DES_EDE_CBC_SHA"; break;
        case TLS_DH_RSA_WITH_3DES_EDE_CBC_SHA: result = @"DH_RSA_WITH_3DES_EDE_CBC_SHA"; break;
        case TLS_DHE_DSS_WITH_3DES_EDE_CBC_SHA: result = @"DHE_DSS_WITH_3DES_EDE_CBC_SHA"; break;
        case TLS_DHE_RSA_WITH_3DES_EDE_CBC_SHA: result = @"DHE_RSA_WITH_3DES_EDE_CBC_SHA"; break;
        case TLS_DH_DSS_WITH_AES_128_CBC_SHA256: result = @"DH_DSS_WITH_AES_128_CBC_SHA256"; break;
        case TLS_DH_RSA_WITH_AES_128_CBC_SHA256: result = @"DH_RSA_WITH_AES_128_CBC_SHA256"; break;
        case TLS_DHE_DSS_WITH_AES_128_CBC_SHA256: result = @"DHE_DSS_WITH_AES_128_CBC_SHA256"; break;
        case TLS_DHE_RSA_WITH_AES_128_CBC_SHA256: result = @"DHE_RSA_WITH_AES_128_CBC_SHA256"; break;
        case TLS_DH_DSS_WITH_AES_256_CBC_SHA256: result = @"DH_DSS_WITH_AES_256_CBC_SHA256"; break;
        case TLS_DH_RSA_WITH_AES_256_CBC_SHA256: result = @"DH_RSA_WITH_AES_256_CBC_SHA256"; break;
        case TLS_DHE_DSS_WITH_AES_256_CBC_SHA256: result = @"DHE_DSS_WITH_AES_256_CBC_SHA256"; break;
        case TLS_DHE_RSA_WITH_AES_256_CBC_SHA256: result = @"DHE_RSA_WITH_AES_256_CBC_SHA256"; break;
        case TLS_DH_anon_WITH_RC4_128_MD5: result = @"DH_anon_WITH_RC4_128_MD5"; break;
        case TLS_DH_anon_WITH_3DES_EDE_CBC_SHA: result = @"DH_anon_WITH_3DES_EDE_CBC_SHA"; break;
        case TLS_DH_anon_WITH_AES_128_CBC_SHA256: result = @"DH_anon_WITH_AES_128_CBC_SHA256"; break;
        case TLS_DH_anon_WITH_AES_256_CBC_SHA256: result = @"DH_anon_WITH_AES_256_CBC_SHA256"; break;
        case TLS_PSK_WITH_RC4_128_SHA: result = @"PSK_WITH_RC4_128_SHA"; break;
        case TLS_PSK_WITH_3DES_EDE_CBC_SHA: result = @"PSK_WITH_3DES_EDE_CBC_SHA"; break;
        case TLS_PSK_WITH_AES_128_CBC_SHA: result = @"PSK_WITH_AES_128_CBC_SHA"; break;
        case TLS_PSK_WITH_AES_256_CBC_SHA: result = @"PSK_WITH_AES_256_CBC_SHA"; break;
        case TLS_DHE_PSK_WITH_RC4_128_SHA: result = @"DHE_PSK_WITH_RC4_128_SHA"; break;
        case TLS_DHE_PSK_WITH_3DES_EDE_CBC_SHA: result = @"DHE_PSK_WITH_3DES_EDE_CBC_SHA"; break;
        case TLS_DHE_PSK_WITH_AES_128_CBC_SHA: result = @"DHE_PSK_WITH_AES_128_CBC_SHA"; break;
        case TLS_DHE_PSK_WITH_AES_256_CBC_SHA: result = @"DHE_PSK_WITH_AES_256_CBC_SHA"; break;
        case TLS_RSA_PSK_WITH_RC4_128_SHA: result = @"RSA_PSK_WITH_RC4_128_SHA"; break;
        case TLS_RSA_PSK_WITH_3DES_EDE_CBC_SHA: result = @"RSA_PSK_WITH_3DES_EDE_CBC_SHA"; break;
        case TLS_RSA_PSK_WITH_AES_128_CBC_SHA: result = @"RSA_PSK_WITH_AES_128_CBC_SHA"; break;
        case TLS_RSA_PSK_WITH_AES_256_CBC_SHA: result = @"RSA_PSK_WITH_AES_256_CBC_SHA"; break;
        case TLS_PSK_WITH_NULL_SHA: result = @"PSK_WITH_NULL_SHA"; break;
        case TLS_DHE_PSK_WITH_NULL_SHA: result = @"DHE_PSK_WITH_NULL_SHA"; break;
        case TLS_RSA_PSK_WITH_NULL_SHA: result = @"RSA_PSK_WITH_NULL_SHA"; break;
        case TLS_RSA_WITH_AES_128_GCM_SHA256: result = @"RSA_WITH_AES_128_GCM_SHA256"; break;
        case TLS_RSA_WITH_AES_256_GCM_SHA384: result = @"RSA_WITH_AES_256_GCM_SHA384"; break;
        case TLS_DHE_RSA_WITH_AES_128_GCM_SHA256: result = @"DHE_RSA_WITH_AES_128_GCM_SHA256"; break;
        case TLS_DHE_RSA_WITH_AES_256_GCM_SHA384: result = @"DHE_RSA_WITH_AES_256_GCM_SHA384"; break;
        case TLS_DH_RSA_WITH_AES_128_GCM_SHA256: result = @"DH_RSA_WITH_AES_128_GCM_SHA256"; break;
        case TLS_DH_RSA_WITH_AES_256_GCM_SHA384: result = @"DH_RSA_WITH_AES_256_GCM_SHA384"; break;
        case TLS_DHE_DSS_WITH_AES_128_GCM_SHA256: result = @"DHE_DSS_WITH_AES_128_GCM_SHA256"; break;
        case TLS_DHE_DSS_WITH_AES_256_GCM_SHA384: result = @"DHE_DSS_WITH_AES_256_GCM_SHA384"; break;
        case TLS_DH_DSS_WITH_AES_128_GCM_SHA256: result = @"DH_DSS_WITH_AES_128_GCM_SHA256"; break;
        case TLS_DH_DSS_WITH_AES_256_GCM_SHA384: result = @"DH_DSS_WITH_AES_256_GCM_SHA384"; break;
        case TLS_DH_anon_WITH_AES_128_GCM_SHA256: result = @"DH_anon_WITH_AES_128_GCM_SHA256"; break;
        case TLS_DH_anon_WITH_AES_256_GCM_SHA384: result = @"DH_anon_WITH_AES_256_GCM_SHA384"; break;
        case TLS_PSK_WITH_AES_128_GCM_SHA256: result = @"PSK_WITH_AES_128_GCM_SHA256"; break;
        case TLS_PSK_WITH_AES_256_GCM_SHA384: result = @"PSK_WITH_AES_256_GCM_SHA384"; break;
        case TLS_DHE_PSK_WITH_AES_128_GCM_SHA256: result = @"DHE_PSK_WITH_AES_128_GCM_SHA256"; break;
        case TLS_DHE_PSK_WITH_AES_256_GCM_SHA384: result = @"DHE_PSK_WITH_AES_256_GCM_SHA384"; break;
        case TLS_RSA_PSK_WITH_AES_128_GCM_SHA256: result = @"RSA_PSK_WITH_AES_128_GCM_SHA256"; break;
        case TLS_RSA_PSK_WITH_AES_256_GCM_SHA384: result = @"RSA_PSK_WITH_AES_256_GCM_SHA384"; break;
        case TLS_PSK_WITH_AES_128_CBC_SHA256: result = @"PSK_WITH_AES_128_CBC_SHA256"; break;
        case TLS_PSK_WITH_AES_256_CBC_SHA384: result = @"PSK_WITH_AES_256_CBC_SHA384"; break;
        case TLS_PSK_WITH_NULL_SHA256: result = @"PSK_WITH_NULL_SHA256"; break;
        case TLS_PSK_WITH_NULL_SHA384: result = @"PSK_WITH_NULL_SHA384"; break;
        case TLS_DHE_PSK_WITH_AES_128_CBC_SHA256: result = @"DHE_PSK_WITH_AES_128_CBC_SHA256"; break;
        case TLS_DHE_PSK_WITH_AES_256_CBC_SHA384: result = @"DHE_PSK_WITH_AES_256_CBC_SHA384"; break;
        case TLS_DHE_PSK_WITH_NULL_SHA256: result = @"DHE_PSK_WITH_NULL_SHA256"; break;
        case TLS_DHE_PSK_WITH_NULL_SHA384: result = @"DHE_PSK_WITH_NULL_SHA384"; break;
        case TLS_RSA_PSK_WITH_AES_128_CBC_SHA256: result = @"RSA_PSK_WITH_AES_128_CBC_SHA256"; break;
        case TLS_RSA_PSK_WITH_AES_256_CBC_SHA384: result = @"RSA_PSK_WITH_AES_256_CBC_SHA384"; break;
        case TLS_RSA_PSK_WITH_NULL_SHA256: result = @"RSA_PSK_WITH_NULL_SHA256"; break;
        case TLS_RSA_PSK_WITH_NULL_SHA384: result = @"RSA_PSK_WITH_NULL_SHA384"; break;
        case TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256: result = @"ECDHE_ECDSA_WITH_AES_128_CBC_SHA256"; break;
        case TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA384: result = @"ECDHE_ECDSA_WITH_AES_256_CBC_SHA384"; break;
        case TLS_ECDH_ECDSA_WITH_AES_128_CBC_SHA256: result = @"ECDH_ECDSA_WITH_AES_128_CBC_SHA256"; break;
        case TLS_ECDH_ECDSA_WITH_AES_256_CBC_SHA384: result = @"ECDH_ECDSA_WITH_AES_256_CBC_SHA384"; break;
        case TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256: result = @"ECDHE_RSA_WITH_AES_128_CBC_SHA256"; break;
        case TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384: result = @"ECDHE_RSA_WITH_AES_256_CBC_SHA384"; break;
        case TLS_ECDH_RSA_WITH_AES_128_CBC_SHA256: result = @"ECDH_RSA_WITH_AES_128_CBC_SHA256"; break;
        case TLS_ECDH_RSA_WITH_AES_256_CBC_SHA384: result = @"ECDH_RSA_WITH_AES_256_CBC_SHA384"; break;
        case TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256: result = @"ECDHE_ECDSA_WITH_AES_128_GCM_SHA256"; break;
        case TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384: result = @"ECDHE_ECDSA_WITH_AES_256_GCM_SHA384"; break;
        case TLS_ECDH_ECDSA_WITH_AES_128_GCM_SHA256: result = @"ECDH_ECDSA_WITH_AES_128_GCM_SHA256"; break;
        case TLS_ECDH_ECDSA_WITH_AES_256_GCM_SHA384: result = @"ECDH_ECDSA_WITH_AES_256_GCM_SHA384"; break;
        case TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256: result = @"ECDHE_RSA_WITH_AES_128_GCM_SHA256"; break;
        case TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384: result = @"ECDHE_RSA_WITH_AES_256_GCM_SHA384"; break;
        case TLS_ECDH_RSA_WITH_AES_128_GCM_SHA256: result = @"ECDH_RSA_WITH_AES_128_GCM_SHA256"; break;
        case TLS_ECDH_RSA_WITH_AES_256_GCM_SHA384: result = @"ECDH_RSA_WITH_AES_256_GCM_SHA384"; break;
        case TLS_EMPTY_RENEGOTIATION_INFO_SCSV: result = @"EMPTY_RENEGOTIATION_INFO_SCSV"; break;
        case SSL_RSA_WITH_RC2_CBC_MD5: result = @"RSA_WITH_RC2_CBC_MD5"; break;
        case SSL_RSA_WITH_IDEA_CBC_MD5: result = @"RSA_WITH_IDEA_CBC_MD5"; break;
        case SSL_RSA_WITH_DES_CBC_MD5: result = @"RSA_WITH_DES_CBC_MD5"; break;
        case SSL_RSA_WITH_3DES_EDE_CBC_MD5: result = @"RSA_WITH_3DES_EDE_CBC_MD5"; break;
        case SSL_NO_SUCH_CIPHERSUITE: result = @"NO_SUCH_CIPHERSUITE"; break;
    }
    return result;
}

+ (NSString *)stringForProtocolVersion:(SSLProtocol)protocol {
    NSString *  result;

    switch (protocol) {
        default:
        case kSSLProtocolUnknown: {
            result = [NSString stringWithFormat:@"unexpected (%d)", (int) protocol];
        } break;
        case kSSLProtocol3: {
            result = @"SSL 3.0";
        } break;
        case kTLSProtocol1: {
            result = @"TLS 1.0";
        } break;
        case kTLSProtocol11: {
            result = @"TLS 1.1";
        } break;
        case kTLSProtocol12: {
            result = @"TLS 1.2";
        } break;
    }
    return result;
}

+ (NSString *)stringForTrustResult:(SecTrustResultType)trustResult {
    NSString *  result;
    
    switch (trustResult) {
        case kSecTrustResultInvalid:                 { result = @"invalid";                   } break;
        case kSecTrustResultProceed:                 { result = @"proceed";                   } break;
        case kSecTrustResultDeny:                    { result = @"deny";                      } break;
        case kSecTrustResultUnspecified:             { result = @"unspecified";               } break;
        case kSecTrustResultRecoverableTrustFailure: { result = @"recoverable trust failure"; } break;
        case kSecTrustResultFatalTrustFailure:       { result = @"fatal trust failure";       } break;
        case kSecTrustResultOtherError:              { result = @"other error";               } break;
        default: {
            result = [NSString stringWithFormat:@"%u", (unsigned int) trustResult];
        } break;
    }
    return result;
}

+ (NSString *)keyBitSizeStringForCertificate:(SecCertificateRef)certificate {
    OSStatus    err;
    NSString *  result;
    SecKeyRef   key;

    // For RSA key size we can get the key size using SecKeyGetBlockSize.  This does not 
    // work for EC keys, alas.  If the key were in the keychain we could use 
    // kSecAttrKeySizeInBits, but the key isn't in the keychain.  AFAIK the only way to 
    // get key size is to drop down to CDSA, which I'd rather not do, because it's deprecated, 
    // but them's the breaks.
    //
    // I filed a bug requesting a non-deprecated way to do this <rdar://problem/22707926>.
    
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wdeprecated-declarations"
    
    result = @"n/a";
    err = SecCertificateCopyPublicKey(certificate, &key);
    if (err == errSecSuccess) {
        const CSSM_KEY * cssmKeyPtr;
        
        err = SecKeyGetCSSMKey(key, &cssmKeyPtr);
        if (err == errSecSuccess) {
            result = [NSString stringWithFormat:@"%zu", (size_t) cssmKeyPtr->KeyHeader.LogicalKeySizeInBits];
        }
        CFRelease(key);
    }

    #pragma clang diagnostic pop
    
    return result;
}

+ (NSString *)keyAlgorithmStringForCertificate:(SecCertificateRef)certificate {
    NSString *      keyAlgorithm;
    NSDictionary *  certValues;
    
    keyAlgorithm = @"n/a";
    
    certValues = CFBridgingRelease( SecCertificateCopyValues(certificate, (__bridge CFArrayRef) @[
        @"2.16.840.1.113741.2.1.1.1.9"
    ], NULL) );
    if (certValues != nil) {
        NSString *  keyOID;
        
        keyOID = certValues[@"2.16.840.1.113741.2.1.1.1.9"][(__bridge NSString *) kSecPropertyKeyValue][0][(__bridge NSString *) kSecPropertyKeyValue];
        keyAlgorithm = @{
            @"1.2.840.113549.1.1.1": @"rsaEncryption", 
            @"1.2.840.10045.2.1":    @"ecPublicKey"
        }[keyOID];
        if (keyAlgorithm == nil) {
            keyAlgorithm = keyOID;
        }
    }
    
    return keyAlgorithm;
}

+ (NSString *)signatureAlgorithmStringForCertificate:(SecCertificateRef)certificate {
    NSString *      sigAlgorithm;
    NSDictionary *  certValues;
    
    sigAlgorithm = nil;
    
    certValues = CFBridgingRelease( SecCertificateCopyValues(certificate, (__bridge CFArrayRef) @[
        @"2.16.840.1.113741.2.1.3.2.1"
    ], NULL) );
    if (certValues != nil) {
        NSString *  sigOID;
        
        sigOID = certValues[@"2.16.840.1.113741.2.1.3.2.1"][(__bridge NSString *) kSecPropertyKeyValue][0][(__bridge NSString *) kSecPropertyKeyValue];
        sigAlgorithm = @{
            @"1.2.840.113549.1.1.1":  @"sha1-with-rsa-signature", 
            @"1.2.840.113549.1.1.5":  @"sha1-with-rsa-signature", 
            @"1.2.840.113549.1.1.11": @"sha256-with-rsa-signature", 
            @"1.2.840.113549.1.1.12": @"sha384-with-rsa-signature", 
            @"1.2.840.113549.1.1.13": @"sha512-with-rsa-signature", 
            @"1.2.840.113549.1.1.14": @"sha224-with-rsa-signature", 
            @"1.2.840.10045.4.1":     @"ecdsa-with-SHA1", 
            @"1.2.840.10045.4.3.1":   @"ecdsa-with-SHA224", 
            @"1.2.840.10045.4.3.2":   @"ecdsa-with-SHA256", 
            @"1.2.840.10045.4.3.3":   @"ecdsa-with-SHA384", 
            @"1.2.840.10045.4.3.4":   @"ecdsa-with-SHA512", 
        }[sigOID];
        if (sigAlgorithm == nil) {
            sigAlgorithm = sigOID;
        }
    }
    
    return sigAlgorithm;
}

+ (NSString *)subjectSummaryForIdentity:(SecIdentityRef)identity {
    BOOL                    success;
    NSString *              result;
    SecCertificateRef       certificate;
    
    NSParameterAssert(identity != NULL);
    
    success = SecIdentityCopyCertificate(identity, &certificate) == errSecSuccess;
    assert(success);
    
    result = CFBridgingRelease( SecCertificateCopySubjectSummary(certificate) );

    CFRelease(certificate);

    return result;
}

@end
