//
//  AnyMesh.m
//  anyMesh
//
//  Created by David Paul on 4/29/14.
//  Copyright (c) 2014 dpTools. All rights reserved.
//

#import "AnyMesh.h"
#import "MeshUDPHandler.h"
#import "MeshTCPHandler.h"
#import "MeshDeviceInfo.h"
#import "SocketInfo.h"
#import <ifaddrs.h>
#import <arpa/inet.h>


@implementation AnyMesh


-(id)init
{
    if (self = [super init]) {
        self.socketQueue = dispatch_queue_create("socketQueue", NULL);
        self.networkID = @"anymesh";
        self.discoveryPort = UDP_PORT;
        connections = [[NSMutableArray alloc] init];
        listenSocket = [[AsyncSocket alloc] initWithDelegate:self];
        
        [self startUDPListener];
    }
    return self;
}

-(void)startUDPListener
{
    udpSocket = [[AsyncUdpSocket alloc] initWithDelegate:self];
    [udpSocket enableBroadcast:true error:nil];
    
    NSError *error = nil;
    if (![udpSocket bindToPort:am.discoveryPort error:&error])
    {
        NSLog(@"Error starting server (bind): %@", error);
        return nil;
    }
    if (![udpSocket beginReceiving:&error])
    {
        [udpSocket close];
        
        NSLog(@"Error starting server (recv): %@", error);
        return nil;
    }
}

-(void)connectWithName:(NSString*)name subscriptions:(NSArray*)listensTo
{
    _name = name;
    _subscriptions = listensTo;
    [_tcpHandler beginListening];
}

-(void)updateSubscriptions:(NSArray*)newSubscriptions
{
    _subscriptions = newSubscriptions;
    [_tcpHandler sendInfoUpdates];
    
}

-(NSArray*)connectedDevices
{
    return [_tcpHandler getConnections];
}

-(void)suspend
{
    [_udpHandler stopBroadcasting];
    [_tcpHandler disconnectAll];
    
}

-(void)resume
{
    //[_udpHandler startBroadcasting];
    if(self.name)[_tcpHandler beginListening];
}

#pragma mark Connections
-(void)_tcpConnectedTo:(GCDAsyncSocket *)socket
{
    SocketInfo *socketInfo = (SocketInfo*)socket.userData;
    if (socketInfo.dInfo.name) {
        [self.delegate anyMesh:self connectedTo:[socketInfo.dInfo _clone]];
    }
}
-(void)_tcpDisconnectedFrom:(GCDAsyncSocket *)socket
{
    SocketInfo *socketInfo = (SocketInfo*)socket.userData;
    if (socketInfo.dInfo.name) {
        [self.delegate anyMesh:self disconnectedFrom:[NSString stringWithString:socketInfo.dInfo.name]];
    }
}

#pragma mark - Shutting down
-(void)disconnectAll
{
    [listenSocket disconnect];
    for(GCDAsyncSocket *socket in connections)
    {
        [socket disconnect];
    }
}

#pragma mark Messaging
- (void)messageReceived:(MeshMessage *)message
{
    [self.delegate anyMesh:self receivedMessage:message];
}

- (void)publishToTarget:(NSString *)target withData:(NSDictionary *)dataDict
{
     [_tcpHandler sendMessageTo:target withType:MeshMessageTypePublish dataObject:dataDict];
}
- (void)requestToTarget:(NSString *)target withData:(NSDictionary *)dataDict
{
     [_tcpHandler sendMessageTo:target withType:MeshMessageTypeRequest dataObject:dataDict];
}

#pragma mark Socket Delegate Methods
- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
    // This method is executed on the socketQueue (not the main thread)
    MeshDeviceInfo *dInfo = [[MeshDeviceInfo alloc] init];
    newSocket.userData = dInfo;
    @synchronized(connections){[connections addObject:newSocket];}
    [newSocket readDataToData:[GCDAsyncSocket CRLFData] withTimeout:-1 tag:0];
}


- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    dispatch_async(dispatch_get_main_queue(), ^{
        @autoreleasepool {
            NSData *strData = [data subdataWithRange:NSMakeRange(0, [data length] - 2)];
            NSDictionary *msgObj = [NSJSONSerialization JSONObjectWithData:strData options:0 error:nil];
            MeshMessage *msg = [[MeshMessage alloc] initWithMessageObject:msgObj];
            
            if (msg.type == MessageTypeSystem) {
                
                MeshDeviceInfo *dInfo = sock.userData;
                //TODO: handle system msg
                
                if ([self.delegate respondsToSelector:@selector(anyMesh:updatedSubscriptions:forName:)]) {
                    [self.delegate anyMesh:self updatedSubscriptions:subscriptions forName:name];
                }
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
        @synchronized(connections){if([connections containsObject:sock])[connections removeObject:sock];}
        dispatch_async(dispatch_get_main_queue(), ^{
            @autoreleasepool {
                if ([self.connections containsObject:sock]) {
                    MeshDeviceInfo *dInfo = sock.userData;
                    self.delegate anyMesh:self disconnectedFrom:dInfo.name;
                }
            }
        });
    }
}


- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    MeshDeviceInfo *dInfo = [[MeshDeviceInfo alloc] init];
    SocketInfo *sInfo = [[SocketInfo alloc] init];
    sInfo.dInfo = dInfo;
    sock.userData = sInfo;
    
    @synchronized(connections){[connections addObject:sock];}
    
    [self sendInfoTo:sock update:FALSE];
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

- (NSString *)_getIPAddress
{
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            if( temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                NSString *interface = [NSString stringWithUTF8String:temp_addr->ifa_name];
                
                if ([interface isEqualToString:@"en0"] || [interface isEqualToString:@"en1"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    // Free memory
    freeifaddrs(interfaces);
    
    return address;
}

@end
