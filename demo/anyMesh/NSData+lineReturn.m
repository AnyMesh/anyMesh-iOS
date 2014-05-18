//
//  NSData+lineReturn.m
//  anyMesh
//
//  Created by David Paul on 5/12/14.
//  Copyright (c) 2014 dpTools. All rights reserved.
//

#import "NSData+lineReturn.h"

@implementation NSData (lineReturn)

-(NSData*)addLineReturn
{
    NSMutableData *data = [NSMutableData dataWithData:self];
    NSString *returnString = @"\r\n";
    [data appendData:[returnString dataUsingEncoding:NSUTF8StringEncoding]];
    return data;
}

@end
