//
//  SetupTableViewCell.h
//  Friend App
//
//  Created by Paul Galasso on 10/19/15.
//  Copyright © 2015 Mark Angeles. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SetupTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imageCell;

@property (weak, nonatomic) IBOutlet UILabel *labelTitle;

@property (weak, nonatomic) IBOutlet UILabel *labelContent;


@end
