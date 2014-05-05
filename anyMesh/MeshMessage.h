//
//  MeshMessage.h
//  anyMesh
//
//  Created by David Paul on 4/29/14.
//  Copyright (c) 2014 dpTools. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MeshTCPServer;


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

@property (nonatomic)MeshTCPServer *tcpHandler;

-(id)initWithHandler:(MeshTCPServer*)handler messageObject:(NSDictionary*)msgObj;
-(void)respondWith:(NSDictionary*)responseObject;


@end
