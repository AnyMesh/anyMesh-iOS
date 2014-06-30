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
#import "GCDAsyncSocket.h"
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
    }
    return self;
}

-(void)connectWithName:(NSString*)name listeningTo:(NSArray*)listensTo
{
    _udpHandler = [[MeshUDPHandler alloc] initWithAnyMesh:self];
    
    _name = name;
    _listensTo = listensTo;
    _tcpHandler = [[MeshTCPHandler alloc] initWithAnyMesh:self];
    
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
    [_tcpHandler beginListening];
}

#pragma mark Connections
-(void)_tcpConnectedTo:(GCDAsyncSocket *)socket
{
    SocketInfo *socketInfo = (SocketInfo*)socket.userData;
    if (socketInfo.dInfo.name) {
        [self.delegate anyMeshConnectedTo:[socketInfo.dInfo _clone]];
    }
}
-(void)_tcpDisconnectedFrom:(GCDAsyncSocket *)socket
{
    MeshDeviceInfo *socketInfo = (MeshDeviceInfo*)socket.userData;
    if (socketInfo.name) {
        [self.delegate anyMeshDisconnectedFrom:[NSString stringWithString:socketInfo.name]];
    }
}

#pragma mark Messaging
- (void)messageReceived:(MeshMessage *)message
{
    [self.delegate anyMeshReceivedMessage:message];
}

- (void)publishToTarget:(NSString *)target withData:(NSDictionary *)dataDict
{
     [_tcpHandler sendMessageTo:target withType:MeshMessageTypePublish dataObject:dataDict];
}
- (void)requestToTarget:(NSString *)target withData:(NSDictionary *)dataDict
{
     [_tcpHandler sendMessageTo:target withType:MeshMessageTypeRequest dataObject:dataDict];
}

#pragma mark Utility
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
                if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
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
