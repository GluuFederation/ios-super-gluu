//
//  SettingsTableCell.h
//  Super Gluu
//
//  Created by Nazar Yavornytskyy on 3/20/17.
//  Copyright © 2017 Gluu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsTableCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UILabel *subTitleLabel;

@property (nonatomic, retain) IBOutlet UILabel *versionLabel;
@property (nonatomic, retain) IBOutlet UIImageView *backArrowImage;

@end
