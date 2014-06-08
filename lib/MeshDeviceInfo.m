//
//  MeshDeviceInfo.m
//  anyMesh
//
//  Created by David Paul on 4/29/14.
//  Copyright (c) 2014 dpTools. All rights reserved.
//

#import "MeshDeviceInfo.h"

@implementation MeshDeviceInfo

-(MeshDeviceInfo*)clone
{
    MeshDeviceInfo *clone = [[MeshDeviceInfo alloc] init];
    if(self.name)clone.name = [NSString stringWithString:self.name];
    NSMutableArray *clonedArray = [[NSMutableArray alloc] init];
    if (self.listensTo) {
        for (NSString *listenString in self.listensTo) {
            [clonedArray addObject:[NSString stringWithString:listenString]];
        }
    }
    clone.listensTo = clonedArray;
    clone.ipAddress = self.ipAddress;
    return clone;
}


@end
