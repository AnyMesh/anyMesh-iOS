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
    
-(id)initWithAnyMesh:(AnyMesh *)anyMesh
{
    if (self = [super init]) {
        am = anyMesh;
        
        udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
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
    return self;
}

-(void)startBroadcastingWithPort:(int)port;
{
    serverPort = port;
    broadcastTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(broadcast) userInfo:nil repeats:TRUE];
}
-(void)stopBroadcasting
{
    [broadcastTimer invalidate];
    broadcastTimer = nil;
}
-(void)broadcast
{
    if(!am.name)return;
    NSString *broadcastString = [NSString stringWithFormat:@"%@,%d,%@", am.networkID, serverPort, am.name];
    NSData *broadcastData = [broadcastString dataUsingEncoding:NSUTF8StringEncoding];
    [udpSocket sendData:broadcastData toHost:@"255.255.255.255" port:am.discoveryPort withTimeout:-1 tag:0];
}

#pragma mark UDP Server Delegate
-(void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext
{
    if (!am.name || serverPort == 0) return;
    
    
    uint16_t aport_DONOTUSE = 0;
    NSString *ipAddress = nil;
    [GCDAsyncUdpSocket getHost:&ipAddress port:&aport_DONOTUSE fromAddress:address];
    if ([ipAddress rangeOfString:@":"].length > 0)return;
    
    NSArray *dataArray = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] componentsSeparatedByString:@","];
    if ([am.networkID isEqualToString:dataArray[0]]) {
        int senderPort = [dataArray[1] intValue];
        NSString *senderName = dataArray[2];
        
        NSString *ownIp = [am _getIPAddress];
        if ((![ipAddress isEqualToString:ownIp] || serverPort != senderPort) && ![ownIp isEqualToString:@"error"]) {
            [am.tcpHandler connectTo:ipAddress port:senderPort name:senderName];
        }
        
    }
    
}
/*
    if ([ipAddress rangeOfString:@":"].length > 0)return;
    if ([ipAddress isEqualToString:[am _getIPAddress]]) return;
    
    if ([am.networkID isEqualToString:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]]) {
        [am.tcpHandler connectTo:ipAddress];
    }}
*/
@end
