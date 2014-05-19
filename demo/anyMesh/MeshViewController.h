//
//  MeshViewController.h
//  anyMesh
//
//  Created by David Paul on 4/28/14.
//  Copyright (c) 2014 dpTools. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AnyMesh.h"
#import "InputViewController.h"

@interface MeshViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, AnyMeshDelegate, UITextFieldDelegate, InputViewControllerDelegate> {
    AnyMesh *am;
    NSMutableArray *connectedDevices;
    InputViewController *inputVC;
}

@property (weak, nonatomic) IBOutlet UITextField *msgField;
@property (weak, nonatomic) IBOutlet UITextField *targetField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *listensToLabel;


-(IBAction)publishButtonPressed:(id)sender;
-(IBAction)requestButtonPressed:(id)sender;


@end
