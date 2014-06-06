//
//  SetupView.h
//  anyMesh
//
//  Created by David Paul on 6/6/14.
//  Copyright (c) 2014 dpTools. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MeshViewController;

@interface SetupView : UIView {
    NSArray *listenFields;
    BOOL isSetup;
}
- (IBAction)buttonPressed:(id)sender;

@property (weak, nonatomic) MeshViewController *parentController;

@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *listen1Field;
@property (weak, nonatomic) IBOutlet UITextField *listen2Field;
@property (weak, nonatomic) IBOutlet UITextField *listen3Field;
@property (weak, nonatomic) IBOutlet UITextField *listen4Field;

- (id) initWithParentController:(MeshViewController*)parentVC;
@end
