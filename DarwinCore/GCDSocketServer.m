//
//  GCDSocketServer.m
//  DarwinCore
//
//  Created by yarshure on 2017/8/17.
//  Copyright © 2017年 Kong XiangBo. All rights reserved.
//
#include <asl.h>
#include <os/log.h>
#include <stdatomic.h>
#include <libkern/OSAtomic.h>
#import "GCDSocketServer.h"
#include "shared.h"
static bool g_accepting_requests = true;

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
        //[stack incomingData:fd data:data];
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
                                              
                                              os_log_info(OS_LOG_DEFAULT, "DISPATCH_SOURCE_TYPE_WRITE - writing bytes" );
                                              
                                              if ( track_sz == 0 )
                                              {
                                                  os_log_info(OS_LOG_DEFAULT, "DISPATCH_SOURCE_TYPE_WRITE - all bytes written" );
                                                  
                                                  dispatch_source_cancel( s );
                                              }
                                          }
                                      });
    
    dispatch_source_set_cancel_handler(s, ^(void)
                                       {
                                           os_log_info(OS_LOG_DEFAULT, "DISPATCH_SOURCE_TYPE_WRITE - canceled" );
                                           free(buff);
                                           //dispatch_release(s);
                                       });
    
    dispatch_resume(s);
}
@implementation GCDSocketServer
+(GCDSocketServer*)shared
{
    static GCDSocketServer* server = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        server = [[GCDSocketServer alloc] init];
    });
    return server;
}

-(void)startServer:(int)port queue:(dispatch_queue_t)queue
{
    self.dispatchQueue = queue;
    
    os_log(OS_LOG_DEFAULT, "Server Starting");
    os_log_info(OS_LOG_DEFAULT, "Additional info for troubleshooting.");
    os_log_debug(OS_LOG_DEFAULT, "Debug level messages.");
    (void)signal(SIGTERM, SIG_IGN);
    (void)signal(SIGPIPE, SIG_IGN);
    
    dispatch_source_t sts = dispatch_source_create(DISPATCH_SOURCE_TYPE_SIGNAL, SIGTERM, 0, queue);
    assert(sts != NULL);
    dispatch_source_set_event_handler(sts, ^(void)
                                      {
                                          os_log_info(OS_LOG_DEFAULT,"DISPATCH_SOURCE_TYPE_SIGNAL" );
                                          
                                         
                                          g_accepting_requests = false;
                                      });
    
    dispatch_resume(sts);
    int fd = server_check_in(port);
    
    (void)fcntl(fd, F_SETFL, O_NONBLOCK);
    dispatch_source_t as = dispatch_source_create(DISPATCH_SOURCE_TYPE_READ, fd, 0, queue);
    assert(as != NULL);
    self.as = as;
    dispatch_source_set_event_handler(as, ^(void){
        struct sockaddr_storage saddr;
        socklen_t        slen    = sizeof(saddr);
        os_log_info(OS_LOG_DEFAULT, "DISPATCH_SOURCE_TYPE_READ A" );
        
        int afd = accept( fd, (struct sockaddr *)&saddr, &slen );
        
        if ( afd != -1 )
        {
            int value = 1;
            setsockopt(afd, SOL_SOCKET, SO_NOSIGPIPE, &value, sizeof(value));
            os_log_info(OS_LOG_DEFAULT,"DISPATCH_SOURCE_TYPE_READ A - accepted" );
            
            /* Again, make sure the new connection's descriptor is non-blocking. */
            (void)fcntl( fd, F_SETFL, O_NONBLOCK );
            
            /* Check to make sure that we're still accepting new requests. */
            if (g_accepting_requests)
            {
                /* We're going to handle all requests concurrently. This daemon uses an HTTP-style
                 * model, where each request comes through its own connection. Making a more
                 * efficient implementation is an exercise left to the reader.
                 */
                int  port = 0;
                char ipstr[INET6_ADDRSTRLEN];
                // deal with both IPv4 and IPv6:
                if (saddr.ss_family == AF_INET) {
                    struct sockaddr_in *s = (struct sockaddr_in *)&saddr;
                    port = ntohs(s->sin_port);
                    inet_ntop(AF_INET, &s->sin_addr, ipstr, sizeof ipstr);
                } else { // AF_INET6
                    struct sockaddr_in6 *s = (struct sockaddr_in6 *)&saddr;
                    port = ntohs(s->sin6_port);
                    inet_ntop(AF_INET6, &s->sin6_addr, ipstr, sizeof ipstr);
                }
                
                printf("Peer IP address: %s\n", ipstr);
                //[self loadfd:fd];
            
                NSString *ipaddr = [NSString stringWithUTF8String:ipstr];
                
                self.accept(afd, ipaddr, port);
                //server_accept( afd, );
                [self server_accept:afd q:dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0 ) ];
            }
            else
            {
                /* We're no longer accepting requests. */
                (void)close(afd);
            }
        }
    });
    
    dispatch_source_set_cancel_handler(as, ^(void)
                                       {
                                           os_log_info(OS_LOG_DEFAULT, "DISPATCH_SOURCE_TYPE_READ A - canceled" );
                                           
                                           //dispatch_release( as );
                                           (void)close( fd );
                                       });
    
    dispatch_resume( as );
    os_log_info(OS_LOG_DEFAULT, "server - dispatch_main" );
    self.sfd = fd;
    
}

-(void) server_accept:(int)fd  q:(dispatch_queue_t)q
{
    /* This variable needs to be mutable in the block. Setting __block will
     * ensure that, when dispatch_source_set_event_handler(3) copies it to
     * the heap, this variable will be copied to the heap as well, so it'll
     * be safely mutable in the block.
     */
    __block size_t total = 0;
    
    
    /* For large allocations like this, the VM system will lazily create
     * the pages, so we won't get the full 10 MB (or anywhere near it) upfront.
     * A smarter implementation would read the intended mess_age size upfront
     * into a fixed-size buffer and then allocate the needed space right there.
     * But if our requests are almost always going to be this small, then we
     * avoid a potential second trap into the kernel to do the second read(2).
     * Also, we avoid a second copy-out of the data read.
     */
    
    
    
    
    dispatch_source_t s = dispatch_source_create( DISPATCH_SOURCE_TYPE_READ, fd, 0, q );
    assert(s != NULL);
    
    dispatch_source_set_event_handler(s, ^(void)
                                      {
                                          os_log_info(OS_LOG_DEFAULT, "DISPATCH_SOURCE_TYPE_READ B" );
                                          
                                          /* You may be asking yourself, "Doesn't the fact that we're on a concurrent
                                           * queue mean that multiple event handler blocks could be running
                                           * simultaneously for the same source?" The answer is no. Parallelism for
                                           * the global concurrent queues is at the source level, not the event
                                           * handler level. So for each source, exactly one invocation of the event
                                           * handler can be inflight. When scheduling on a concurrent queue, it
                                           * means that that handler may be running concurrently with other sources'
                                           * event handlers, but not its own.
                                           */
                                          
                                          size_t    buff_sz        = 8 * 1024;
                                          void*    buff        = malloc( buff_sz );
                                          void*    msgStart    = buff;
                                          assert(buff != NULL);
                                          if ( server_read( fd, buff, buff_sz, &msgStart, &total) )
                                          {
                                              os_log_info(OS_LOG_DEFAULT, "DISPATCH_SOURCE_TYPE_READ B - server_read success" );
                                              
                                              /* After handling the request (which, in this case, means that we've
                                               * scheduled a source to deliver the reply), we no longer need this
                                               * source. So we cancel it.
                                               */
                                              dispatch_source_cancel(s);
                                          }
                                          free( buff );
                                      });
    
    dispatch_source_set_cancel_handler(s, ^(void)
                                       {
                                           os_log_info(OS_LOG_DEFAULT, "DISPATCH_SOURCE_TYPE_READ B - canceled" );
                                           
                                           //dispatch_release( s );
                                           
                                           close( fd );
                                           //[stack didCloseSocket:fd];
                                           self.colse(fd);
                                           //GCDSocketServer *server = [GCDSocketServer shared];
                                           
                                           //server.colse
                                       });
    
    dispatch_resume(s);
}
-(void)server_write_request:(int)fd buffer:(const void *)buffer total:(size_t)total
{
    CFDataRef data = CFDataCreateWithBytesNoCopy( NULL, buffer, total, kCFAllocatorNull );
    assert(data != NULL);
    
    server_send_reply( fd, dispatch_get_current_queue(), data);
    
    /* ss_send_reply() copies the data from replyData out, so we can safely
     * release it here. But remember, that's an inefficient design.
     */
    CFRelease( data );
}
-(void)stopServer;
{
    dispatch_source_cancel(self.as);
}
-(BOOL)running
{
    return false;
}
@end
