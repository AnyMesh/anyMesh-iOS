//
//  AnyMesh.h
//  anyMesh
//
//  Created by David Paul on 4/29/14.
//  Copyright (c) 2014 dpTools. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MeshTCPHandler;
@class MeshUDPHandler;
@class MeshMessage;

@interface AnyMesh : NSObject

@property (nonatomic) MeshTCPHandler *tcpHandler;
@property (nonatomic) MeshUDPHandler *udpHandler;

+ (id)sharedInstance;

-(void)messageReceived:(MeshMessage*)message;

@end
