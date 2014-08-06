//
//  SessionInfoView.h
//  anyMesh
//
//  Created by David Paul on 6/8/14.
//  Copyright (c) 2014 dpTools. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MeshViewController;

@interface SessionInfoView : UIView <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic) NSString *myName;
@property (nonatomic) NSArray *connectedDevices;

@property (weak, nonatomic) MeshViewController *parentController;
- (IBAction)closeView:(id)sender;
- (void)presentInView:(UIView*)superView;
@end
