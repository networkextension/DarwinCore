//
//  GCDSocket.m
//  DarwinCore
//
//  Created by yarshure on 2017/9/26.
//  Copyright © 2017年 Kong XiangBo. All rights reserved.
//
#include <netdb.h>
#import "GCDSocket.h"
#import "xsocket.h"
#include <sys/socket.h>
#include "shared.h"
#include <os/log.h>
@implementation GCDSocket
-(instancetype _Nonnull )initWithRemoteaddr:(NSString*_Nonnull)addr port:(NSString*)port
{
    if(self = [super init]){
        
        self.remote = addr;
        self.port = (int)port.integerValue;
        
        [self connectRemote:self.remote.UTF8String service:port.UTF8String];
    }
    return self;
}
-(instancetype _Nonnull )initWithFD:(int)fd remoteaddr:(NSString*_Nonnull)addr port:(int)port
{
    if(self = [super init]){
        self.sfd = fd;
        self.remote = addr;
        self.port = port;
        
    }
    return self;
}
-(instancetype _Nonnull )initWithPort:(int)port//create and listen
{
    if(self = [super init]){
        
        self.sfd = server_check_in(port);
        self.remote = @"";
        self.g_accepting_requests = true;
        self.port = port;
    }
    return self;
}


-(void)accept:(newSocket _Nonnull )news
{
    assert(self.dispatchQueue != nil);
    assert(self.socketQueue != nil);
    
    os_log(OS_LOG_DEFAULT, "Server Starting");
    os_log_info(OS_LOG_DEFAULT, "Additional info for troubleshooting.");
    os_log_debug(OS_LOG_DEFAULT, "Debug level messages.");
    (void)signal(SIGTERM, SIG_IGN);
    (void)signal(SIGPIPE, SIG_IGN);
    
    dispatch_source_t sts = dispatch_source_create(DISPATCH_SOURCE_TYPE_SIGNAL, SIGTERM, 0, self.socketQueue);
    assert(sts != NULL);
    dispatch_source_set_event_handler(sts, ^(void)
                                      {
                                        os_log_info(OS_LOG_DEFAULT,"DISPATCH_SOURCE_TYPE_SIGNAL" );
                                        _g_accepting_requests = false;
                                      });
    
    dispatch_resume(sts);
    int fd = self.sfd;
    
    (void)fcntl(fd, F_SETFL, O_NONBLOCK);
    dispatch_source_t as = dispatch_source_create(DISPATCH_SOURCE_TYPE_READ, fd, 0, self.socketQueue);
    assert(as != NULL);
    
    dispatch_source_set_event_handler(as, ^(void){
        struct sockaddr_storage saddr;
        socklen_t        slen    = sizeof(saddr);
        os_log_debug(OS_LOG_DEFAULT, "DISPATCH_SOURCE_TYPE_READ A" );
        
        int afd = accept( fd, (struct sockaddr *)&saddr, &slen );
        
        if ( afd != -1 )
            {
            int value = 1;
            setsockopt(afd, SOL_SOCKET, SO_NOSIGPIPE, &value, sizeof(value));
            os_log_debug(OS_LOG_DEFAULT,"DISPATCH_SOURCE_TYPE_READ A - accepted" );
            
            /* Again, make sure the new connection's descriptor is non-blocking. */
            (void)fcntl( fd, F_SETFL, O_NONBLOCK );
            
            /* Check to make sure that we're still accepting new requests. */
            if (_g_accepting_requests)
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
                os_log_debug(OS_LOG_DEFAULT, "Peer IP address: %s\n", ipstr);
                
                
                NSString *ipaddr = [NSString stringWithUTF8String:ipstr];
                GCDSocket *s = [[GCDSocket alloc] initWithFD:afd remoteaddr:ipaddr port:port];
                dispatch_async(self.dispatchQueue, ^{
                    //self.accept(afd, ipaddr, port);
                    news(s);
                });
                //should not read here
                    //server_accept( afd, );
                
            }else
                {
                /* We're no longer accepting requests. */
                    (void)close(afd);
                }
            }
    });
    
    dispatch_source_set_cancel_handler(as, ^(void)
                                       {
                                       os_log_debug(OS_LOG_DEFAULT, "DISPATCH_SOURCE_TYPE_READ A - canceled" );
                                       
                                           //dispatch_release( as );
                                       (void)close( fd );
                                       });
    
    dispatch_resume( as );
    os_log_info(OS_LOG_DEFAULT, "server - dispatch_queue" );
    self.readSource = as;
    
}

-(void)write:(NSData*_Nonnull)odata completionHandler:(writeCompletionHandler _Nonnull) completionHandler
{
    //write to
    os_log_info(OS_LOG_DEFAULT, "server_send_reply" );
    CFDataRef data = (__bridge CFDataRef)(odata);
    size_t            total    = CFDataGetLength( data );
    unsigned char*    buff    = (unsigned char *)malloc(total);
    
    assert(buff != NULL);
    
        //struct ss_msg_s *msg = (struct ss_msg_s *)buff;
    
        //msg->_len = OSSwapHostToLittleInt32(total - sizeof(struct ss_msg_s));
    
    /* Coming up with a more efficient implementation is left as an exercise to
     * the reader.
     */
    (void)memcpy( buff, CFDataGetBytePtr( data ), CFDataGetLength( data ) );
    
    
    dispatch_source_t s = dispatch_source_create(DISPATCH_SOURCE_TYPE_WRITE, self.sfd, 0, self.socketQueue);
    assert(s != NULL);
    
    __block unsigned char*    track_buff    = buff;
    __block size_t            track_sz    = total;
   
    dispatch_source_set_event_handler(s, ^(void)
                                      {
                                      self.writing = true;
                                      ssize_t nbytes = write(self.sfd, track_buff, track_sz);
                                      if (nbytes != -1)
                                          {
                                          track_buff += nbytes;
                                          track_sz -= nbytes;
                                          
                                          
                                          
                                          if ( track_sz == 0 )
                                              {
                                              os_log_debug(OS_LOG_DEFAULT, "DISPATCH_SOURCE_TYPE_WRITE - all bytes written" );
                                              
                                              dispatch_source_cancel( s );
                                                  dispatch_async(self.dispatchQueue, ^{
                                                      completionHandler(nil);
                                                  });
                                              
                                              }else {
                                                  
                                                  os_log_debug(OS_LOG_DEFAULT, "DISPATCH_SOURCE_TYPE_WRITE count:%d", nbytes);
                                                  
                                              }
                                          }else {
                                              os_log_debug(OS_LOG_DEFAULT, "write fail:%s",strerror(errno));
                                              
                                          }
                                      
                                      
                                      
                                      });
    
    dispatch_source_set_cancel_handler(s, ^(void)
                                       {
                                         os_log_debug(OS_LOG_DEFAULT, "DISPATCH_SOURCE_TYPE_WRITE - canceled" );
                                         free(buff);
                                         self.writing = false;
                                         
                                           //dispatch_release(s);
                                       });
    
    dispatch_resume(s);
    self.writeSource = s;
}
-(void)readWithCompletionHandler:(completionHandler _Nonnull)completionHandler
{
    
    
    dispatch_source_t s = dispatch_source_create( DISPATCH_SOURCE_TYPE_READ, self.sfd, 0, self.socketQueue);
    self.readError = nil;
    dispatch_source_set_event_handler(s, ^(void)
                                      {
                                      self.reading = true;
                                      os_log_info(OS_LOG_DEFAULT, "DISPATCH_SOURCE_TYPE_READ B" );
                                      
                                      
                                      
                                      size_t    buff_sz        = 8 * 1024;
                                      void*    buff        = malloc( buff_sz );
                                      
                                      assert(buff != NULL);
                                      ssize_t            nbytes        = read( self.sfd, buff, buff_sz );
                                      dispatch_source_cancel(s);
                                      if (nbytes == 0){
                                          //remote closed
                                          os_log_info(OS_LOG_DEFAULT, "all bytes read" );
                                          
                                          dispatch_async(self.dispatchQueue, ^{
                                                  //socket.incoming(socket, data);
                                              
                                              completionHandler(nil,nil);
                                          });
                                      }else if (nbytes == -1 ){
                                          //read error
                                          os_log_info(OS_LOG_DEFAULT, "server_read: error on read!" );
                                          NSString *str = [NSString stringWithFormat:@"%s",strerror(errno)];
                                          NSError *e = [[NSError alloc] initWithDomain:@"com.socket.error" code:errno userInfo:@{NSLocalizedDescriptionKey:str}];
                                          
                                          dispatch_async(self.dispatchQueue, ^{
                                                  //socket.incoming(socket, data);
                                              
                                              completionHandler(nil,e);
                                          });
                                      }else {
                                          //success
                                          os_log_info(OS_LOG_DEFAULT, "DISPATCH_SOURCE_TYPE_READ B - server_read success" );
                                          /* We do this swap on every read(2), which is wasteful. But there is a
                                           * way to avoid doing this every time and not introduce an extra
                                           * parameter. See if you can find it.
                                           */
                                          NSData *data = [NSData dataWithBytes:buff length:nbytes];
                                          
                                          
                                          dispatch_async(self.dispatchQueue, ^{
                                                  //socket.incoming(socket, data);
                                              completionHandler(data,nil);
                                          });
                                          
                                      }
                                      
                                      free( buff );
                                      });
    
    dispatch_source_set_cancel_handler(s, ^(void)
                                       {
                                       os_log_info(OS_LOG_DEFAULT, "DISPATCH_SOURCE_TYPE_READ B - canceled" );
                                       //cancel 1 somedata 2 error 3 close
                                           //dispatch_release( s )
                                       self.reading = false;
                                       });
    
    
    dispatch_resume(s);
    self.readSource = s;
}

//什么时候关闭掉socket
//raw socket close??
//todo test
-(void)closeReadWithError:(NSError*_Nullable)e
{
    //close( self.sfd );
    if (self.reading){
        dispatch_cancel(self.readSource);
    }
    if (self.writing){
        dispatch_cancel(self.writeSource);
    }
    close(self.sfd);
    
}
-(void)closeWriteWithError:(NSError*_Nullable)e
{
    if (self.writing){
        dispatch_cancel(self.writeSource);
    }
}

-(void)close
{
    
}
-(void)connectRemote:(const char *)hostname service:(const char *)service
{
    int err;
    int sock;
    struct addrinfo hints, *res, *res0;
    const char *cause = NULL;
    
    memset(&hints, 0, sizeof(hints));
    hints.ai_family = PF_INET; // For udp, hint to ipv4
    hints.ai_socktype = SOCK_STREAM;
    err = getaddrinfo(hostname, service, &hints, &res0);
    if (err) {
        fprintf(stderr, "%s", gai_strerror(err));
        return ;
    }
    sock = -1;
    for (res = res0; res; res = res->ai_next) {
        sock = socket(res->ai_family, res->ai_socktype,
                      res->ai_protocol);
        if (sock < 0) {
            cause = "socket";
            continue;
        }
        
        if (connect(sock, res->ai_addr, res->ai_addrlen) < 0) {
            cause = "connect";
            close(sock);
            sock = -1;
            continue;
        }
        
        break;  /* okay we got one */
    }
    if (sock < 0) {
        fprintf(stderr, "%s", cause);
    }
    freeaddrinfo(res0);
    
    self.sfd = sock;
}
@end
