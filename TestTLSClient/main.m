//
//  main.m
//  TestTLSClient
//
//  Created by yarshure on 15/01/2018.
//  Copyright © 2018 Kong XiangBo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DarwinCore/DarwinCore.h>
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSLog(@"Hello, World!");
        dtls_client();
    }
    return 0;
}
