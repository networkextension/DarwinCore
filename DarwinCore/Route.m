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
