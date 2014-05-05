//
//  MeshTCPHandler.h
//  anyMesh
//
//  Created by David Paul on 4/29/14.
//  Copyright (c) 2014 dpTools. All rights reserved.
//

#import <Foundation/Foundation.h>
@class GCDAsyncSocket;
@class MeshDeviceInfo;

@interface MeshTCPServer : NSObject
{
    int tcpPort;
	
	GCDAsyncSocket *listenSocket;
	NSMutableArray *connectedSockets;

    
}

-(id)initWithPort:(int)port;

@end
