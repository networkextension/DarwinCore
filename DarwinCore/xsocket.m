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
int server_check_in(int port,bool share)
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
    if(share){
        saddr.sin_addr.s_addr = INADDR_ANY;
    }else {
        saddr.sin_addr.s_addr = inet_addr("127.0.0.1");//INADDR_ANY;
    }
    
    
    int result = bind(sockfd, (struct sockaddr *)&saddr, sizeof(saddr));
    assert(result == 0);
    
    result = listen(sockfd, -1);
    assert(result == 0);
    return sockfd;
}


