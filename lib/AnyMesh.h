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
    MeshMessageTypeInfo
} MeshMessageType;

@protocol AnyMeshDelegate <NSObject>

-(void)anyMeshReceivedMessage:(MeshMessage*)message;
-(void)anyMeshConnectedTo:(MeshDeviceInfo*)device;
-(void)anyMeshDisconnectedFrom:(NSString*)name;

@end

@interface AnyMesh : NSObject 

@property (nonatomic) MeshTCPHandler *tcpHandler;
@property (nonatomic) MeshUDPHandler *udpHandler;
@property (nonatomic) dispatch_queue_t socketQueue;
@property (nonatomic) NSObject<AnyMeshDelegate> *delegate;

@property (nonatomic) NSString *name;
@property (nonatomic) NSArray *listensTo;
@property (nonatomic) NSString *networkID;

+ (AnyMesh*)sharedInstance;

-(void)connectWithName:(NSString*)name listeningTo:(NSArray*)listensTo;
-(NSArray*)connectedDevices;
-(void)tcpConnectedTo:(GCDAsyncSocket*)socket;
-(void)tcpDisconnectedFrom:(GCDAsyncSocket*)socket;
-(void)messageReceived:(MeshMessage*)message;
-(void)publishToTarget:(NSString*)target withData:(NSDictionary *)dataDict;
-(void)requestToTarget:(NSString*)target withData:(NSDictionary *)dataDict;
- (NSString *)getIPAddress;

@end
