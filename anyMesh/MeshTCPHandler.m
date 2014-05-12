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

@implementation MeshTCPHandler

-(id)initWithPort:(int)port
{
    if (self = [super init]) {
        tcpPort = port;
    
        am = [AnyMesh sharedInstance];
        
		listenSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:[AnyMesh sharedInstance].socketQueue];
		[listenSocket acceptOnPort:port error:nil];
        
		// Setup an array to store all accepted client connections
		connections = [[NSMutableArray alloc] initWithCapacity:1];
        
    }
    return self;
}

#pragma mark Server
- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
	// This method is executed on the socketQueue (not the main thread)
	
	@synchronized(connections)
	{
		[connections addObject:newSocket];
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
	NSLog(@"read");
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
		
		@synchronized(connections)
		{
			[connections removeObject:sock];
		}
	}
}

#pragma mark Client
- (void)connectTo:(NSString*)ipAddress
{
    for (GCDAsyncSocket *connection in connections) {
        MeshDeviceInfo *devInfo = (MeshDeviceInfo*)connection.userData;
        if ([devInfo.ipAddress isEqualToString:ipAddress] ) return;
    }
    

    GCDAsyncSocket *socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:[AnyMesh sharedInstance].socketQueue];
    [connections addObject:socket];
        
    [socket connectToHost:ipAddress onPort:TCP_PORT error:nil];
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    NSLog(@"client - server connected!");
}


-(void)sendMessageTo:(NSString *)target withType:(MeshMessageType)type dataObject:(NSDictionary *)dataDict
{
    NSArray *types = @[@"pub", @"req", @"res"];
    NSDictionary *message = @{KEY_SENDER:am.name,
                              KEY_TARGET:target,
                              KEY_TYPE:types[type],
                              KEY_DATA:dataDict};
    NSData *msgData = [NSJSONSerialization dataWithJSONObject:message options:0 error:nil];
    
    if (type == MeshMessageTypePublish) {
        for (GCDAsyncSocket *connection in connections) {
            MeshDeviceInfo *devInfo = (MeshDeviceInfo*)connection.userData;
            if ([devInfo.listensTo containsObject:target]) [connection writeData:msgData withTimeout:-1 tag:0];
        }
    }
    else {
        for (GCDAsyncSocket *connection in connections) {
            MeshDeviceInfo *devInfo = (MeshDeviceInfo*)connection.userData;
            if ([devInfo.name isEqualToString:target]) {
                [connection writeData:msgData withTimeout:-1 tag:0];
                return;
            }
        }
    }
}

@end
