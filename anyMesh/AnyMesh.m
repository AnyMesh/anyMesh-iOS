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

static AnyMesh *sharedInstance = nil;

@implementation AnyMesh


+ (AnyMesh *)sharedInstance {
    if (sharedInstance == nil) {
        sharedInstance = [[super allocWithZone:NULL] init];
    }
    
    return sharedInstance;
}

-(id)init
{
    if (self = [super init]) {
        self.socketQueue = dispatch_queue_create("socketQueue", NULL);
        self.networkID = @"c8m3!x";
    }
    return self;
}

-(void)connectWithName:(NSString*)name listeningTo:(NSArray*)listensTo
{
    _udpHandler = [[MeshUDPHandler alloc] initWithNetworkID:_networkID onPort:UDP_PORT];
    [_udpHandler startBroadcasting];
    
    _name = name;
    _tcpHandler = [[MeshTCPHandler alloc] initWithPort:TCP_PORT];
    
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


@end
