//
//  DisconnectTest.m
//  anyMesh
//
//  Created by David Paul on 7/6/14.
//  Copyright (c) 2014 dpTools. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AnyMesh.h"
#import "AGASyncTestHelper.h"
#import "MeshDeviceInfo.h"

@interface DisconnectTest : XCTestCase <AnyMeshDelegate> {
    AnyMesh *any1;
    AnyMesh *any2;
    
    int connections;
    
    BOOL testDone;
    BOOL madeConnections;
}

@end

@implementation DisconnectTest

- (void)testDisconnects
{
    connections = 0;
    
    any1 = [[AnyMesh alloc] init];
    any1.delegate = self;
    any1.networkID = @"disconnect";
    [any1 connectWithName:@"One" subscriptions:@[@"global"]];
    
    any2 = [[AnyMesh alloc] init];
    any2.delegate = self;
    any2.networkID = @"disconnect";
    [any2 connectWithName:@"Two" subscriptions:@[@"global"]];
    
    WAIT_WHILE(!testDone, 20.0);
}

#pragma mark - Delegate
- (void)anyMesh:(AnyMesh*)anyMesh connectedTo:(MeshDeviceInfo *)device
{
    NSLog(@"%@ reports connection to %@", anyMesh.name, device.name);
    
    connections++;
    if (connections > 2) XCTFail(@"Duplicate connections have been made!");
    if (connections == 2) {
        madeConnections = TRUE;
        [any1 suspend];
    }
}

-(void)anyMesh:(AnyMesh*)anyMesh disconnectedFrom:(NSString *)name
{
    NSLog(@"%@ reports disconnection from %@", anyMesh.name, name);
    
    connections--;
    if (connections < 0) XCTFail(@"Error reporting connections!");
    
    if (madeConnections) {
        if (connections == 0) testDone = TRUE;
    }
}

-(void)anyMesh:(AnyMesh*)anyMesh receivedMessage:(MeshMessage *)message
{
    
}
@end
