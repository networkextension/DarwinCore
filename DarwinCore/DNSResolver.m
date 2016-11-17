//
//  DNSResolver.m
//  Surf
//
//  Created by 孔祥波 on 7/27/16.
//  Copyright © 2016 yarshure. All rights reserved.
//

#import "DNSResolver.h"
#include <dns_sd.h>
#include <resolv.h>
#include <sys/types.h>
#include <netinet/in.h>
#include <arpa/nameser.h>
#include <resolv.h>
#include <arpa/inet.h>

struct  SDRecord {
    const char                          *fullname;
    uint16_t rrtype;
    uint16_t rrclass;
    uint32_t ttl;
    uint16_t rdlen;
    const void                          *rdata;
} SDRecord;

@interface DNSResolver ()
- (void)record:(const struct  SDRecord*)theRecord onInterface:(uint32_t)theIndex;
- (void)recordExpired:(const struct SDRecord *)theRecord;
@end
void DNSSD_API callback
(
 DNSServiceRef sdRef,
 DNSServiceFlags flags,
 uint32_t interfaceIndex,
 DNSServiceErrorType errorCode,
 const char                          *fullname,
 uint16_t rrtype,
 uint16_t rrclass,
 uint16_t rdlen,
 const void                          *rdata,
 uint32_t ttl,
 void                                *context
 );

void DNSSD_API callback
(
 DNSServiceRef sdRef,
 DNSServiceFlags flags,
 uint32_t interfaceIndex,
 DNSServiceErrorType errorCode,
 const char                          *fullname,
 uint16_t rrtype,
 uint16_t rrclass,
 uint16_t rdlen,
 const void                          *rdata,
 uint32_t ttl,
 void                                *context
 )
{
    //NSLog(@"queryCallback: flags == %d error code == %d", flags, errorCode);
    DNSResolver *service =(__bridge DNSResolver*)context;
    if (errorCode != kDNSServiceErr_NoError)
    {
        [service failed:errorCode];
    }
    else
    {
        //NSLog(@"theName == %s theType == %u", fullname, rrtype);
        
        struct SDRecord  rr = {
            fullname,
            rrtype,
            rrclass,
            ttl,
            rdlen,
            rdata
        };
        
        if ((flags & kDNSServiceFlagsAdd) != 0)
        {
            [service record:&rr onInterface:interfaceIndex];
        }
        else
        {
            [service recordExpired:&rr];
        }
    }
    
}

@implementation DNSResultRecord
@end
@implementation DNSResolver
- (void)record:(const struct  SDRecord*)theRecord onInterface:(uint32_t)theIndex
{
    if (theRecord->rrtype == kDNSServiceType_A) {
        
        char result[32] = "";
        const unsigned char *rd  = theRecord->rdata;
        
        snprintf(result, sizeof(result), "%d.%d.%d.%d", rd[0], rd[1], rd[2], rd[3]);
        NSString *r = [[NSString alloc] initWithUTF8String:result];
        DNSResultRecord *record = [[DNSResultRecord alloc] init];
        record.type = kDNSServiceErr_NoError;
        record.ipaddress = r;
        if (self.dnsRequestCompleted != nil){
            self.dnsRequestCompleted(record);
            self.dnsRequestCompleted = nil;
        }
        
    }
    
}
- (void)recordExpired:(const struct SDRecord *)theRecord
{
    DNSResultRecord *record = [[DNSResultRecord alloc] init];
    record.type = kDNSServiceErr_Timeout;
    
    if (self.dnsRequestCompleted != nil){
        self.dnsRequestCompleted(record);
        self.dnsRequestCompleted = nil;
    }
    //[self.delegate query:self recordDidExpire:theRecord];
}
- (void)failed:(DNSServiceErrorType)theErrorCode
{
    if (self.dnsRequestCompleted != nil){
        DNSResultRecord *record = [[DNSResultRecord alloc] init];
        record.type = kDNSServiceErr_Timeout;
        self.dnsRequestCompleted(record);
        self.dnsRequestCompleted = nil;
    }
    

}
-(void)querey:(NSString *)domain complete:(DNSCallback)complete
{
    self.dnsRequestCompleted = complete;
    dispatch_queue_t q = dispatch_queue_create("com.yarshure.dns", DISPATCH_QUEUE_CONCURRENT);
    __weak DNSResolver *weakSelf = self;
    dispatch_async(q,^{
        DNSServiceRef sdRef;
        DNSServiceErrorType res;
        
        res=DNSServiceQueryRecord(
                                  &sdRef, 0, 0,
                                  [domain UTF8String],
                                  kDNSServiceType_A,
                                  kDNSServiceClass_IN,
                                  callback,
                                  (__bridge void *)(self)
                                  );
        if (res != kDNSServiceErr_NoError)
        {
            //NSLog(@"DNSServiceQueryRecord: %d", res);
            DNSResultRecord *record = [[DNSResultRecord alloc] init];
            record.type = res;
            weakSelf.dnsRequestCompleted(record);
            weakSelf.dnsRequestCompleted = nil;
            
        }else {
             DNSServiceProcessResult(sdRef);
        }
        DNSServiceRefDeallocate(sdRef);
    });

}
-(void)dealloc
{
    //DLog(@"DNSResolver dealloc ,%@",self.hostname);
}
@end
