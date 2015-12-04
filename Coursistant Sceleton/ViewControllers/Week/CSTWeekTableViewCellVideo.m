//
//  CSTWeekTableViewCellVideo.m
//  Coursistant
//
//  Created by Администратор on 3.10.13.
//  Copyright (c) 2013 Altasapiens. All rights reserved.
//

#import "CSTWeekTableViewCellVideo.h"

@implementation CSTWeekTableViewCellVideo

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    self.accessoryView.frame = CGRectMake( 824, 0, 150, 50 );
}

@end
