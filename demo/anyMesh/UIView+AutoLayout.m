//
//  UIView+AutoLayout.m
//  anyMesh
//
//  Created by David Paul on 6/6/14.
//  Copyright (c) 2014 dpTools. All rights reserved.
//

#import "UIView+AutoLayout.h"

@implementation UIView (AutoLayout)


+(instancetype)autoLayoutView
{
    UIView *view = [self new];
    [view setTranslatesAutoresizingMaskIntoConstraints:FALSE];
    return view;
}

+(instancetype)autoLayoutViewInView:(UIView*)superView
{
    UIView *view = [self autoLayoutView];
    [superView addSubview:view];
    return  view;
}

#pragma mark - Super view related constraints:
-(NSArray *)constrainHorizontalToSuperView
{
    return [self constrainHorizontalToSuperViewWithInset:0];
}
-(NSArray *)constrainVerticalToSuperView
{
    return [self constrainVerticalToSuperViewWithInset:0];
}

-(NSArray *)constrainToSuperView
{
    return [self constrainToSuperViewWithInset:0];
}

-(NSArray *)constrainToSuperViewWithInset:(float)inset {
    NSArray *hConstraints = [self constrainHorizontalToSuperViewWithInset:inset];
    NSArray *vConstraints = [self constrainVerticalToSuperViewWithInset:inset];
    return [hConstraints arrayByAddingObjectsFromArray:vConstraints];
}
-(NSArray *)constrainHorizontalToSuperViewWithInset:(float)inset {
    UIView *thisView = self;
    NSDictionary *dict = NSDictionaryOfVariableBindings(thisView);
    
    NSString *VFLString = [NSString stringWithFormat:@"|-%f-[thisView]-%f-|", inset, inset];
    
    NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:VFLString options:0 metrics:nil views:dict];
    [self.superview addConstraints:constraints];
    return constraints;
    
}
-(NSArray *)constrainVerticalToSuperViewWithInset:(float)inset {
    UIView *thisView = self;
    NSDictionary *dict = NSDictionaryOfVariableBindings(thisView);
    
    NSString *VFLString = [NSString stringWithFormat:@"V:|-%f-[thisView]-%f-|", inset, inset];
    
    NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:VFLString options:0 metrics:nil views:dict];
    [self.superview addConstraints:constraints];
    return constraints;
}

@end
