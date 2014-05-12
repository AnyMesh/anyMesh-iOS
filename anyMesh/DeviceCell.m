//
//  DeviceCell.m
//  anyMesh
//
//  Created by David Paul on 5/10/14.
//  Copyright (c) 2014 dpTools. All rights reserved.
//

#import "DeviceCell.h"

@implementation DeviceCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
