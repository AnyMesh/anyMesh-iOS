//
//  MeshUDPHandler.h
//  anyMesh
//
//  Created by David Paul on 4/28/14.
//  Copyright (c) 2014 dpTools. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncUdpSocket.h"

@interface MeshUDPHandler : NSObject <GCDAsyncUdpSocketDelegate> {
    GCDAsyncUdpSocket *udpSocket;
    NSData *message;
    int port;
    NSTimer *broadcastTimer;
}

@end
