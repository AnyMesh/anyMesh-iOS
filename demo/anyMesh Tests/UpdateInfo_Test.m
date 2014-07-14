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
#import "MeshMessage.h"
#import "MeshDeviceInfo.h"

@interface UpdateInfo_Test : XCTestCase <AnyMeshDelegate> {
    AnyMesh *sender;
    AnyMesh *receiver;
    
    BOOL switchedInfo;
    int connectedMeshes;
    
    BOOL testDone;
}

@end

@implementation UpdateInfo_Test

- (void)testInfoUpdate
{
    connectedMeshes = 0;
    
    sender = [[AnyMesh alloc] init];
    sender.delegate = self;
    sender.networkID = @"update";
    [sender connectWithName:@"sender" subscriptions:@[@"global"]];
    
    receiver = [[AnyMesh alloc] init];
    receiver.delegate = self;
    receiver.networkID = @"update";
    [receiver connectWithName:@"receiver" subscriptions:@[@"start"]];
    
    WAIT_WHILE(!testDone, 20.0);
}

#pragma mark - Delegate
- (void)anyMesh:(AnyMesh*)anyMesh connectedTo:(MeshDeviceInfo *)device
{
     NSLog(@"%@ reports connection to %@", anyMesh.name, device.name);
    
    connectedMeshes++;
    NSLog(@"%d connections", connectedMeshes);
    
    if (connectedMeshes > 2) XCTFail(@"Duplicate connections have been made!");

    else if (connectedMeshes == 2) [sender publishToTarget:@"start" withData:@{@"index":@(1)}];
    
}

-(void)anyMesh:(AnyMesh*)anyMesh disconnectedFrom:(NSString *)name
{
    NSLog(@"%@ reports disconnection from %@", anyMesh.name, name);
    
    connectedMeshes--;
    if (connectedMeshes < 0) XCTFail(@"Error in reporting connections and disconnections!");
}

-(void)anyMesh:(AnyMesh*)anyMesh receivedMessage:(MeshMessage *)message
{
    NSLog(@"%@ mesh received message from %@", anyMesh.name, message.sender);
    
    if (anyMesh == sender) XCTFail(@"only receiver instance should receive messages in this test.");
    else {
        if ([message.data[@"index"] isEqualToNumber:@(1)]) [receiver updateSubscriptions:@[@"end"]];
        else if ([message.data[@"index"] isEqualToNumber:@(2)]) testDone = TRUE;
        else XCTFail(@"unrecognized message");
    }
}

-(void)anyMesh:(AnyMesh *)anyMesh updatedSubscriptions:(NSArray *)subscriptions forName:(NSString *)name
{
    NSLog(@"%@ mesh updated subscriptions for %@", anyMesh.name, name);
    
    if (anyMesh == receiver) XCTFail(@"only receiver updates subscriptions in this test.");
    else {
        XCTAssert(subscriptions.count == 1, @"updated subscription array is only one keyword");
        XCTAssert(([subscriptions[0] isEqualToString:@"end"]), @"new keyword is 'end'");
        [sender publishToTarget:@"end" withData:@{@"index":@(2)}];
    }
}

@end
