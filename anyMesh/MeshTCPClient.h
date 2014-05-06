//
//  MeshTCPClient.h
//  anyMesh
//
//  Created by David Paul on 4/30/14.
//  Copyright (c) 2014 dpTools. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"
@class MeshDeviceInfo;


@interface MeshTCPClient : NSObject <GCDAsyncSocketDelegate>{
    NSMutableDictionary *connectedServers;
    int tcpPort;
}

@property (nonatomic) NSString *name;

-(id)initWithPort:(int)port;
-(void)connectTo:(MeshDeviceInfo*)device;

@end
