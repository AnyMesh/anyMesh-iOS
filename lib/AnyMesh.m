//
//  AnyMesh.m
//  anyMesh
//
//  Created by David Paul on 4/29/14.
//  Copyright (c) 2014 dpTools. All rights reserved.
//

#import "AnyMesh.h"
#import "MeshDeviceInfo.h"
#import "NSData+lineReturn.h"
#import "MeshMessage.h"
#import <ifaddrs.h>
#import <arpa/inet.h>


@implementation AnyMesh

#pragma mark - Setup

-(id)init
{
    if (self = [super init]) {
        self.networkID = @"anymesh";
        self.discoveryPort = UDP_PORT;
        connections = [[NSMutableArray alloc] init];
        temporary = [[NSMutableArray alloc] init];
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
    [udpSocket receiveWithTimeout:-1 tag:0];
    NSLog(@"listening!");
}

-(void)startBroadcasting;
{
    NSLog(@"starting to broadcast");
    broadcastTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(broadcast) userInfo:nil repeats:TRUE];
}

-(void)broadcast
{
    if(!_name || tcpPort == 0)return;
    NSString *broadcastString = [NSString stringWithFormat:@"%@,%d,%@", _networkID, tcpPort, _name];
    NSData *broadcastData = [broadcastString dataUsingEncoding:NSUTF8StringEncoding];
    [udpSocket sendData:broadcastData toHost:@"255.255.255.255" port:_discoveryPort withTimeout:-1 tag:0];
    
    NSLog(@"broadcasting on %ld", (long)_discoveryPort);
}

-(void)connectWithName:(NSString*)name subscriptions:(NSArray*)listensTo
{
    _name = name;
    _subscriptions = listensTo;
    tcpPort = 0;
    workingPort = TCP_PORT;
    [self startTCPServer];
}

-(void)startTCPServer
{
    NSError *error;
    BOOL success = [listenSocket acceptOnPort:workingPort error:&error];
    if (!success) {
        workingPort++;
        [self startTCPServer];
    }
    else {
        tcpPort = workingPort;
        [self startBroadcasting];
    }

}

#pragma mark - Connections

- (void)connectTo:(NSString*)ipAddress port:(int)port name:(NSString *)name
{
    if ([self socketForName:name]) return;
    
    NSLog(@"trying to connect to %@", name);
    
    AsyncSocket *socket = [[AsyncSocket alloc] initWithDelegate:self];
    [socket connectToHost:ipAddress onPort:port error:nil];
    [temporary addObject:socket];
}

-(void)updateSubscriptions:(NSArray*)newSubscriptions
{
    _subscriptions = newSubscriptions;
    for (AsyncSocket *connection in connections) {
        if (connection.deviceInfo.name) {
            [self sendInfoTo:connection update:TRUE];
        }
    }
    
}

-(void)sendInfoTo:(AsyncSocket*)socket update:(BOOL)isUpdate
{
    NSString *target = socket.deviceInfo.name ? socket.deviceInfo.name : @"";
    NSDictionary *message = @{KEY_TYPE:@(MessageTypeSystem),
                              KEY_SENDER:_name,
                              KEY_TARGET:target,
                              KEY_DATA: @{
                                  KEY_TYPE:@(MessageTypeSystemSubscription),
                                  KEY_ISUPDATE:@(isUpdate),
                                  KEY_SUBSCRIPTIONS:_subscriptions
                              }};
    NSData *msgData = [NSJSONSerialization dataWithJSONObject:message options:0 error:nil];
    [socket writeData:[msgData addLineReturn] withTimeout:-1 tag:0];
    
}

-(NSArray*)connectedDevices
{
    NSMutableArray *devices = [[NSMutableArray alloc] init];
    for (AsyncSocket* connection in connections) {
        if (connection.deviceInfo.name.length > 0) [devices addObject:connection.deviceInfo];
    }
    return devices;
}

-(void)resume
{
    [self startBroadcasting];
    if(self.name)[self startTCPServer];
}


#pragma mark - Shutting down
-(void)suspend
{
    [listenSocket disconnect];
    NSMutableArray *socketsToDisconnect = [[NSMutableArray alloc] init];
    for(AsyncSocket *socket in connections)
    {
        [socketsToDisconnect addObject:socket];
    }
    for (AsyncSocket *socket in socketsToDisconnect) {
        [socket disconnect];
    }
    
    [broadcastTimer invalidate];
    broadcastTimer = nil;
    tcpPort = 0;
}


- (void)publishToTarget:(NSString *)target withData:(NSDictionary *)dataDict
{
     [self sendMessageTo:target withType:MessageTypePublish dataObject:dataDict];
}
- (void)requestToTarget:(NSString *)target withData:(NSDictionary *)dataDict
{
     [self sendMessageTo:target withType:MessageTypeRequest dataObject:dataDict];
}

-(void)sendMessageTo:(NSString *)target withType:(MeshMessageTypeGeneral)type dataObject:(NSDictionary *)dataDict
{
    NSDictionary *message = @{KEY_SENDER:_name,
                              KEY_TARGET:target,
                              KEY_TYPE:@(type),
                              KEY_DATA:dataDict};
    NSData *msgData = [NSJSONSerialization dataWithJSONObject:message options:0 error:nil];
    
    if (type == MessageTypePublish) {
        for (AsyncSocket *connection in connections) {
            MeshDeviceInfo *devInfo = connection.deviceInfo;
            if ([devInfo.subscriptions containsObject:target]) [connection writeData:[msgData addLineReturn] withTimeout:-1 tag:0];
        }
    }
    else {
        for (AsyncSocket *connection in connections) {
            if ([connection.deviceInfo.name isEqualToString:target]) {
                [connection writeData:[msgData addLineReturn] withTimeout:-1 tag:0];
                return;
            }
        }
    }
}


#pragma mark Socket Delegate Methods
- (void)onSocket:(AsyncSocket *)sock didAcceptNewSocket:(AsyncSocket *)newSocket
{
    NSLog(@"Accepting new socket");
    
    newSocket.deviceInfo = [[MeshDeviceInfo alloc] init];
    [connections addObject:newSocket];
    [self sendInfoTo:newSocket update:FALSE];
    [newSocket readDataToData:[AsyncSocket CRLFData] withTimeout:-1 tag:0];
}


- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSData *strData = [data subdataWithRange:NSMakeRange(0, [data length] - 2)];
    NSDictionary *msgObj = [NSJSONSerialization JSONObjectWithData:strData options:0 error:nil];
    MeshMessage *msg = [[MeshMessage alloc] initWithMessageObject:msgObj];
    
    if (msg.type == MessageTypeSystem) {
        NSLog(@"received system msg");
       NSDictionary *sysData = msg.data;
        if ([sysData[KEY_TYPE] integerValue] == MessageTypeSystemSubscription) {
            if ([sysData[KEY_ISUPDATE] boolValue]) {
                sock.deviceInfo.subscriptions = sysData[KEY_SUBSCRIPTIONS];
                if ([self.delegate respondsToSelector:@selector(anyMesh:updatedSubscriptions:forName:)]) {
                    [self.delegate anyMesh:self updatedSubscriptions:_subscriptions forName:_name];
                }
            }
            else {
                sock.deviceInfo.name = msg.sender;
                sock.deviceInfo.subscriptions = sysData[KEY_SUBSCRIPTIONS];
                if(sock.deviceInfo.name.length > 0) [self.delegate anyMesh:self connectedTo:sock.deviceInfo];
            }
        }
    }
    else [self.delegate anyMesh:self receivedMessage:msg];
    [sock readDataToData:[AsyncSocket CRLFData] withTimeout:-1 tag:0];
}


- (void)onSocketDidDisconnect:(AsyncSocket *)sock
{
    if (sock != listenSocket)
    {
        if([connections containsObject:sock]) {
            [connections removeObject:sock];
            [temporary removeObject:sock];
            [self.delegate anyMesh:self disconnectedFrom:sock.deviceInfo.name];
        }
    }
}


- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    sock.deviceInfo = [[MeshDeviceInfo alloc] init];
    [connections addObject:sock];
    [temporary removeObject:sock];
    [self sendInfoTo:sock update:FALSE];
    [sock readDataToData:[AsyncSocket CRLFData] withTimeout:-1 tag:0];
}

#pragma mark UDP Server Delegate
- (BOOL)onUdpSocket:(AsyncUdpSocket *)sock didReceiveData:(NSData *)data withTag:(long)tag fromHost:(NSString *)host port:(UInt16)port
{    
    if (!_name || tcpPort == 0) return FALSE;
    if ([host rangeOfString:@":"].length > 0)return FALSE;
    
    NSArray *dataArray = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] componentsSeparatedByString:@","];
    if ([_networkID isEqualToString:dataArray[0]]) {
        int senderPort = [dataArray[1] intValue];
        NSString *senderName = dataArray[2];
        
        NSString *ownIp = [self _getIPAddress];
        if ((![host isEqualToString:ownIp] || tcpPort != senderPort) &&
        ![ownIp isEqualToString:@"error"]) {
            if ([_name compare:senderName] == NSOrderedDescending ) {
                [self connectTo:host port:senderPort name:senderName];
            }
        }
        
    }
    return FALSE;
}

#pragma mark Utility
- (AsyncSocket*)socketForName:(NSString*)name
{
    for (AsyncSocket *connection in connections)
    {
        if ([connection.deviceInfo.name isEqualToString:name]) {
            return connection;
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

@end
