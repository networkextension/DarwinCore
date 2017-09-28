//
//  SocketServer.m
//  DarwinCore
//
//  Created by yarshure on 2017/9/26.
//  Copyright © 2017年 Kong XiangBo. All rights reserved.
//

#import "SocketServer.h"
#include "xsocket.h"
#include "shared.h"

#include <os/log.h>
@implementation SocketServer
-(instancetype)initWith:(NSInteger)port queue:(dispatch_queue_t)queue
{
    if (self = [super init]){
        self.lport = port;
        self.dispatchQueue = queue;
        self.accepting_requests = true;
    }
    return self;
}
-(void)prepare
{
    os_log(OS_LOG_DEFAULT, "Server Starting");
    os_log_info(OS_LOG_DEFAULT, "Additional info for troubleshooting.");
    os_log_debug(OS_LOG_DEFAULT, "Debug level messages.");
    (void)signal(SIGTERM, SIG_IGN);
    (void)signal(SIGPIPE, SIG_IGN);
    dispatch_source_t newSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_SIGNAL, SIGTERM, 0, self.dispatchQueue);
    
    dispatch_source_set_event_handler(newSource, ^{
        os_log_info(OS_LOG_DEFAULT,"DISPATCH_SOURCE_TYPE_SIGNAL" );
        self.accepting_requests = false;
    });
    dispatch_resume(newSource);
    
    
    
}
-(void)start
{
    [self prepare];
    int fd = server_check_in((int)self.lport);
    (void)fcntl(fd, F_SETFL, O_NONBLOCK);
    dispatch_source_t as = dispatch_source_create(DISPATCH_SOURCE_TYPE_READ, fd, 0, self.dispatchQueue);
    assert(as != NULL);
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
            @synchronized(self) {
                if (self.accepting_requests)
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
                    GCDSocket *socket = [[GCDSocket alloc] initWithFD:afd remoteaddr:ipaddr port:port];
                    dispatch_async(self.dispatchQueue, ^{
                        self.accept(socket);
                    });
                    
                    //server_accept( afd, );
                    //start read
                    //[self server_accept:afd q:dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0 ) ];
                }
                else
                {
                    dispatch_cancel(as);
                    /* We're no longer accepting requests. */
                    //(void)close(afd);
                }
            }
            
        }
    });
    
    dispatch_source_set_cancel_handler(as, ^(void)
                                       {
                                           os_log_info(OS_LOG_DEFAULT, "DISPATCH_SOURCE_TYPE_READ A - canceled" );
                                           @synchronized(self) {
                                               self.accepting_requests = false;
                                               
                                           }
                                           //dispatch_release( as );
                                           (void)close( fd );
                                       });
    
    dispatch_resume( as );
    os_log_info(OS_LOG_DEFAULT, "server - dispatch_main" );
    self.socketSource = as;
    self.sfd = fd;
}
-(void)stop
{
    dispatch_cancel(self.socketSource);
    self.socketSource = nil;
}
@end
