//
//  AnyMesh.h
//  anyMesh
//
//  Created by David Paul on 4/29/14.
//  Copyright (c) 2014 dpTools. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MeshTCPHandler;
@class MeshTCPClient;
@class MeshUDPHandler;
@class MeshMessage;
@class MeshDeviceInfo;
@class GCDAsyncSocket;

#define KEY_TYPE @"type"
#define KEY_TARGET @"target"
#define KEY_SENDER @"sender"
#define KEY_DATA @"data"
#define KEY_NAME @"name"
#define KEY_LISTENSTO @"listensTo"

#define UDP_PORT 12345
#define TCP_PORT 12346

typedef enum {
    MeshMessageTypePublish,
    MeshMessageTypeRequest,
    MeshMessageTypeResponse,
    MeshMessageTypeInfo,
    MeshMessageTypePass
} MeshMessageType;

@class AnyMesh;
@protocol AnyMeshDelegate <NSObject>
-(void)anyMesh:(AnyMesh*)anyMesh receivedMessage:(MeshMessage*)message;
-(void)anyMesh:(AnyMesh*)anyMesh connectedTo:(MeshDeviceInfo*)device;
-(void)anyMesh:(AnyMesh*)anyMesh disconnectedFrom:(NSString*)name;
@optional
-(void)anyMesh:(AnyMesh *)anyMesh updatedSubscriptions:(NSArray*)subscriptions forName:(NSString*)name;


@end

@interface AnyMesh : NSObject 

@property (nonatomic) MeshTCPHandler *tcpHandler;
@property (nonatomic) MeshUDPHandler *udpHandler;
@property (nonatomic) dispatch_queue_t socketQueue;
@property (nonatomic) NSObject<AnyMeshDelegate> *delegate;

@property (nonatomic) int discoveryPort;
@property (nonatomic) NSString *name;
@property (nonatomic) NSArray *subscriptions;
@property (nonatomic) NSString *networkID;


-(void)connectWithName:(NSString*)name subscriptions:(NSArray*)subscriptions;
-(NSArray*)connectedDevices;
-(void)messageReceived:(MeshMessage*)message;
-(void)publishToTarget:(NSString*)target withData:(NSDictionary *)dataDict;
-(void)requestToTarget:(NSString*)target withData:(NSDictionary *)dataDict;
-(void)updateSubscriptions:(NSArray*)subscriptions;

-(void)suspend;
-(void)resume;


#pragma mark Internal Use
-(void)_tcpConnectedTo:(GCDAsyncSocket*)socket;
-(void)_tcpDisconnectedFrom:(GCDAsyncSocket*)socket;
-(void)_tcpUpdatedSubscriptions:(NSArray*)subscriptions forName:(NSString*)name;
- (NSString *)_getIPAddress;

@end
