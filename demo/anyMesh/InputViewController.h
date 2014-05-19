//
//  InputViewController.h
//  anyMesh
//
//  Created by David Paul on 5/18/14.
//  Copyright (c) 2014 dpTools. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MeshDeviceInfo;

@protocol InputViewControllerDelegate <NSObject>

-(void)inputViewSubmittedWithInfo:(MeshDeviceInfo*)info;

@end


@interface InputViewController : UIViewController <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *listen1Field;
@property (weak, nonatomic) IBOutlet UITextField *listen2Field;
@property (weak, nonatomic) IBOutlet UITextField *listen3Field;
@property (weak, nonatomic) IBOutlet UITextField *listen4Field;

@property (nonatomic) NSArray *listenFields;

@property (weak, nonatomic) NSObject<InputViewControllerDelegate> *delegate;
- (IBAction)startButtonPressed:(id)sender;

@end
