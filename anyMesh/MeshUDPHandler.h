//
//  MeshUDPHandler.h
//  anyMesh
//
//  Created by David Paul on 4/28/14.
//  Copyright (c) 2014 dpTools. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncUdpSocket.h"
@class AnyMesh;

@interface MeshUDPHandler : NSObject <GCDAsyncUdpSocketDelegate> {
    AnyMesh *am;
    GCDAsyncUdpSocket *udpSocket;
    NSData *message;
    int port;
    NSTimer *broadcastTimer;
}

-(id)initWithBroadcastMessage:(NSString*)msg onPort:(int)thePort;
-(void)startBroadcasting;

@end
