//
//  MeshMessage.m
//  anyMesh
//
//  Created by David Paul on 4/29/14.
//  Copyright (c) 2014 dpTools. All rights reserved.
//

#import "MeshMessage.h"
#import "AnyMesh.h"

@implementation MeshMessage

-(id)initWithHandler:(MeshTCPHandler*)handler messageObject:(NSDictionary*)msgObj
{
    if (self = [super init]) {
        _tcpHandler = handler;
        
        if ([msgObj[KEY_TYPE] isEqualToString:@"pub"]) _type = MeshMessageTypePublish;
        else if ([msgObj[KEY_TYPE] isEqualToString:@"req"]) _type = MeshMessageTypeRequest;
        else if ([msgObj[KEY_TYPE] isEqualToString:@"res"]) _type = MeshMessageTypeResponse;
        else if ([msgObj[KEY_TYPE] isEqualToString:@"info"]) _type = MeshMessageTypeInfo;
        
        _data = msgObj[KEY_DATA];
        _sender = msgObj[KEY_SENDER];
        _target = msgObj[KEY_TARGET];
        _listensTo = msgObj[KEY_LISTENSTO];
        
    }
    
    return self;
}

-(void)respondWith:(NSDictionary*)responseObject
{
    
}

@end
