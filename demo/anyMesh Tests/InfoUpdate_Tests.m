//
//  InfoUpdate_Tests.m
//  anyMesh
//
//  Created by David Paul on 7/5/14.
//  Copyright (c) 2014 dpTools. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AnyMesh.h"
#import "AGASyncTestHelper.h"

@interface InfoUpdate_Tests : XCTestCase <AnyMeshDelegate> {
    AnyMesh *sender;
    AnyMesh *receiver;
    
    BOOL switchedInfo;
    int connectedMeshes;
    
    BOOL testDone;
}

@end

@implementation InfoUpdate_Tests

- (void)testInfoUpdate
{
    connectedMeshes = 0;
    
    sender = [[AnyMesh alloc] init];
    [sender connectWithName:@"sender" subscriptions:@[]];
    receiver = [[AnyMesh alloc] init];
    [receiver connectWithName:@"receiver" subscriptions:@[@"start"]];
    
    WAIT_WHILE(!testDone, 10.0);
}

#pragma mark - Delegate
- (void)anyMesh:(AnyMesh*)anyMesh connectedTo:(MeshDeviceInfo *)device
{
    connectedMeshes++;
    if (connectedMeshes > 2) XCTFail(@"Duplicate connections have been made!");

    
}

-(void)anyMesh:(AnyMesh*)anyMesh disconnectedFrom:(NSString *)name
{
    connectedMeshes--;
    if (connectedMeshes < 0) XCTFail(@"Error in reporting connections and disconnections!");
}

-(void)anyMesh:(AnyMesh*)anyMesh receivedMessage:(MeshMessage *)message
{
    
}

@end
