//
//  MeshMessage.h
//  anyMesh
//
//  Created by David Paul on 4/29/14.
//  Copyright (c) 2014 dpTools. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AnyMesh.h"
@class MeshTCPHandler;


@interface MeshMessage : NSObject

@property (nonatomic)MeshMessageType type;
@property (nonatomic)NSDictionary *data;
@property (nonatomic)NSString *sender;
@property (nonatomic)NSString *target;
@property (nonatomic)NSArray *listensTo;

@property (nonatomic)MeshTCPHandler *tcpHandler;

-(id)initWithHandler:(MeshTCPHandler*)handler messageObject:(NSDictionary*)msgObj;
-(void)respondWith:(NSDictionary*)responseObject;


@end
