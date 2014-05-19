//
//  InputViewController.m
//  anyMesh
//
//  Created by David Paul on 5/18/14.
//  Copyright (c) 2014 dpTools. All rights reserved.
//

#import "InputViewController.h"
#import "MeshDeviceInfo.h"

@interface InputViewController ()

@end

@implementation InputViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _listenFields = @[_listen1Field, _listen2Field, _listen3Field, _listen4Field];
    
    _nameField.delegate = self;
    for (UITextField* textField in _listenFields) textField.delegate = self;
    
    
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)]];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)startButtonPressed:(id)sender {
    if (_nameField.text.length > 0) {
        MeshDeviceInfo *info = [[MeshDeviceInfo alloc] init];
        info.name = _nameField.text;
        NSMutableArray *listensToItems = [[NSMutableArray alloc] init];
        
        for (UITextField *listenField in _listenFields) {
            if (listenField.text.length > 0) {
                [listensToItems addObject:listenField.text];
            }
        }
        info.listensTo = listensToItems;
        
        [self.delegate inputViewSubmittedWithInfo:info];
    }
}

-(void)dismissKeyboard:(id)sender
{
    for (UITextField *listenField in _listenFields) {
        [listenField resignFirstResponder];
    }
    [_nameField resignFirstResponder];

}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return TRUE;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationPortrait;
}

-(BOOL)shouldAutorotate
{
    return FALSE;
}


@end
