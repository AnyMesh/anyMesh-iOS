//
//  MeshTCPHandler.h
//  anyMesh
//
//  Created by David Paul on 4/29/14.
//  Copyright (c) 2014 dpTools. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AnyMesh.h"
@class GCDAsyncSocket;
@class MeshDeviceInfo;

@interface MeshTCPHandler : NSObject
{
    int tcpPort;
	AnyMesh *am;
	GCDAsyncSocket *listenSocket;
	NSMutableArray *connections;

    
}

-(id)initWithPort:(int)port;
-(void)connectTo:(NSString*)ipAddress;
-(void)sendMessageTo:(NSString *)target withType:(MeshMessageType)type dataObject:(NSDictionary *)dataDict;

@end
