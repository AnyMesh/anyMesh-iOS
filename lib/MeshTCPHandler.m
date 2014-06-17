//
//  MeshTCPHandler.m
//  anyMesh
//
//  Created by David Paul on 4/29/14.
//  Copyright (c) 2014 dpTools. All rights reserved.
//

#import "MeshTCPHandler.h"
#import "GCDAsyncSocket.h"
#import "MeshDeviceInfo.h"
#import "MeshMessage.h"
#import "NSData+lineReturn.h"

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

- (void)connectTo:(NSString*)ipAddress
{
    if ([self IpExistsInConnections:ipAddress]) return;
    
    GCDAsyncSocket *socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:[AnyMesh sharedInstance].socketQueue];
    
    MeshDeviceInfo *dInfo = [[MeshDeviceInfo alloc] init];
    dInfo.ipAddress = ipAddress;
    socket.userData = dInfo;
    @synchronized(connections){[connections addObject:socket];}
    
    [socket connectToHost:ipAddress onPort:TCP_PORT error:nil];
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
            if ([devInfo.listensTo containsObject:target]) [connection writeData:[msgData addLineReturn] withTimeout:-1 tag:0];
        }
    }
    else {
        for (GCDAsyncSocket *connection in connections) {
            MeshDeviceInfo *devInfo = (MeshDeviceInfo*)connection.userData;
            if ([devInfo.name isEqualToString:target]) {
                [connection writeData:[msgData addLineReturn] withTimeout:-1 tag:0];
                return;
            }
        }
    }
}

-(void)sendInfoTo:(GCDAsyncSocket*)socket
{
    NSDictionary *message = @{KEY_TYPE:@"info",
                              KEY_SENDER:am.name,
                              KEY_LISTENSTO:am.listensTo};
    NSData *msgData = [NSJSONSerialization dataWithJSONObject:message options:0 error:nil];
    [socket writeData:[msgData addLineReturn] withTimeout:-1 tag:0];
    
}

-(NSArray*)getConnections
{
    NSMutableArray *devices = [[NSMutableArray alloc] init];
    @synchronized(connections){
        for (GCDAsyncSocket* connection in connections)
        {
            MeshDeviceInfo *info = connection.userData;
            if (info.name.length > 0) [devices addObject:[info _clone]];
        }
    }
    return devices;
}

#pragma mark Socket Delegate Methods
- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
	// This method is executed on the socketQueue (not the main thread)
    MeshDeviceInfo *dInfo = [[MeshDeviceInfo alloc] init];
    
    dInfo.ipAddress = [newSocket connectedHost];
    
    if ([self IpExistsInConnections:dInfo.ipAddress]) {
        [newSocket disconnect];
        return;
    }
    
    newSocket.userData = dInfo;
    
	@synchronized(connections){[connections addObject:newSocket];}
    
    [self sendInfoTo:newSocket];
		
	dispatch_async(dispatch_get_main_queue(), ^{
		@autoreleasepool {
            
		}
	});
	
	[newSocket readDataToData:[GCDAsyncSocket CRLFData] withTimeout:-1 tag:0];
}


- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
	dispatch_async(dispatch_get_main_queue(), ^{
		@autoreleasepool {
            
			NSData *strData = [data subdataWithRange:NSMakeRange(0, [data length] - 2)];
			NSDictionary *msgObj = [NSJSONSerialization JSONObjectWithData:strData options:0 error:nil];
            MeshMessage *msg = [[MeshMessage alloc] initWithHandler:self messageObject:msgObj];
           
            if (msg.type == MeshMessageTypeInfo) {
                MeshDeviceInfo *dInfo = (MeshDeviceInfo*)sock.userData;
                
                dInfo.name = msg.sender;
                dInfo.listensTo = msg.listensTo;
                
                if ([dInfo _validate]) [am _tcpConnectedTo:sock];
                else [sock disconnect];
            }
            else {
                [[AnyMesh sharedInstance] messageReceived:msg];
            }
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
                [am _tcpDisconnectedFrom:sock];
			}
		});
		
		@synchronized(connections){[connections removeObject:sock];}
	}
}


- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    [self sendInfoTo:sock];
    [sock readDataToData:[GCDAsyncSocket CRLFData] withTimeout:-1 tag:0];
}

#pragma mark Utility
- (BOOL)IpExistsInConnections:(NSString*)address
{
    @synchronized(connections){
        for (GCDAsyncSocket* connection in connections)
        {
            MeshDeviceInfo *dInfo = (MeshDeviceInfo*)connection.userData;
            if ([dInfo.ipAddress isEqualToString:address]) {
                return true;
            }
        }
        return false;
    }
}


@end
