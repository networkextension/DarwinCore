//
//  IPSum.m
//  DarwinCore
//
//  Created by 孔祥波 on 02/06/2017.
//  Copyright © 2017 Kong XiangBo. All rights reserved.
//

#import "IPSum.h"

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
