//
//  CellInfo.h
//  anyMesh
//
//  Created by David Paul on 5/18/14.
//  Copyright (c) 2014 dpTools. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MeshDeviceInfo;

@interface CellInfo : NSObject

@property (nonatomic)MeshDeviceInfo *deviceInfo;
@property (nonatomic)NSString *message;

@end
