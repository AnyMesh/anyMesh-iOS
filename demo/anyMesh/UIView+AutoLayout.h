//
//  UIView+AutoLayout.h
//  anyMesh
//
//  Created by David Paul on 6/6/14.
//  Copyright (c) 2014 dpTools. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef struct
{
    float top;
    float left;
    float bottom;
    float right;
} alOptions;

static const float alNONE = 99999;
static const float alCENTER = 99998;
alOptions alOptionsMake(float top, float left, float bottom, float right);


@interface UIView (AutoLayout)

+(instancetype)autoLayoutView;
+(instancetype)autoLayoutViewInView:(UIView*)superView;

//MULTIPLE SIDES:
-(NSArray *)constrainHorizontalToSuperView;
-(NSArray *)constrainVerticalToSuperView;
-(NSArray *)constrainToSuperView;
-(NSArray *)constrainToSuperViewWithInset:(float)inset;
-(NSArray *)constrainHorizontalToSuperViewWithInset:(float)inset;
-(NSArray *)constrainVerticalToSuperViewWithInset:(float)inset;

-(NSArray *)constrainToSuperViewWithOptions:(alOptions)options;

// ONE SIDE:
-(NSLayoutConstraint *)constrainTopToSuperView;
-(NSLayoutConstraint *)constrainBottomToSuperView;
-(NSLayoutConstraint *)constrainLeadingToSuperView;
-(NSLayoutConstraint *)constrainTrailingToSuperView;

-(NSLayoutConstraint *)constrainAttribute:(NSLayoutAttribute*)attribute toView:(UIView*)view;
-(NSLayoutConstraint *)constrainAttribute:(NSLayoutAttribute*)attribute toView:(UIView*)view withMultiplier:(float)multiplier;

// RELATIVE DIMENSIONS:
-(NSLayoutConstraint *)constrainWidthTo:(UIView *)view;
-(NSLayoutConstraint *)constrainHeightTo:(UIView *)view;

// CENTERING:
-(NSLayoutConstraint *)constrainCenterXToSuperView;
-(NSLayoutConstraint *)constrainCenterYToSuperView;
-(NSArray *)constrainCenterToSuperView;

// INTERNAL DIMENSIONS:
-(NSLayoutConstraint *)addWidthConstraint:(float)width;
-(NSLayoutConstraint *)addHeightConstraint:(float)height;
-(NSArray *)addConstraintsWidth:(float)width andHeight:(float)height;

// SEQUENTIAL
-(NSLayoutConstraint *)constrainBottomToTopOf:(UIView *)view2;
-(NSLayoutConstraint *)constrainBottomToTopOf:(UIView *)view2 withSpace:(float)space;
-(NSLayoutConstraint *)constrainTrailingToLeadingOf:(UIView *)view2;

+(void)disableAutoResizeForViews:(NSArray *)views;
@end

@interface UIImageView (Constraints)
+(instancetype)autoLayoutViewWithImage:(UIImage *)image;
@end
