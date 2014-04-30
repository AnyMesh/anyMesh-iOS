//
//  MeshMessage.h
//  anyMesh
//
//  Created by David Paul on 4/29/14.
//  Copyright (c) 2014 dpTools. All rights reserved.
//

#define KEY_TYPE @"type"
#define KEY_TARGET @"target"
#define KEY_SENDER @"sender"
#define KEY_DATA @"data"

#import <Foundation/Foundation.h>
@class MeshTCPHandler;


typedef enum {
    MeshMessageTypePublish,
    MeshMessageTypeRequest,
    MeshMessageTypeResponse
} MeshMessageType;

@interface MeshMessage : NSObject

@property (nonatomic)MeshMessageType type;
@property (nonatomic)NSDictionary *data;
@property (nonatomic)NSString *sender;
@property (nonatomic)NSString *target;

@property (nonatomic)MeshTCPHandler *tcpHandler;

-(id)initWithHandler:(MeshTCPHandler*)handler messageObject:(NSDictionary*)msgObj;
-(void)respondWith:(NSDictionary*)responseObject;


@end
