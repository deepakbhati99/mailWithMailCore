//
//  maiFooterTableViewCell.h
//  IMPATest29
//
//  Created by Deepak on 09/08/17.
//  Copyright © 2017 bdAppManiac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface maiFooterTableViewCell : UITableViewCell

@property (nonatomic, strong)IBOutlet UITextView *txtViewMailBody;
@property (nonatomic, strong)IBOutlet UIButton *btnAttachment;
@property (nonatomic, strong)IBOutlet UIProgressView *progressBar;
@property (nonatomic, strong)IBOutlet UILabel        *progressLable;

@end
