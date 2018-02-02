//
//  GCDSocket.h
//  DarwinCore
//
//  Created by yarshure on 2017/9/26.
//  Copyright © 2017年 Kong XiangBo. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GCDSocketServer.h"
@class GCDSocket;
typedef void (^completionHandler)(NSData * _Nullable data,NSError * _Nullable error);
typedef void (^writeCompletionHandler)(NSError * _Nullable error);
typedef void (^newSocket)(GCDSocket * _Nonnull s);

@interface GCDSocket : NSObject
@property (nonatomic) int sfd;
@property (nonatomic) boolean_t writing;
@property (nonatomic) boolean_t reading;
@property (nonatomic) NSError * _Nullable readError;
@property (nonatomic) NSError * _Nullable writeError;
@property (nonatomic) boolean_t g_accepting_requests;
@property (nonatomic,strong ) NSString * _Nonnull remote;
@property (nonatomic) int port;
@property (nonatomic) dispatch_queue_t _Nonnull  dispatchQueue;
@property (nonatomic) dispatch_queue_t _Nonnull  socketQueue;

@property (nonatomic) dispatch_source_t _Nullable readSource;
@property (nonatomic) dispatch_source_t _Nullable writeSource;
-(instancetype _Nonnull )initWithRemoteaddr:(NSString*_Nonnull)addr port:(NSString*_Nonnull)port;
-(instancetype _Nonnull )initWithFD:(int)fd remoteaddr:(NSString*_Nonnull)addr port:(int)port;
-(instancetype _Nonnull )initWithPort:(int)port share:(bool)share;//create and listen
-(void)accept:(newSocket _Nonnull )news;

-(void)write:(NSData*_Nonnull)data completionHandler:(writeCompletionHandler _Nonnull )completionHandler;
-(void)readWithCompletionHandler:(completionHandler _Nonnull)completionHandler;

-(void)closeReadWithError:(NSError*_Nullable)e;
-(void)closeWriteWithError:(NSError*_Nullable)e;
//没空实现啊
//-(void)startTLS;
@end
