//
//  SessionInfoView.m
//  anyMesh
//
//  Created by David Paul on 6/8/14.
//  Copyright (c) 2014 dpTools. All rights reserved.
//

#import "SessionInfoView.h"
#import "UIView+AutoLayout.h"
#import "MeshViewController.h"
#import "MeshDeviceInfo.h"

@implementation SessionInfoView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


- (IBAction)closeView:(id)sender {
    [self dismiss];
}

-(void)presentInView:(UIView*)superView {
    [self setAlpha:0];
    [superView addSubview:self];
    [self layoutSubviews];
    [self constrainToSuperView];
    
    [UIView animateWithDuration:0.5 animations:^{
        [self setAlpha:1];
    }];
}

-(void)dismiss
{
    [UIView animateWithDuration:0.5 animations:^{
        [self setAlpha:0];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark - TableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_connectedDevices count];
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell1"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell1"];
    }
    
    MeshDeviceInfo *dInfo = [_connectedDevices objectAtIndex:indexPath.row];
    cell.textLabel.text = dInfo.name;
    return cell;
}
@end
