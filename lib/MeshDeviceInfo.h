//
//  MeshDeviceInfo.h
//  anyMesh
//
//  Created by David Paul on 4/29/14.
//  Copyright (c) 2014 dpTools. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MeshDeviceInfo : NSObject

@property (nonatomic, copy)NSString *name;
@property (nonatomic, copy)NSArray *subscriptions;

- (BOOL)_validate;
@end
