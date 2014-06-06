//
//  UIView+AutoLayout.m
//  anyMesh
//
//  Created by David Paul on 6/6/14.
//  Copyright (c) 2014 dpTools. All rights reserved.
//

#import "UIView+AutoLayout.h"

alOptions alOptionsMake(float top, float left, float bottom, float right){
    alOptions options;
    options.top = top;
    options.left = left;
    options.bottom = bottom;
    options.right = right;
    return options;
}


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

-(NSLayoutConstraint *)constrainLeadingToSuperView
{
    return [self constrainLeadingToSuperViewWithInset:0];
}

-(NSLayoutConstraint *)constrainTrailingToSuperView
{
    return [self constrainTrailingToSuperViewWithInset:0];
}

-(NSArray *)constrainEdgesToSuperViewWithInsets:(UIEdgeInsets)insets
{
    NSMutableArray *constraints = [[NSMutableArray alloc] init];
    if (insets.top != alNONE) [constraints addObject:[self constrainTopToSuperViewWithInset:insets.top]];
    if (insets.left != alNONE) [constraints addObject:[self constrainLeadingToSuperViewWithInset:insets.left]];
    if (insets.bottom != alNONE) [constraints addObject:[self constrainBottomToSuperViewWithInset:-insets.bottom]];
    if (insets.right != alNONE) [constraints addObject:[self constrainTrailingToSuperViewWithInset:-insets.right]];
    return constraints;
}

-(NSArray *)constrainToSuperViewWithOptions:(alOptions)options
{
    NSMutableArray *constraints = [[NSMutableArray alloc] init];
    if (options.top != alNONE) {
        if (options.top == alCENTER) {
            [constraints addObject:[self constrainCenterYToSuperView]];
        }
        else [constraints addObject:[self constrainTopToSuperViewWithInset:options.top]];
    }
    if (options.left != alNONE) {
        if (options.left == alCENTER) {
            [constraints addObject:[self constrainCenterXToSuperView]];
        }
        else [constraints addObject:[self constrainLeadingToSuperViewWithInset:options.left]];
    }
    if (options.bottom != alNONE) {
        if (options.bottom == alCENTER) {
            [constraints addObject:[self constrainCenterYToSuperView]];
        }
        else [constraints addObject:[self constrainBottomToSuperViewWithInset:-options.bottom]];
    }
    if (options.right != alNONE) {
        if (options.right == alCENTER) {
            [constraints addObject:[self constrainCenterXToSuperView]];
        }
        else [constraints addObject:[self constrainTrailingToSuperViewWithInset:-options.right]];
    }
    return constraints;
}

-(NSLayoutConstraint *)constrainWidthTo:(UIView *)view
{
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeWidth multiplier:1 constant:0];
    [self.superview addConstraint:constraint];
    return constraint;
}

-(NSLayoutConstraint *)constrainHeightTo:(UIView *)view
{
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeHeight multiplier:1 constant:0];
    [self.superview addConstraint:constraint];
    return constraint;
}

-(NSLayoutConstraint *)constrainTopToSuperView
{
    return [self constrainTopToSuperViewWithInset:0];
}

-(NSLayoutConstraint *)constrainBottomToSuperView
{
    return [self constrainBottomToSuperViewWithInset:0];
}

-(NSLayoutConstraint *)constrainTopToSuperViewWithInset:(float)inset
{
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeTop multiplier:1 constant:inset];
    [self.superview addConstraint:constraint];
    return constraint;
}

-(NSLayoutConstraint *)constrainBottomToSuperViewWithInset:(float)inset
{
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeBottom multiplier:1 constant:inset];
    [self.superview addConstraint:constraint];
    return constraint;
}
-(NSLayoutConstraint *)constrainLeadingToSuperViewWithInset:(float)inset
{
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeLeading multiplier:1 constant:inset];
    [self.superview addConstraint:constraint];
    return constraint;
}
-(NSLayoutConstraint *)constrainTrailingToSuperViewWithInset:(float)inset
{
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeTrailing multiplier:1 constant:inset];
    [self.superview addConstraint:constraint];
    return constraint;
}

-(NSLayoutConstraint *)constrainAttribute:(NSLayoutAttribute*)attribute toView:(UIView*)view
{
    return [self constrainAttribute:attribute toView:view withMultiplier:1];
}

-(NSLayoutConstraint *)constrainAttribute:(NSLayoutAttribute*)attribute toView:(UIView*)view withMultiplier:(float)multiplier
{
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:attribute relatedBy:NSLayoutRelationEqual toItem:view attribute:attribute multiplier:multiplier constant:0];
    [self.superview addConstraint:constraint];
    return  constraint;
}

-(NSLayoutConstraint *)constrainCenterXToSuperView
{
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    [self.superview addConstraint:constraint];
    return constraint;
}

-(NSLayoutConstraint *)constrainCenterYToSuperView
{
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
    [self.superview addConstraint:constraint];
    return constraint;
}

-(NSArray *)constrainCenterToSuperView
{
    NSLayoutConstraint *centerXcons = [self constrainCenterXToSuperView];
    NSLayoutConstraint *centerYcons = [self constrainCenterYToSuperView];
    return @[centerXcons, centerYcons];
}

-(NSLayoutConstraint *)constrainBottomToTopOf:(UIView *)view2
{
    return [self constrainBottomToTopOf:view2 withSpace:0];
}
-(NSLayoutConstraint *)constrainBottomToTopOf:(UIView *)view2 withSpace:(float)space
{
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:view2 attribute:NSLayoutAttributeTop multiplier:1 constant:(space * -1)];
    [self.superview addConstraint:constraint];
    return constraint;
}

-(NSLayoutConstraint *)constrainTrailingToLeadingOf:(UIView *)view2
{
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:view2 attribute:NSLayoutAttributeLeading multiplier:1 constant:0];
    [self.superview addConstraint:constraint];
    return constraint;
}


#pragma mark - Internal constraints:
-(NSLayoutConstraint *)addWidthConstraint:(float)width
{
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:width];
    [self addConstraint:constraint];
    return constraint;
}
-(NSLayoutConstraint *)addHeightConstraint:(float)height
{
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:height];
    [self addConstraint:constraint];
    return constraint;
}


-(NSArray *)addConstraintsWidth:(float)width andHeight:(float)height
{
    NSLayoutConstraint *xConstraint = [self addWidthConstraint:width];
    NSLayoutConstraint *yConstraint = [self addHeightConstraint:height];
    return @[xConstraint, yConstraint];
}

//Not proven to work yet:
-(NSArray *)equallySpaceSubViewsVertically:(NSArray *)subViews
{
    NSMutableArray *spacers = [[NSMutableArray alloc] init];
    NSMutableArray *constraints = [[NSMutableArray alloc] init];
    
    UIView *topSpacer = [[UIView alloc] initWithFrame:CGRectZero];
    [self addSubview:topSpacer];
    [topSpacer constrainTopToSuperView];
    [topSpacer addWidthConstraint:0];
    
    NSLayoutConstraint *minHeightConstraint = [NSLayoutConstraint constraintWithItem:topSpacer attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:1];
    [topSpacer addConstraint:minHeightConstraint];
    
    
    [spacers addObject:topSpacer];
    
    for (UIView *subView in subViews)
    {
        UIView *lastSpacer = [spacers objectAtIndex:([spacers count] - 1)];
        [lastSpacer constrainBottomToTopOf:subView];
        
        UIView *newSpacer = [[UIView alloc] initWithFrame:CGRectZero];
        [self addSubview:newSpacer];
        [newSpacer addWidthConstraint:0];
        [subView constrainBottomToTopOf:newSpacer];
        [spacers addObject:newSpacer];
        
        [constraints addObject:[newSpacer constrainHeightTo:topSpacer]];
    }
    
    UIView *bottomSpacer = [spacers objectAtIndex:([spacers count] - 1)];
    [bottomSpacer constrainBottomToSuperView];
    
    return [NSArray arrayWithArray:constraints];
}

#pragma mark Utility

+(void)disableAutoResizeForViews:(NSArray *)views
{
    for (UIView * view in views)
    {
        [view setTranslatesAutoresizingMaskIntoConstraints:FALSE];
    }
}
@end

@implementation UIImageView (Constraints)

+(instancetype)autoLayoutViewWithImage:(UIImage *)image
{
    UIImageView *view = [[self alloc] initWithImage:image];;
    [view setTranslatesAutoresizingMaskIntoConstraints:FALSE];
    return view;
}

#pragma mark Getting Constraints
- (NSLayoutConstraint*)getWidthConstraint
{
    NSArray *constraints = [self constraints];
    for (NSLayoutConstraint* constraint in constraints)
    {
        if (constraint.firstAttribute == NSLayoutAttributeWidth) {
            return constraint;
        }
    }
    return nil;
}


@end
