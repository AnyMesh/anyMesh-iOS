//
//  MeshTCPHandler.m
//  anyMesh
//
//  Created by David Paul on 4/29/14.
//  Copyright (c) 2014 dpTools. All rights reserved.
//

#import "MeshTCPHandler.h"
#import "MeshUDPHandler.h"
#import "GCDAsyncSocket.h"
#import "MeshDeviceInfo.h"
#import "MeshMessage.h"
#import "NSData+lineReturn.h"
#import "SocketInfo.h"

@implementation MeshTCPHandler

-(id)initWithAnyMesh:(AnyMesh *)anyMesh
{
    if (self = [super init]) {
        tcpPort = TCP_PORT;
        am = anyMesh;
		listenSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:am.socketQueue];
        
		// Setup an array to store all accepted client connections
		connections = [[NSMutableArray alloc] initWithCapacity:1];
        
    }
    return self;
}

-(void)beginListening
{
    NSError *error;
    BOOL success = [listenSocket acceptOnPort:tcpPort error:&error];
    if (!success) {
        tcpPort++;
        [self beginListening];
    }
    else {
        [am.udpHandler startBroadcastingWithPort:tcpPort];
    }
}


-(void)disconnectAll
{
    [listenSocket disconnect];
    for(GCDAsyncSocket *socket in connections)
    {
        [socket disconnect];
    }
}

- (void)connectTo:(NSString*)ipAddress port:(int)port name:(NSString *)name
{
    if ([self socketForName:name]) return;
    
    GCDAsyncSocket *socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:am.socketQueue];
    
    MeshDeviceInfo *dInfo = [[MeshDeviceInfo alloc] init];
    dInfo.ipAddress = ipAddress;
    SocketInfo *sInfo = [[SocketInfo alloc] init];
    sInfo.dInfo = dInfo;
    socket.userData = sInfo;

    @synchronized(connections){[connections addObject:socket];}
    
    [socket connectToHost:ipAddress onPort:port error:nil];
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
            SocketInfo *info = (SocketInfo*)connection.userData;
            MeshDeviceInfo *devInfo = info.dInfo;
            if ([devInfo.listensTo containsObject:target]) [connection writeData:[msgData addLineReturn] withTimeout:-1 tag:0];
        }
    }
    else {
        for (GCDAsyncSocket *connection in connections) {
            SocketInfo *info = (SocketInfo*)connection.userData;
            MeshDeviceInfo *devInfo = info.dInfo;
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

-(void)sendPassTo:(GCDAsyncSocket*)socket
{
    NSDictionary *message = @{KEY_TYPE:@"pass"};
    NSData *msgData = [NSJSONSerialization dataWithJSONObject:message options:0 error:nil];
    [socket writeData:[msgData addLineReturn] withTimeout:-1 tag:0];
}

-(NSArray*)getConnections
{
    NSMutableArray *devices = [[NSMutableArray alloc] init];
    @synchronized(connections){
        for (GCDAsyncSocket* connection in connections)
        {
            SocketInfo *info = (SocketInfo*)connection.userData;
            MeshDeviceInfo *dInfo = info.dInfo;
            if (dInfo.name.length > 0) [devices addObject:[dInfo _clone]];
        }
    }
    return devices;
}

#pragma mark Socket Delegate Methods
- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
	// This method is executed on the socketQueue (not the main thread)
    SocketInfo *info = [[SocketInfo alloc] init];
    MeshDeviceInfo *dInfo = [[MeshDeviceInfo alloc] init];
    info.dInfo = dInfo;
    info.serverRelationship = TRUE;
    newSocket.userData = info;
	@synchronized(connections){[connections addObject:newSocket];}
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
                SocketInfo *info = (SocketInfo*)sock.userData;
                MeshDeviceInfo *dInfo = info.dInfo;
                
                if (info.serverRelationship) {
                    //validate, add device info and send info back
                    if ([self socketForName:msg.sender]) {
                        [connections removeObject:sock];
                        [sock disconnect];
                    }
                    else {
                        dInfo.name = msg.sender;
                        dInfo.listensTo = msg.listensTo;
                        [self sendInfoTo:sock];
                    }
                }
                else {
                    //validate, add device, notify, and send PASS.  check array index
                    GCDAsyncSocket *existingSocket = [self socketForName:msg.sender];
                    if (existingSocket) {
                        if ([connections indexOfObject:existingSocket] < [connections indexOfObject:sock]) {
                            [connections removeObject:sock];
                            [sock disconnect];
                            return;
                        }
                    }
                    [self sendPassTo:sock];
                    dInfo.name = msg.sender;
                    dInfo.listensTo = msg.listensTo;
                    [am _tcpConnectedTo:sock];
                }
                /*
                dInfo.name = msg.sender;
                dInfo.listensTo = msg.listensTo;
                
                if ([dInfo _validate]) [am _tcpConnectedTo:sock];
                else [sock disconnect];
                */
            }
            else if (msg.type == MeshMessageTypePass) {
                //notify
                [am _tcpConnectedTo:sock];
            }
            
            
            else {
                [am messageReceived:msg];
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
		
		@synchronized(connections){if([connections containsObject:sock])[connections removeObject:sock];}
	}
}


- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    [self sendInfoTo:sock];
    [sock readDataToData:[GCDAsyncSocket CRLFData] withTimeout:-1 tag:0];
}

#pragma mark Utility
- (GCDAsyncSocket*)socketForName:(NSString*)name
{
    @synchronized(connections){
        for (GCDAsyncSocket *connection in connections)
        {
            SocketInfo *info = (SocketInfo*)connection.userData;
            MeshDeviceInfo *dInfo = info.dInfo;
            if ([dInfo.name isEqualToString:name]) {
                return connection;
            }
        }
    }
    return nil;
}

@end
