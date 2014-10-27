//
//  MeshTCPHandler.m
//  anyMesh
//
//  Created by David Paul on 4/29/14.
//  Copyright (c) 2014 dpTools. All rights reserved.
//


#import "MeshDeviceInfo.h"
#import "MeshMessage.h"
#import "NSData+lineReturn.h"

@implementation MeshTCPHandler


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




- (void)connectTo:(NSString*)ipAddress port:(int)port name:(NSString *)name
{
    if ([self socketForName:name]) return;
    
    GCDAsyncSocket *socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:am.socketQueue];
    [socket connectToHost:ipAddress onPort:port error:nil];
}

-(void)sendMessageTo:(NSString *)target withType:(MeshMessageTypeGeneral)type dataObject:(NSDictionary *)dataDict
{
    NSDictionary *message = @{KEY_SENDER:am.name,
                              KEY_TARGET:target,
                              KEY_TYPE:@(type),
                              KEY_DATA:dataDict};
    NSData *msgData = [NSJSONSerialization dataWithJSONObject:message options:0 error:nil];
    
    if (type == MessageTypePublish) {
        for (GCDAsyncSocket *connection in connections) {
            MeshDeviceInfo *devInfo = connection.userData;
            if ([devInfo.subscriptions containsObject:target]) [connection writeData:[msgData addLineReturn] withTimeout:-1 tag:0];
        }
    }
    else {
        for (GCDAsyncSocket *connection in connections) {
            MeshDeviceInfo *devInfo = connection.userData;
            if ([devInfo.name isEqualToString:target]) {
                [connection writeData:[msgData addLineReturn] withTimeout:-1 tag:0];
                return;
            }
        }
    }
}

-(void)sendInfoTo:(GCDAsyncSocket*)socket update:(BOOL)isUpdate
{
    NSString *name = am.name;
    if (isUpdate) name = @"";
    NSDictionary *message = @{KEY_TYPE:@"info",
                              KEY_SENDER:name,
                              KEY_SUBSCRIPTIONS:am.subscriptions};
    NSData *msgData = [NSJSONSerialization dataWithJSONObject:message options:0 error:nil];
    [socket writeData:[msgData addLineReturn] withTimeout:-1 tag:0];
    
}

-(void)sendInfoUpdates
{
    for (GCDAsyncSocket *connection in connections) {
        MeshDeviceInfo *dInfo = connection.userData;
        if (dInfo.name) {
            [self sendInfoTo:connection update:TRUE];
        }
    }
}


-(NSArray*)getConnections
{
    NSMutableArray *devices = [[NSMutableArray alloc] init];
    @synchronized(connections){
        for (GCDAsyncSocket* connection in connections)
        {
            MeshDeviceInfo *dInfo = connection.userData;
            if (dInfo.name.length > 0) [devices addObject:[dInfo _clone]];
        }
    }
    return devices;
}


@end
