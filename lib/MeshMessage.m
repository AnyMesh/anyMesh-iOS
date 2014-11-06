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

-(id)initWithMessageObject:(NSDictionary*)msgObj
{
    if (self = [super init]) {
        
        _type = [msgObj[KEY_TYPE] integerValue];
        _data = msgObj[KEY_DATA];
        _sender = msgObj[KEY_SENDER];
        _target = msgObj[KEY_TARGET];        
    }
    
    return self;
}

@end
