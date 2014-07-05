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
        
        _udpHandler = [[MeshUDPHandler alloc] initWithAnyMesh:self];
        _tcpHandler = [[MeshTCPHandler alloc] initWithAnyMesh:self];
    }
    return self;
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
