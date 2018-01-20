/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    Utilities routines used by various subsystems.
 */

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

/*! Utilities routines used by various subsystems.
 *  \details This class exports a number of class utility methods for turning 
 *      TLS constructs into strings that are displayed in various log messages.
 */

@interface TLSUtilities : NSObject

- (instancetype)init NS_UNAVAILABLE;

/*! Returns a string representation of a TLS cipher suite value.
 *  \param cipher A cipher suite value.
 *  \returns A string representation of that cipher suite value.
 */

+ (NSString *)stringForCipherSuite:(SSLCipherSuite)cipher;

/*! Returns a string representation of a TLS protocol version.
 *  \param protocol A protocol version.
 *  \returns A string representation of that protocol version.
 */

+ (NSString *)stringForProtocolVersion:(SSLProtocol)protocol;

/*! Returns a string representation of a trust result value.
 *  \param trustResult A trust result value.
 *  \returns A string representation of that trust result value.
 */

+ (NSString *)stringForTrustResult:(SecTrustResultType)trustResult;

/*! Returns a string representation of the key size, in bits, of the certificate's key.
 *  \param certificate A certificate.
 *  \returns A string representation of key size of the key in the certificate.
 */

+ (NSString *)keyBitSizeStringForCertificate:(SecCertificateRef)certificate;

/*! Returns a string representation of the key algorithm of the certificate.
 *  \param certificate A certificate.
 *  \returns A string representation of key algorithm of the key in the certificate.
 */

+ (NSString *)keyAlgorithmStringForCertificate:(SecCertificateRef)certificate;

/*! Returns a string representation of the signature algorithm of the certificate.
 *  \param certificate A certificate.
 *  \returns A string representation of that certificate's signature algorithm.
 */

+ (NSString *)signatureAlgorithmStringForCertificate:(SecCertificateRef)certificate;

/*! Returns a subject summary string for the specified identity.
 *  \param identity The identity whose subject you're looking for.
 *  \returns The subject summary from the identity's certificate.
 */

+ (NSString *)subjectSummaryForIdentity:(SecIdentityRef)identity;

@end

NS_ASSUME_NONNULL_END
