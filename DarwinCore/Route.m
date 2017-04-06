//
//  Route.m
//  DarwinCore
//
//  Created by 孔祥波 on 16/11/2016.
//  Copyright © 2016 Kong XiangBo. All rights reserved.
//

#import "Route.h"
#include <arpa/inet.h>
/*
 get route $netstat -an
 */
int	Aflag;		/* show addresses of protocol control block */

int	aflag;		/* show all sockets (including servers) */

int	bflag;		/* show i/f total bytes in/out */
int	cflag;		/* show specific classq */
int	dflag;		/* show i/f dropped packets */
int	Fflag;		/* show i/f forwarded packets */
#if defined(__APPLE__)
int	gflag;		/* show group (multicast) routing or stats */
#endif
int	iflag;		/* show interfaces */

int	lflag;		/* show routing table with use and ref */

int	Lflag;		/* show size of listen queues */
int	mflag;		/* show memory stats */

int	nflag;		/* show addresses numerically */


int	prioflag = -1;	/* show packet priority statistics */
int	Rflag;		/* show reachability information */
int	rflag;		/* show routing tables (or routing stats) */

int	sflag;		/* show protocol statistics */

int	Sflag;		/* show additional i/f link status */
int	tflag;		/* show i/f watchdog timers */
int	vflag;		/* more verbose */
int	Wflag;		/* wide display */
int	qflag;		/* classq stats display */
int	Qflag;		/* opportunistic polling stats display */
int	xflag;		/* show extended link-layer reachability information */

int	cq = -1;	/* send classq index (-1 for all) */
int	interval;	/* repeat interval for i/f stats */

char	*interface;	/* desired i/f for stats, or NULL for all i/fs */
int	unit;		/* unit number for above */


int	af;		/* address family */
char *
plural(int n)
{
    return (n > 1 ? "s" : "");
}
extern void routepr(char *p);

@implementation Route
+ (NSString*) currntRouter
{
    //  #if TARGET_OS_IPHONE
    rflag = 1;
    nflag = 1;
    aflag = 1;
    af = AF_INET;
    char  buffer[8196*10];
    memset(buffer, 0, 8196*10);
    routepr(buffer);
    NSString *result = [NSString stringWithCString:buffer encoding:NSASCIIStringEncoding];
    if (result == nil) {
        result = @"Get Route Failure";
    }
    return result;
    
}
@end
static unsigned short
ip_sum(
       unsigned char	*c,
       unsigned int	hlen
       )
{
    unsigned int	high, low, sum;
    
    high = low = 0;
    while (hlen-- > 0) {
        low += c[1] + c[3];
        high += c[0] + c[2];
        
        c += sizeof (int);
    }
    
    sum = (high << 8) + low;
    sum = (sum >> 16) + (sum & 65535);
    
    return (sum > 65535 ? sum - 65535 : sum);
}
#import <netinet/ip.h>
NSData* ipHeader(int len,__uint32_t src,__uint32_t dst,__uint16_t iden, u_char p)
{
    char buffer[20];
    struct ip *h =(struct ip*)buffer;
    
    //struct in_addr s,d;
    memset(h, 0, sizeof(struct ip));
    h->ip_v = 4;
    h->ip_hl = 5;
    h->ip_tos = 0;
    u_short l2= htons(len);
    memcpy(&h->ip_len, &l2, 2);
    //h->ip_len = len;
    
    h->ip_id = iden;
    h->ip_off = 0;
    
    h->ip_ttl = 0x3f;
    h->ip_p = p;
    h->ip_sum = 0;
    
    memcpy(&(h->ip_src.s_addr), &src, 4);
    
    memcpy(&(h->ip_dst.s_addr), &dst, 4);
    h->ip_sum=htons(~ip_sum((unsigned char *)h, h->ip_hl));//in_cksumdata(h,20);
    NSData *d = [NSData dataWithBytes:h length:20];
    return d;
}
