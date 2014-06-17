//
//  MeshDeviceInfo.m
//  anyMesh
//
//  Created by David Paul on 4/29/14.
//  Copyright (c) 2014 dpTools. All rights reserved.
//

#import "MeshDeviceInfo.h"

@implementation MeshDeviceInfo

-(MeshDeviceInfo*)_clone
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

-(BOOL)_validate
{
    if (![[self.name class] isSubclassOfClass:[NSString class]]) return FALSE;
    if (![[self.listensTo class] isSubclassOfClass:[NSArray class]]) return FALSE;
    
    for (NSObject *subscription in self.listensTo)
    {
        if (![[subscription class] isSubclassOfClass:[NSString class]]) return FALSE;
    }
    return TRUE;
}

@end
