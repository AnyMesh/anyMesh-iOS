//
//  MeshDeviceInfo.m
//  anyMesh
//
//  Created by David Paul on 4/29/14.
//  Copyright (c) 2014 dpTools. All rights reserved.
//

#import "MeshDeviceInfo.h"

@implementation MeshDeviceInfo


-(BOOL)_validate
{
    if(self.name){
        if(![[self.name class] isSubclassOfClass:[NSString class]]) return FALSE;
    }
    if(self.subscriptions){
        if (![[self.subscriptions class] isSubclassOfClass:[NSArray class]]) return FALSE;
        
        for (NSObject *subscription in self.subscriptions)
        {
            if (![[subscription class] isSubclassOfClass:[NSString class]]) return FALSE;
        }

    }
    return TRUE;
}

@end
