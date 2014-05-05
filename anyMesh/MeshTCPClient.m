//
//  MeshTCPClient.m
//  anyMesh
//
//  Created by David Paul on 4/30/14.
//  Copyright (c) 2014 dpTools. All rights reserved.
//

#import "MeshTCPClient.h"
#import "MeshDeviceInfo.h"
#import "GCDAsyncSocket.h"
#import "AnyMesh.h"


@implementation MeshTCPClient

-(id)initWithPort:(int)port
{
    if (self = [super init]) {
        tcpPort = port;
    }
    return self;
}

- (void)connectTo:(MeshDeviceInfo *)device
{
    if (![connectedServers objectForKey:device.name]) {
        GCDAsyncSocket *socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:[AnyMesh sharedInstance].socketQueue];
        [socket connectToHost:device.ipAddress onPort:tcpPort error:nil];
        socket.userData = device;
    }
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    MeshDeviceInfo *deviceInfo = (MeshDeviceInfo*)sock.userData;
    [connectedServers setObject:sock forKey:deviceInfo.name];
}


@end
