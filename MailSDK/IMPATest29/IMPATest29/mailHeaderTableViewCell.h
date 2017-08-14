//
//  mailHeaderTableViewCell.h
//  IMPATest29
//
//  Created by Deepak on 09/08/17.
//  Copyright © 2017 bdAppManiac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface mailHeaderTableViewCell : UITableViewCell


@property (nonatomic, strong) IBOutlet UILabel *lblFrom;
@property (nonatomic, strong) IBOutlet UILabel *lblSubject;
@property (nonatomic, strong) IBOutlet UILabel *lblCC;
@property (nonatomic, strong) IBOutlet UILabel *lblTo;
@property (nonatomic, strong) IBOutlet UIButton *btnAction;

@end
