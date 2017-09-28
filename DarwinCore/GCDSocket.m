//
//  GCDSocket.m
//  DarwinCore
//
//  Created by yarshure on 2017/9/26.
//  Copyright © 2017年 Kong XiangBo. All rights reserved.
//

#import "GCDSocket.h"
#import "xsocket.h"
#include <os/log.h>
@implementation GCDSocket
-(instancetype)initWithFD:(int)fd remoteaddr:(NSString*)addr port:(int)port;
{
    if(self = [super init]){
        self.sfd = fd;
        self.remote = addr;
        self.port = port;
    }
    return self;
}
-(void)startWithIncoming:(incomingData)incoming
{
    __block size_t total = 0;
    
    dispatch_source_t s = dispatch_source_create( DISPATCH_SOURCE_TYPE_READ, self.sfd, 0, self.socketQueue);
    
    dispatch_source_set_event_handler(s, ^(void)
                                      {
                                          os_log_info(OS_LOG_DEFAULT, "DISPATCH_SOURCE_TYPE_READ B" );
                                          
                                          
                                          
                                          size_t    buff_sz        = 8 * 1024;
                                          void*    buff        = malloc( buff_sz );
                                          void*    msgStart    = buff;
                                          assert(buff != NULL);
                                          if ( server_readx( self, buff, buff_sz, &msgStart, &total) )
                                          {
                                              os_log_info(OS_LOG_DEFAULT, "DISPATCH_SOURCE_TYPE_READ B - server_read success" );
                                              
                                             
                                              dispatch_source_cancel(s);
                                          }
                                          free( buff );
                                      });
    
    dispatch_source_set_cancel_handler(s, ^(void)
                                       {
                                           os_log_info(OS_LOG_DEFAULT, "DISPATCH_SOURCE_TYPE_READ B - canceled" );
                                           
                                           //dispatch_release( s );
                                           
                                           close( self.sfd );
                                           dispatch_async(self.dispatchQueue, ^{
                                               self.didClosedSocket(self);
                                           });
                                           
                                       });
                                       
    
    dispatch_resume(s);
    self.socketSource = s;
    
}
bool server_readx( GCDSocket *socket, unsigned char *buff, size_t buff_sz, void** msgStart, size_t *total )
{
    os_log_info(OS_LOG_DEFAULT, "server_read" );
    
    bool result = false;
    
    //    struct ss_msg_s *msg = (struct ss_msg_s *)buff;
    //
    //    size_t            headerSize    = sizeof( struct ss_msg_s );
    //    unsigned char*    track_buff    = buff + *total;
    //    size_t            track_sz    = buff_sz - *total;
    ssize_t            nbytes        = read( socket.sfd, buff, 8 * 1024 );
    
    os_log_info(OS_LOG_DEFAULT, "nbytes: %lu", nbytes );
    
    if ( nbytes == 0 )
    {
        os_log_info(OS_LOG_DEFAULT, "all bytes read" );
        
        return true;
    }
    else if ( nbytes == -1 )
    {
        os_log_info(OS_LOG_DEFAULT, "server_read: error on read!" );
        
        return true;
    }
    else
    {
        *total += nbytes;
        
        /* We do this swap on every read(2), which is wasteful. But there is a
         * way to avoid doing this every time and not introduce an extra
         * parameter. See if you can find it.
         */
        NSData *data = [NSData dataWithBytes:buff length:nbytes];
        
        
        dispatch_async(socket.dispatchQueue, ^{
            socket.incoming(socket, data);
        });
        
        
    }
    
    return result;
}
-(void)write_request_buffer:(const void *)buffer total:(size_t)total
{
    CFDataRef data = CFDataCreateWithBytesNoCopy( NULL, buffer, total, kCFAllocatorNull );
    assert(data != NULL);
    
    server_send_reply( self.sfd, self.socketQueue, data);
    
    /* ss_send_reply() copies the data from replyData out, so we can safely
     * release it here. But remember, that's an inefficient design.
     */
    CFRelease( data );
}
-(void)close
{
    dispatch_cancel(self.socketSource);
}
@end
