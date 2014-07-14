//
//  UIView+AutoLayout.h
//  anyMesh
//
//  Created by David Paul on 6/6/14.
//  Copyright (c) 2014 dpTools. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIView (AutoLayout)

+(instancetype)autoLayoutView;
+(instancetype)autoLayoutViewInView:(UIView*)superView;

-(NSArray *)constrainHorizontalToSuperView;
-(NSArray *)constrainVerticalToSuperView;
-(NSArray *)constrainToSuperView;

@end