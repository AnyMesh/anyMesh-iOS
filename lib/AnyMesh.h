//
//  AnyMesh.h
//  anyMesh
//
//  Created by David Paul on 4/29/14.
//  Copyright (c) 2014 dpTools. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AsyncSocket.h"
#import "AsyncUdpSocket.h"
@class MeshMessage;
@class MeshDeviceInfo;

#define KEY_TYPE @"type"
#define KEY_TARGET @"target"
#define KEY_SENDER @"sender"
#define KEY_DATA @"data"
#define KEY_NAME @"name"
#define KEY_SUBSCRIPTIONS @"subscriptions"
#define KEY_ISUPDATE @"isUpdate"

#define UDP_PORT 12345
#define TCP_PORT 12346

typedef NS_ENUM(NSInteger, MeshMessageTypeGeneral) {
    MessageTypePublish,
    MessageTypeRequest,
    MessageTypeSystem
};
typedef NS_ENUM(NSInteger, MeshMessageTypeSystem) {
    MessageTypeSystemSubscription
};

@class AnyMesh;
@protocol AnyMeshDelegate <NSObject>
-(void)anyMesh:(AnyMesh*)anyMesh receivedMessage:(MeshMessage*)message;
-(void)anyMesh:(AnyMesh*)anyMesh connectedTo:(MeshDeviceInfo*)device;
-(void)anyMesh:(AnyMesh*)anyMesh disconnectedFrom:(NSString*)name;
@optional
-(void)anyMesh:(AnyMesh *)anyMesh updatedSubscriptions:(NSArray*)subscriptions forName:(NSString*)name;
@end


@interface AnyMesh : NSObject <AsyncSocketDelegate, AsyncUdpSocketDelegate> {
    	NSMutableArray *connections;
        AsyncSocket *listenSocket;
        int tcpPort;
        int workingPort;
    
        AsyncUdpSocket *udpSocket;
        NSTimer *broadcastTimer;
}


@property (nonatomic) NSObject<AnyMeshDelegate> *delegate;

@property (nonatomic) int discoveryPort;
@property (nonatomic) NSString *name;
@property (nonatomic) NSArray *subscriptions;
@property (nonatomic) NSString *networkID;


-(void)connectWithName:(NSString*)name subscriptions:(NSArray*)subscriptions;
-(NSArray*)connectedDevices;
-(void)publishToTarget:(NSString*)target withData:(NSDictionary *)dataDict;
-(void)requestToTarget:(NSString*)target withData:(NSDictionary *)dataDict;
-(void)updateSubscriptions:(NSArray*)subscriptions;

-(void)suspend;
-(void)resume;



@end
