//
//  AnyMesh.m
//  anyMesh
//
//  Created by David Paul on 4/29/14.
//  Copyright (c) 2014 dpTools. All rights reserved.
//

#import "AnyMesh.h"
#import "MeshDeviceInfo.h"
#import <ifaddrs.h>
#import <arpa/inet.h>


@implementation AnyMesh

#pragma mark - Setup

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
    if (![udpSocket bindToPort:_discoveryPort error:&error])
    {
        NSLog(@"Error starting server (bind): %@", error);
        return;
    }
    if (![udpSocket beginReceiving:&error])
    {
        [udpSocket close];
        
        NSLog(@"Error starting server (recv): %@", error);
        return;
    }
}

-(void)startBroadcastingWithPort:(int)port;
{
    serverPort = port;
    broadcastTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(broadcast) userInfo:nil repeats:TRUE];
}

-(void)broadcast
{
    if(!am.name)return;
    NSString *broadcastString = [NSString stringWithFormat:@"%@,%d,%@", am.networkID, serverPort, am.name];
    NSData *broadcastData = [broadcastString dataUsingEncoding:NSUTF8StringEncoding];
    [udpSocket sendData:broadcastData toHost:@"255.255.255.255" port:am.discoveryPort withTimeout:-1 tag:0];
}

-(void)connectWithName:(NSString*)name subscriptions:(NSArray*)listensTo
{
    _name = name;
    _subscriptions = listensTo;
    
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

#pragma mark - Connections

- (void)connectTo:(NSString*)ipAddress port:(int)port name:(NSString *)name
{
    if ([self socketForName:name]) return;
    
    GCDAsyncSocket *socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:am.socketQueue];
    [socket connectToHost:ipAddress onPort:port error:nil];
}

-(void)updateSubscriptions:(NSArray*)newSubscriptions
{
    _subscriptions = newSubscriptions;
    for (GCDAsyncSocket *connection in connections) {
        MeshDeviceInfo *dInfo = connection.userData;
        if (dInfo.name) {
            [self sendInfoTo:connection update:TRUE];
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

-(NSArray*)connectedDevices
{
    return [_tcpHandler getConnections];
}



-(void)resume
{
    [self startBroadcasting];
    if(self.name)[self beginListening];
}

#pragma mark Connections
-(void)_tcpConnectedTo:(GCDAsyncSocket *)socket
{
    SocketInfo *socketInfo = (SocketInfo*)socket.userData;
    if (socketInfo.dInfo.name) {
        [self.delegate anyMesh:self connectedTo:[socketInfo.dInfo _clone]];
    }
}


#pragma mark - Shutting down
-(void)suspend
{
    [listenSocket disconnect];
    for(GCDAsyncSocket *socket in connections)
    {
        [socket disconnect];
    }
    
    [broadcastTimer invalidate];
    broadcastTimer = nil;
    serverPort = 0;
}


#pragma mark Messaging
- (void)messageReceived:(MeshMessage *)message
{
    [self.delegate anyMesh:self receivedMessage:message];
}

- (void)publishToTarget:(NSString *)target withData:(NSDictionary *)dataDict
{
     [self sendMessageTo:target withType:MeshMessageTypePublish dataObject:dataDict];
}
- (void)requestToTarget:(NSString *)target withData:(NSDictionary *)dataDict
{
     [self sendMessageTo:target withType:MeshMessageTypeRequest dataObject:dataDict];
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
