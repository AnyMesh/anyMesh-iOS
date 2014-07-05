//
//  SetupView.m
//  anyMesh
//
//  Created by David Paul on 6/6/14.
//  Copyright (c) 2014 dpTools. All rights reserved.
//

#import "SetupView.h"
#import "MeshViewController.h"
#import "MeshDeviceInfo.h"
#import "UIView+AutoLayout.h"

@implementation SetupView


- (id) initWithParentController:(MeshViewController*)parentVC
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        // Initialization code
        _parentController = parentVC;
        [self setTranslatesAutoresizingMaskIntoConstraints:FALSE];
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    if (isSetup ) return;
    isSetup = TRUE;
    _nameField.delegate = _parentController;
    
    listenFields = @[_listen1Field, _listen2Field, _listen3Field, _listen4Field];
    for (UITextField * field in listenFields) {
        field.delegate = _parentController;
    }
}

- (IBAction)buttonPressed:(id)sender {
    NSMutableArray *listens = [[NSMutableArray alloc] init];
    for (UITextField *field in listenFields) {
        if ([field.text length] > 0)
        {
            [listens addObject:field.text];
        }
    }
    MeshDeviceInfo *dInfo = [[MeshDeviceInfo alloc] init];
    dInfo.name = _nameField.text;
    dInfo.subscriptions = listens;
    
    [_parentController connectWithInfo:dInfo];
    [self dismiss];
}

-(void)presentInView:(UIView*)superView {
    [self setAlpha:0];
    [superView addSubview:self];
    [self constrainToSuperView];
    [self layoutSubviews];
    
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
@end
