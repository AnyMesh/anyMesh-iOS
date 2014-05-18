//
//  MeshDeviceInfo.h
//  anyMesh
//
//  Created by David Paul on 4/29/14.
//  Copyright (c) 2014 dpTools. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MeshDeviceInfo : NSObject

@property (nonatomic)NSString *name;
@property (nonatomic)NSArray *listensTo;
@property (nonatomic)NSString *ipAddress;

- (MeshDeviceInfo*)clone;
@end
