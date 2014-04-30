//
//  MeshTCPHandler.h
//  anyMesh
//
//  Created by David Paul on 4/29/14.
//  Copyright (c) 2014 dpTools. All rights reserved.
//

#import <Foundation/Foundation.h>
@class GCDAsyncSocket;

@interface MeshTCPHandler : NSObject
{
    int tcpPort;
    
    dispatch_queue_t socketQueue;
	
	GCDAsyncSocket *listenSocket;
	NSMutableArray *connectedSockets;
    NSMutableDictionary *connectedServers;
    
}

@end
