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


@implementation MeshTCPClient

-(id)initWithPort:(int)port
{
    if (self = [super init]) {
        tcpPort = port;
        am = [AnyMesh sharedInstance];
        connectedServers = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)connectTo:(MeshDeviceInfo *)device
{
    if (!device.name) {
        return;
    }
    
    if (![connectedServers objectForKey:device.name]) {
        GCDAsyncSocket *socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:[AnyMesh sharedInstance].socketQueue];
        
        [connectedServers setObject:socket forKey:device.name];
        
        NSError *error = nil;
       if (![socket connectToHost:device.ipAddress onPort:TCP_PORT error:nil])
       {
           NSLog(@"Error! %@", error);
       }
        socket.userData = device;
    }
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    //MeshDeviceInfo *deviceInfo = (MeshDeviceInfo*)sock.userData;
    //[connectedServers setObject:sock forKey:deviceInfo.name];
    
    NSLog(@"client - server connected!");
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    NSLog(@"client - server disconnected?");
    
    //TODO remove from dictionary
}

-(void)sendMessageTo:(NSString *)target withType:(MeshMessageType)type dataObject:(NSDictionary *)dataDict
{
    GCDAsyncSocket *receiver = [connectedServers objectForKey:target];
    if (receiver)
    {
        NSArray *types = @[@"pub", @"req", @"res"];
        
        NSDictionary *message = @{KEY_SENDER:am.name,
                                  KEY_TARGET:target,
                                  KEY_TYPE:types[type],
                                  KEY_DATA:dataDict};
        NSData *msgData = [NSJSONSerialization dataWithJSONObject:message options:0 error:nil];
        [receiver writeData:msgData withTimeout:-1 tag:0];
    }
}


@end
