//
//  NSData+NSData_Crypto.h
//  testgcm
//
//  Created by yarshure on 2017/9/30.
//  Copyright © 2017年 yarshure. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCryptor.h>
@interface NSData (NSData_Crypto)
+(NSData *)randomKeyDataGeneratorWithNumberBits:(int)numberOfBits;
+(NSDictionary *)dataEncryption:(NSData *)dataIn ivLengthInBits:(int)ivLenghtInBits key:(NSData *)symmetricKey aad:(NSData *)aad context:(CCOperation)encryptOrDecrypt error:(NSError **)error;
@end
