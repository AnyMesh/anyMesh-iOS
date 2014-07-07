//
//  anyMesh_Tests.m
//  anyMesh Tests
//
//  Created by David Paul on 7/3/14.
//  Copyright (c) 2014 dpTools. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AnyMesh.h"
#import "AGASyncTestHelper.h"

@interface anyMesh_Tests : XCTestCase <AnyMeshDelegate> {
    AnyMesh *any1;
    AnyMesh *any2;
    
    BOOL didConnect;
}

@end

@implementation anyMesh_Tests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample
{
    any1 = [[AnyMesh alloc] init];
    any1.delegate = self;
    [any1 connectWithName:@"One" subscriptions:@[@"global", @"odd"]];
    
    any2 = [[AnyMesh alloc] init];
    any2.delegate = self;
    [any2 connectWithName:@"Two" subscriptions:@[@"global", @"even"]];
    
    
    WAIT_WHILE(!didConnect, 6.0);
}

#pragma mark - Delegate
- (void)anyMesh:(AnyMesh*)anyMesh connectedTo:(MeshDeviceInfo *)device
{
    didConnect = TRUE;
}

-(void)anyMesh:(AnyMesh*)anyMesh disconnectedFrom:(NSString *)name
{
    
}

-(void)anyMesh:(AnyMesh*)anyMesh receivedMessage:(MeshMessage *)message
{
    
}

@end
