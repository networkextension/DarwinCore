//
//  GCDSocketServer.m
//  DarwinCore
//
//  Created by yarshure on 2017/8/17.
//  Copyright © 2017年 Kong XiangBo. All rights reserved.
//
//#include <asl.h>
#include <os/log.h>
#include <stdatomic.h>
#include <libkern/OSAtomic.h>
#import "GCDSocketServer.h"
#include "shared.h"
#import "xsocket.h"

#ifdef DEBUG

// Something to log your sensitive data here
#define kos_log(log, format, ...) \
    os_log_with_type(log, OS_LOG_TYPE_DEFAULT, format, ##__VA_ARGS__)
#define kos_log_info(log, format, ...) \
    os_log_with_type(log, OS_LOG_TYPE_INFO, format, ##__VA_ARGS__)
#define kos_log_debug(log, format, ...) \
    os_log_with_type(log, OS_LOG_TYPE_DEBUG, format, ##__VA_ARGS__)
#else

#define kos_log(log, format, ...)

#define kos_log_info(log, format, ...)

#define kos_log_debug(log, format, ...)

#endif
static bool g_accepting_requests = true;


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
-(void)pauseRestartServer
{
    //设置状态，这个时候有新来的socket 会直接close掉
    
    g_accepting_requests = !g_accepting_requests;
}
-(void)startServer:(int)port dispatchQueue:(dispatch_queue_t  _Nonnull)dqueue socketQueue:(dispatch_queue_t  _Nonnull)squeue share:(BOOL)share;
{
    self.dispatchQueue = dqueue;
    self.socketQueue = squeue;
    
    kos_log(OS_LOG_DEFAULT, "Server Starting");
    kos_log_info(OS_LOG_DEFAULT, "Additional info for troubleshooting.");
    kos_log_debug(OS_LOG_DEFAULT, "Debug level messages.");
    (void)signal(SIGTERM, SIG_IGN);
    (void)signal(SIGPIPE, SIG_IGN);
    
    dispatch_source_t sts = dispatch_source_create(DISPATCH_SOURCE_TYPE_SIGNAL, SIGTERM, 0, self.socketQueue);
    assert(sts != NULL);
    dispatch_source_set_event_handler(sts, ^(void)
                                      {
                                          kos_log_info(OS_LOG_DEFAULT,"DISPATCH_SOURCE_TYPE_SIGNAL" );
                                          
                                         
                                          g_accepting_requests = false;
                                      });
    
    dispatch_resume(sts);
    int fd = server_check_in(port,share);
    
    (void)fcntl(fd, F_SETFL, O_NONBLOCK);
    dispatch_source_t as = dispatch_source_create(DISPATCH_SOURCE_TYPE_READ, fd, 0, self.socketQueue);
    assert(as != NULL);
    
    dispatch_source_set_event_handler(as, ^(void){
        struct sockaddr_storage saddr;
        socklen_t        slen    = sizeof(saddr);
        kos_log_debug(OS_LOG_DEFAULT, "DISPATCH_SOURCE_TYPE_READ A" );
        
        int afd = accept( fd, (struct sockaddr *)&saddr, &slen );
        
        if ( afd != -1 )
        {
            int value = 1;
            setsockopt(afd, SOL_SOCKET, SO_NOSIGPIPE, &value, sizeof(value));
            kos_log_debug(OS_LOG_DEFAULT,"DISPATCH_SOURCE_TYPE_READ A - accepted" );
            
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
                dispatch_async(self.dispatchQueue, ^{
                   self.accept(afd, ipaddr, port);
                });
            
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
                                           kos_log_debug(OS_LOG_DEFAULT, "DISPATCH_SOURCE_TYPE_READ A - canceled" );
                                           
                                           //dispatch_release( as );
                                           (void)close( fd );
                                       });
    
    dispatch_resume( as );
    os_log_info(OS_LOG_DEFAULT, "server - dispatch_queue" );
    self.as = as;
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
                                          kos_log_debug(OS_LOG_DEFAULT, "DISPATCH_SOURCE_TYPE_READ B" );
                                          
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
                                          if ([self server_read:fd buff:buff size:buff_sz start:&msgStart total:&total])
                                         
                                          {
                                              kos_log_debug(OS_LOG_DEFAULT, "DISPATCH_SOURCE_TYPE_READ B - server_read success" );
                                              
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
                                           kos_log_debug(OS_LOG_DEFAULT, "DISPATCH_SOURCE_TYPE_READ B - canceled" );
                                           
                                           //dispatch_release( s );
                                           
                                           close( fd );
                                       
                                           dispatch_async(self.dispatchQueue, ^{
                                               self.colse(fd);
                                           });
                                       
                                       
                                       });
    
    dispatch_resume(s);
}


-(void)stopServer;
{
    dispatch_source_cancel(self.as);
    
}
-(BOOL)running
{
    if(self.sfd != 0){
        return true;
    }
    return false;
}
-(void)pauseReading
{
    self.pauseRead = YES;
}
-(void)resumeReading;
{
    self.pauseRead = NO;
    
}
-(bool)server_read:(int)fd buff:(unsigned char *_Nullable)buff size:(size_t)buff_sz start:(void  * _Nullable *_Nullable)msgStart total:(size_t *_Nullable)total
    {
        kos_log_info(OS_LOG_DEFAULT, "server_read" );
        
        bool result = false;
        
        //    struct ss_msg_s *msg = (struct ss_msg_s *)buff;
        //
        //    size_t            headerSize    = sizeof( struct ss_msg_s );
        //    unsigned char*    track_buff    = buff + *total;
        //    size_t            track_sz    = buff_sz - *total;
        ssize_t            nbytes        = read( fd, buff, 8 * 1024 );
        
        
        
        if ( nbytes == 0 )
        {
            kos_log_info(OS_LOG_DEFAULT, "all bytes read" );
            
            return true;
        }
        else if ( nbytes == -1 )
        {
            perror(strerror(errno));
            kos_log_info(OS_LOG_DEFAULT, "server_read: error on read! %s",strerror(errno) );
            
            return true;
        }
        else
        {
            kos_log_info(OS_LOG_DEFAULT, "nbytes: %lu", nbytes );
            *total += nbytes;
            
            /* We do this swap on every read(2), which is wasteful. But there is a
             * way to avoid doing this every time and not introduce an extra
             * parameter. See if you can find it.
             */
            NSData *data = [NSData dataWithBytes:buff length:nbytes];
            __weak GCDSocketServer *server = self;
            dispatch_async(self.dispatchQueue, ^{
                server.incoming(fd, data);
            });
            
        }
        
        return result;
    }
-(void)server_write_request:(int)fd  data:(NSData* _Nullable)odata finish:(didWrite _Nonnull )finish
{
//-(void)server_send_reply:(int)fd queue:(dispatch_queue_t)q  data:(CFDataRef)data finish:(didWrite)finish
 //    [self server_send_reply:fd queue:self.socketQueue data: finish:finish];
        kos_log_info(OS_LOG_DEFAULT, "server_send_reply" );
        CFDataRef data =  (__bridge CFDataRef)(odata);
        size_t            total    = CFDataGetLength( data );
        unsigned char*    buff    = (unsigned char *)malloc(total);
        
        assert(buff != NULL);
        
        //struct ss_msg_s *msg = (struct ss_msg_s *)buff;
        
        //msg->_len = OSSwapHostToLittleInt32(total - sizeof(struct ss_msg_s));
        
        /* Coming up with a more efficient implementation is left as an exercise to
         * the reader.
         */
        (void)memcpy( buff, CFDataGetBytePtr( data ), CFDataGetLength( data ) );
        
        
        dispatch_source_t s = dispatch_source_create(DISPATCH_SOURCE_TYPE_WRITE, fd, 0, self.socketQueue);
        assert(s != NULL);
        
        __block unsigned char*    track_buff    = buff;
        __block size_t            track_sz    = total;
       __weak GCDSocketServer *server = self;
        dispatch_source_set_event_handler(s, ^(void)
                                          {
                                              ssize_t nbytes = write(fd, track_buff, track_sz);
                                              if (nbytes != -1)
                                              {
                                                  track_buff += nbytes;
                                                  track_sz -= nbytes;
                                                  
                                                  
                                                  
                                                  if ( track_sz == 0 )
                                                  {
                                                      kos_log_debug(OS_LOG_DEFAULT, "DISPATCH_SOURCE_TYPE_WRITE - all bytes written" );
                                                      
                                                      dispatch_source_cancel( s );
                                                      //finish(true,fd);
                                                      
                                                      dispatch_async(server.dispatchQueue, ^{
                                                          finish(true,fd,total);
                                                      });
                                                  }else {
                                                      
                                                      kos_log_debug(OS_LOG_DEFAULT, "DISPATCH_SOURCE_TYPE_WRITE count:%d", nbytes);
                                                      
                                                  }
                                              }else {
                                                  kos_log_debug(OS_LOG_DEFAULT, "write fail:%s",strerror(errno));
                                                  
                                                  dispatch_source_cancel( s );
                                                  dispatch_async(server.dispatchQueue, ^{
                                                      finish(false,fd,total);
                                                  });
                                                
                                              }
                                              
                                              
                                              
                                          });
        
        dispatch_source_set_cancel_handler(s, ^(void)
                                           {
                                               kos_log_debug(OS_LOG_DEFAULT, "DISPATCH_SOURCE_TYPE_WRITE - canceled" );
                                               free(buff);
                                               //dispatch_release(s);
                                           });
        
        dispatch_resume(s);
    }

@end
