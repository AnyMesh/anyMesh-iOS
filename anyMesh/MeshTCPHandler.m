//
//  MeshTCPHandler.m
//  anyMesh
//
//  Created by David Paul on 4/29/14.
//  Copyright (c) 2014 dpTools. All rights reserved.
//

#import "MeshTCPHandler.h"
#import "GCDAsyncSocket.h"
#import "MeshMessage.h"
#import "MeshDeviceInfo.h"
#import "AnyMesh.h"

@implementation MeshTCPHandler

-(id)initWithPort:(int)port
{
    if (self = [super init]) {
        tcpPort = port;
        
        socketQueue = dispatch_queue_create("socketQueue", NULL);
		
		listenSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:socketQueue];
		
		// Setup an array to store all accepted client connections
		connectedSockets = [[NSMutableArray alloc] initWithCapacity:1];
        
    }
    return self;
}

#pragma mark Server
- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
	// This method is executed on the socketQueue (not the main thread)
	
	@synchronized(connectedSockets)
	{
		[connectedSockets addObject:newSocket];
	}
		
	dispatch_async(dispatch_get_main_queue(), ^{
		@autoreleasepool {
            
			NSLog(@"server - client connected!");
            
		}
	});
	
	[newSocket readDataToData:[GCDAsyncSocket CRLFData] withTimeout:-1 tag:0];
}


- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
	// This method is executed on the socketQueue (not the main thread)
	
	dispatch_async(dispatch_get_main_queue(), ^{
		@autoreleasepool {
            
			NSData *strData = [data subdataWithRange:NSMakeRange(0, [data length] - 2)];
			NSDictionary *msgObj = [NSJSONSerialization JSONObjectWithData:strData options:0 error:nil];
            MeshMessage *msg = [[MeshMessage alloc] initWithHandler:self messageObject:msgObj];
            [[AnyMesh sharedInstance] messageReceived:msg];
            }
	});
	
	[sock readDataToData:[GCDAsyncSocket CRLFData] withTimeout:-1 tag:0];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
	if (sock != listenSocket)
	{
		dispatch_async(dispatch_get_main_queue(), ^{
			@autoreleasepool {
                
				NSLog(@"server - client disconnected");
                
			}
		});
		
		@synchronized(connectedSockets)
		{
			[connectedSockets removeObject:sock];
		}
	}
}

#pragma mark Client
- (void)connectTo:(MeshDeviceInfo*)device
{
    if (![connectedServers valueForKey:device.name]) {
        //TODO connect
        
        
        //TODO store name and subscribesTo inside object SOMEHOW?
        
        
    }
}


@end
