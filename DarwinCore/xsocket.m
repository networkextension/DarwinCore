//
//  xsocket.c
//  DarwinCore
//
//  Created by yarshure on 2017/9/26.
//  Copyright © 2017年 Kong XiangBo. All rights reserved.
//

#include "xsocket.h"
#include "shared.h"
#include <asl.h>
#include <os/log.h>
#include <stdatomic.h>
#include <libkern/OSAtomic.h>
#import "GCDSocketServer.h"
//#define SNOW(format, ...)  os_log_info(OS_LOG_DEFAULT, format, ...)
int server_check_in(int port)
{
    int sockfd = -1;
    CFShow( CFSTR( "server_check_in - not managed" ) );
    
    /* We're running under a debugger, so set up the socket by hand. In this
     * case, we're setting up a TCP socket that listens on port 1138. Under
     * launchd, all of this is taken care of for us in the plist.
     */
    sockfd = socket(PF_INET, SOCK_STREAM, 0);
    assert(sockfd != -1);
    int sock_opt = 1;
    if (setsockopt(sockfd, SOL_SOCKET, SO_REUSEADDR, (void*)&sock_opt, sizeof(sock_opt) ) == -1){
        return false;
    }
    
    struct sockaddr_in saddr;
    (void)bzero(&saddr, sizeof(saddr));
    saddr.sin_family = AF_INET;
    saddr.sin_port = htons(port);
    saddr.sin_addr.s_addr = INADDR_ANY;
    
    int result = bind(sockfd, (struct sockaddr *)&saddr, sizeof(saddr));
    assert(result == 0);
    
    result = listen(sockfd, -1);
    assert(result == 0);
    return sockfd;
}
bool server_read( int fd, unsigned char *buff, size_t buff_sz, void** msgStart, size_t *total )
{
    os_log_info(OS_LOG_DEFAULT, "server_read" );
    
    bool result = false;
    
    //    struct ss_msg_s *msg = (struct ss_msg_s *)buff;
    //
    //    size_t            headerSize    = sizeof( struct ss_msg_s );
    //    unsigned char*    track_buff    = buff + *total;
    //    size_t            track_sz    = buff_sz - *total;
    ssize_t            nbytes        = read( fd, buff, 8 * 1024 );
    
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
        
        
        
//fixme
        GCDSocketServer *server = [GCDSocketServer shared];
        dispatch_async(server.dispatchQueue, ^{
            server.incoming(fd, data);
        });
        
    }
    
    return result;
}
void server_send_reply(int fd, dispatch_queue_t q, CFDataRef data)
{
    os_log_info(OS_LOG_DEFAULT, "server_send_reply" );
    
    size_t            total    = CFDataGetLength( data );
    unsigned char*    buff    = (unsigned char *)malloc(total);
    
    assert(buff != NULL);
    
    //struct ss_msg_s *msg = (struct ss_msg_s *)buff;
    
    //msg->_len = OSSwapHostToLittleInt32(total - sizeof(struct ss_msg_s));
    
    /* Coming up with a more efficient implementation is left as an exercise to
     * the reader.
     */
    (void)memcpy( buff, CFDataGetBytePtr( data ), CFDataGetLength( data ) );
    
    
    dispatch_source_t s = dispatch_source_create(DISPATCH_SOURCE_TYPE_WRITE, fd, 0, q);
    assert(s != NULL);
    
    __block unsigned char*    track_buff    = buff;
    __block size_t            track_sz    = total;
    
    dispatch_source_set_event_handler(s, ^(void)
                                      {
                                          ssize_t nbytes = write(fd, track_buff, track_sz);
                                          if (nbytes != -1)
                                          {
                                              track_buff += nbytes;
                                              track_sz -= nbytes;
                                              
                                              os_log_debug(OS_LOG_DEFAULT, "DISPATCH_SOURCE_TYPE_WRITE - writing bytes" );
                                              
                                              if ( track_sz == 0 )
                                              {
                                                  os_log_debug(OS_LOG_DEFAULT, "DISPATCH_SOURCE_TYPE_WRITE - all bytes written" );
                                                  
                                                  dispatch_source_cancel( s );
                                              }
                                          }
                                      });
    
    dispatch_source_set_cancel_handler(s, ^(void)
                                       {
                                           os_log_debug(OS_LOG_DEFAULT, "DISPATCH_SOURCE_TYPE_WRITE - canceled" );
                                           free(buff);
                                           //dispatch_release(s);
                                       });
    
    dispatch_resume(s);
}
