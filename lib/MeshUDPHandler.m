//
//  MeshUDPHandler.m
//  anyMesh
//
//  Created by David Paul on 4/28/14.
//  Copyright (c) 2014 dpTools. All rights reserved.
//

#import "MeshUDPHandler.h"
#import "MeshDeviceInfo.h"
#import "AnyMesh.h"
#import "MeshTCPHandler.h"

@implementation MeshUDPHandler
    
-(id)initWithNetworkID:(NSString*)_id onPort:(int)thePort
{
    if (self = [super init]) {
        am = [AnyMesh sharedInstance];
        
        udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        [udpSocket enableBroadcast:true error:nil];
        port = thePort;
        networkID = [_id dataUsingEncoding:NSUTF8StringEncoding];
        
        NSError *error = nil;
        if (![udpSocket bindToPort:port error:&error])
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
    return self;
}

-(void)startBroadcasting
{
    broadcastTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(broadcast) userInfo:nil repeats:TRUE];
}
-(void)stopBroadcasting
{
    [broadcastTimer invalidate];
    broadcastTimer = nil;
}
-(void)broadcast
{
    [udpSocket sendData:networkID toHost:@"255.255.255.255" port:port withTimeout:-1 tag:0];
}

#pragma mark UDP Server Delegate
-(void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext
{
    uint16_t aport = 0;
    NSString *ipAddress = nil;
    [GCDAsyncUdpSocket getHost:&ipAddress port:&aport fromAddress:address];

    if ([ipAddress rangeOfString:@":"].length > 0)return;
    if ([ipAddress isEqualToString:[am _getIPAddress]]) return;
    
    if ([am.networkID isEqualToString:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]]) {
        [[AnyMesh sharedInstance].tcpHandler connectTo:ipAddress];
    }}

@end
