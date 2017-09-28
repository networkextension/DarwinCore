//
//  GCDSocket.m
//  DarwinCore
//
//  Created by yarshure on 2017/9/26.
//  Copyright © 2017年 Kong XiangBo. All rights reserved.
//

#import "GCDSocket.h"
#import "xsocket.h"
@implementation GCDSocket
-(instancetype)initWithFD:(int) fd
{
    if(self = [super init]){
        self.sfd = fd;
    }
    return self;
}

-(void)server_write_request:(int)fd buffer:(const void *)buffer total:(size_t)total
{
    CFDataRef data = CFDataCreateWithBytesNoCopy( NULL, buffer, total, kCFAllocatorNull );
    assert(data != NULL);
    
    server_send_reply( fd, self.socketQueue, data);
    
    /* ss_send_reply() copies the data from replyData out, so we can safely
     * release it here. But remember, that's an inefficient design.
     */
    CFRelease( data );
}
@end
