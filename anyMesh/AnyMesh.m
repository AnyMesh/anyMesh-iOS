//
//  AnyMesh.m
//  anyMesh
//
//  Created by David Paul on 4/29/14.
//  Copyright (c) 2014 dpTools. All rights reserved.
//

#import "AnyMesh.h"
#import "MeshUDPHandler.h"
#import "MeshTCPServer.h"
#import "MeshTCPClient.h"

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
    }
    return self;
}

-(void)connectWithName:(NSString*)name listeningTo:(NSArray*)listensTo
{
    NSDictionary *msgDict = @{KEY_NAME:name, KEY_LISTENSTO:listensTo};
    NSData *msgData = [NSJSONSerialization dataWithJSONObject:msgDict options:0 error:nil];
    NSString *msg = [[NSString alloc] initWithData:msgData encoding:NSUTF8StringEncoding];
    _udpHandler = [[MeshUDPHandler alloc] initWithBroadcastMessage:msg onPort:UDP_PORT];
    
    _tcpClient = [[MeshTCPClient alloc] initWithPort:TCP_PORT];
    _tcpClient.name = name;
    
    _tcpServer = [[MeshTCPServer alloc] initWithPort:TCP_PORT];
    
}

- (void)messageReceived:(MeshMessage *)message
{
    
}

@end
