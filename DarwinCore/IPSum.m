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
#import <mach/mach.h>
#import <mach/mach_host.h>

void print_free_memory ()
{
    mach_port_t host_port;
    mach_msg_type_number_t host_size;
    vm_size_t pagesize;
    
    host_port = mach_host_self();
    host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    host_page_size(host_port, &pagesize);
    
    vm_statistics_data_t vm_stat;
    
    if (host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size) != KERN_SUCCESS) {
        NSLog(@"Failed to fetch vm statistics");
    }
    
    /* Stats in bytes */
    natural_t mem_used = (vm_stat.active_count +
                          vm_stat.inactive_count +
                          vm_stat.wire_count) * (unsigned int)pagesize;
    natural_t mem_free = vm_stat.free_count * (unsigned int)pagesize;
    natural_t mem_total = mem_used + mem_free;
    NSLog(@"used: %u free: %u total: %u", mem_used, mem_free, mem_total);
}
