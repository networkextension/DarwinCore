//
//  IPSum.h
//  DarwinCore
//
//  Created by 孔祥波 on 02/06/2017.
//  Copyright © 2017 Kong XiangBo. All rights reserved.
//

#import <Foundation/Foundation.h>
NSData* ipHeader(int len,__uint32_t src,__uint32_t dst,__uint16_t iden, u_char p);
void print_free_memory (void);
