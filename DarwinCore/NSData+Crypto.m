//
//  NSData+NSData_Crypto.m
//  testgcm
//
//  Created by yarshure on 2017/9/30.
//  Copyright © 2017年 yarshure. All rights reserved.
//

#import "NSData+Crypto.h"

#import "CommonCryptorSPI.h"
@implementation NSData (NSData_Crypto)
/*!
 * @brief Generates AES GCM ciphertext, tag (MAC) and IV of a input data
 * @param dataIn the data to be encrypted
 * @param ivLenghtInBits the desired length for the initialization vector (iv)
 * @param symmetricKey the symmetric key
 * @param aad the additional authentication data
 * @param encryptOrDecrypt the operation type kCCEncrypt or kCCDecrypt
 * @param error NSError pointer
 * @return a NSDictionary with the cyphertext ('cyphertext' key) tag ('tag' key) and the iv ('iv' key)
 */
+ (NSDictionary *)dataEncryption:(NSData *)dataIn ivLengthInBits:(int)ivLenghtInBits key:(NSData *)symmetricKey aad:(NSData *)aad context:(CCOperation)encryptOrDecrypt error:(NSError **)error
{
    CCCryptorStatus ccStatus = kCCSuccess;
    NSData *iv = [self randomKeyDataGeneratorWithNumberBits:ivLenghtInBits];
    NSMutableData  *dataOut = [NSMutableData dataWithLength:dataIn.length];
    NSMutableData  *tag = [NSMutableData dataWithLength:kCCBlockSizeAES128];
    size_t          tagLength = kCCBlockSizeAES128;
    
    ccStatus = CCCryptorGCM(encryptOrDecrypt,
                            kCCAlgorithmAES,
                            symmetricKey.bytes,
                            kCCKeySizeAES256,
                            iv.bytes,
                            iv.length,
                            aad.bytes,
                            aad.length,
                            dataIn.bytes,
                            dataIn.length,
                            dataOut.mutableBytes,
                            (void*)tag.bytes,
                            &tagLength);
    
    if (ccStatus == kCCSuccess) {
        return [NSDictionary dictionaryWithObjectsAndKeys:dataOut,@"cyphertext",tag,@"tag",iv,@"iv",nil];
    } else {
        if (error) {
            *error = [NSError errorWithDomain:@"kEncryptionError"
                                         code:ccStatus
                                     userInfo:nil];
        }
        return nil;
    }
    
}

/*!
 * @brief Generates NSData from a randomly generated byte array with a specific number of bits
 * @param numberOfBits the number of bits the generated data must have
 * @return the randomly generated NSData
 */
+(NSData *)randomKeyDataGeneratorWithNumberBits:(int)numberOfBits {
    int numberOfBytes = numberOfBits/8;
    uint8_t randomBytes[numberOfBytes];
    int result = SecRandomCopyBytes(kSecRandomDefault, numberOfBytes, randomBytes);
    if(result == 0) {
        return [NSData dataWithBytes:randomBytes length:numberOfBytes];
    } else {
        return nil;
    }
}
@end
