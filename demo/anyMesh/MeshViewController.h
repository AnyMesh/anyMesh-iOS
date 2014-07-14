//
//  MeshViewController.h
//  anyMesh
//
//  Created by David Paul on 4/28/14.
//  Copyright (c) 2014 dpTools. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AnyMesh.h"

@interface MeshViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, AnyMeshDelegate, UITextFieldDelegate> {
    AnyMesh *am;
    NSMutableArray *messages;
    UITapGestureRecognizer *recognizer;
}

@property AnyMesh *am;
@property (weak, nonatomic) IBOutlet UITextField *msgField;
@property (weak, nonatomic) IBOutlet UITextField *targetField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

-(void)connectWithInfo:(MeshDeviceInfo *)info;
-(IBAction)publishButtonPressed:(id)sender;
-(IBAction)requestButtonPressed:(id)sender;
-(IBAction)infoButtonPressed:(id)sender;

@end
