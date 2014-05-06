//
//  AnyMesh.h
//  anyMesh
//
//  Created by David Paul on 4/29/14.
//  Copyright (c) 2014 dpTools. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MeshTCPServer;
@class MeshTCPClient;
@class MeshUDPHandler;
@class MeshMessage;

#define KEY_TYPE @"type"
#define KEY_TARGET @"target"
#define KEY_SENDER @"sender"
#define KEY_DATA @"data"
#define KEY_NAME @"name"
#define KEY_LISTENSTO @"listensTo"

#define UDP_PORT 12345
#define TCP_PORT 12346

@interface AnyMesh : NSObject 

@property (nonatomic) MeshTCPServer *tcpServer;
@property (nonatomic) MeshTCPClient *tcpClient;
@property (nonatomic) MeshUDPHandler *udpHandler;
@property (nonatomic) dispatch_queue_t socketQueue;

+ (AnyMesh*)sharedInstance;

-(void)connectWithName:(NSString*)name listeningTo:(NSArray*)listensTo;
-(void)messageReceived:(MeshMessage*)message;

@end
