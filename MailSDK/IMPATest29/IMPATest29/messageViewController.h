//
//  messageViewController.h
//  IMPATest29
//
//  Created by Deepak on 04/08/17.
//  Copyright © 2017 bdAppManiac. All rights reserved.
//

#import <UIKit/UIKit.h>
#include <MailCore/MailCore.h>

@interface messageViewController : UIViewController    
{
    MCOIMAPSession * _session;
    MCOIMAPMessage * _message;
}
@property (nonatomic, strong) MCOIMAPSession * imapSession;
@property (nonatomic, strong) MCOIMAPMessage * message;
@property (nonatomic, strong) NSString       * folder;
@property (nonatomic, strong) NSMutableDictionary *dictMailInfo, *messagePreviews;
@property (nonatomic, strong) NSMutableArray *arrayOfMessages;


@end
