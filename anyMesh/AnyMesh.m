//
//  AnyMesh.m
//  anyMesh
//
//  Created by David Paul on 4/29/14.
//  Copyright (c) 2014 dpTools. All rights reserved.
//

#import "AnyMesh.h"

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

-(void)activateWithName:(NSString*)name listeningTo:(NSArray*)listeningTo
{
    
}

- (void)messageReceived:(MeshMessage *)message
{
    
}

@end
