//
//  messageViewController.m
//  IMPATest29
//
//  Created by Deepak on 04/08/17.
//  Copyright © 2017 bdAppManiac. All rights reserved.
//

#import "messageViewController.h"
#import "mailHeaderTableViewCell.h"
#import "maiFooterTableViewCell.h"


@interface messageViewController ()
{
    IBOutlet UILabel *lblFrom;
    IBOutlet UITextView *txtViewMailBody;
    IBOutlet UILabel *lblSubject;
    IBOutlet UILabel *lblCC;
    IBOutlet UILabel *lblTo;
    IBOutlet UIButton *btnAttachment;
    
    
    IBOutlet UIProgressView *progressBar;
    IBOutlet UILabel        *progressLable;
    NSString *attachmentPath;
    int      selectecSection;
    
    IBOutlet UITableView *tableMails;
    
}
@end

@implementation messageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    selectecSection = -1;
    
   // [self setupView];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - general Function 


-(NSString *)getStringForArray:(NSArray *)array
{
    NSString *toString = @"";
    for (int i = 0; i < array.count; i++)
    {
        toString  = [toString stringByAppendingString:[NSString stringWithFormat:@"%@ %@ ",[[array objectAtIndex:i] valueForKey:@"displayName"],[[array objectAtIndex:i] valueForKey:@"mailbox"]]];
    }

    return toString;
}


-(IBAction)headerPressed:(id)sender
{
    [tableMails beginUpdates];
    
    
    int section = ((UIButton *)sender).tag;
    
    
    if (selectecSection == section)  // Means already Open Close it
    {
        selectecSection = -200;
        
        [tableMails reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationFade];
        
    }
    else // means user click on other section then remove cells and open user selected section
    {
        
        if (selectecSection > -1)
        {
            [tableMails reloadSections:[NSIndexSet indexSetWithIndex:selectecSection] withRowAnimation:UITableViewRowAnimationFade];
        }
        
        NSString *sectionString = [NSString stringWithFormat:@"%ld",(long)section];
        selectecSection = section;
        
        NSArray *indexPaths = [self indexPathsForSection:section withNumberOfRows:1];
        [tableMails insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
        [tableMails reloadSections:[NSIndexSet indexSetWithIndex:selectecSection] withRowAnimation:UITableViewRowAnimationFade];
        
        
    }
    
    [tableMails endUpdates];
    
    
    
}



-(NSArray*) indexPathsForSection:(NSInteger)section withNumberOfRows:(NSInteger)numberOfRows
{
    NSMutableArray* indexPaths = [NSMutableArray new];
    for (int i = 0; i < numberOfRows; i++) {
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:i inSection:section];
        [indexPaths addObject:indexPath];
    }
    return indexPaths;
}



-(void)setupView
{
    
    btnAttachment.hidden = true;
    progressLable.hidden = true;
    progressBar  .hidden = true;
    
    lblFrom.text = [NSString stringWithFormat:@"%@ %@", self.message.header.from.displayName,  self.message.header.from.mailbox];
    
    NSString *toString = @"";
    for (int i = 0; i < self.message.header.to.count; i++)
    {
        NSArray *arr = self.message.header.to;
        NSLog(@"%@", [[arr objectAtIndex:i] valueForKey:@"displayName"]);
        
        NSLog(@"%@",[arr description]);
        
        toString  = [toString stringByAppendingString:[NSString stringWithFormat:@"%@ %@ ",[[arr objectAtIndex:i] valueForKey:@"displayName"],[[arr objectAtIndex:i] valueForKey:@"mailbox"]]];
    }
    
    lblTo.text  = [NSString stringWithFormat:@"%@",toString];
    
    
    NSString *CCString = @"";
    for (int i = 0; i < self.message.header.cc.count; i++) {
        NSArray *arr = self.message.header.cc;

        CCString  = [CCString stringByAppendingString:[NSString stringWithFormat:@"%@ %@ ",[[arr objectAtIndex:i] valueForKey:@"displayName"],[[arr objectAtIndex:i] valueForKey:@"mailbox"]]];
    }
    if (CCString.length)
        lblTo.text  = [NSString stringWithFormat:@"%@",CCString];

    
    NSString *bccString = @"";
    for (int i = 0; i < self.message.header.bcc.count; i++) {
        
        NSArray *arr = self.message.header.bcc;

        bccString  = [bccString stringByAppendingString:[NSString stringWithFormat:@"%@ %@",[[arr objectAtIndex:i] valueForKey:@"displayName"],[[arr objectAtIndex:i] valueForKey:@"mailbox"]]];
    }
    if (bccString.length)
        lblTo.text  = [NSString stringWithFormat:@"%@",bccString];
    
    
    NSString *cachedPreview = self.messagePreviews[[NSString stringWithFormat:@"%d", self.message.uid]];
    
    if (cachedPreview)
    {
        
        txtViewMailBody.text = cachedPreview;
    }
    else
    {
        MCOIMAPMessageRenderingOperation * messageRenderingOperation;
        messageRenderingOperation = [self.imapSession plainTextBodyRenderingOperationWithMessage:self.message
                                                                                               folder:@"INBOX"];
        
        [messageRenderingOperation start:^(NSString * plainTextBodyString, NSError * error) {
            txtViewMailBody.text = plainTextBodyString;
        }];
    }

//    [self downlaodattachmentFormMessage:self.message];

}


#pragma mark - downlaod Attachment function

-(void)downlaodattachmentFormMessage:(MCOIMAPMessage *)message andForCell:(maiFooterTableViewCell *)cell
{
    cell.btnAttachment.hidden = true;
    cell.progressLable.hidden = true;
    cell.progressBar  .hidden = true;
    cell.btnAttachment.enabled = true;

    if ([message.attachments count] > 0) {
        
        cell.btnAttachment.hidden = false;
        cell.progressLable.hidden = FALSE;
        cell.progressBar  .hidden = false;
        cell.btnAttachment.enabled = FALSE;
        
        
        
        for (int k = 0; k < [message.attachments count]; k++) {
            MCOIMAPPart *part = [message.attachments objectAtIndex:k];
            // MCOIMAPFetchContentOperation *mcop = [self.imapSession fetchMessageAttachmentByUIDOperationWithFolder:@"INBOX" uid:message.uid partID:part.partID encoding:part.encoding];
            
            
            MCOIMAPFetchContentOperation *mcop = [self.imapSession fetchMessageAttachmentOperationWithFolder:@"INBOX" uid:message.uid partID:part.partID encoding:part.encoding];
            mcop.progress = ^(unsigned int current, unsigned int maximum) {
              
                NSLog(@"%d of %d",current, maximum);
                cell.progressBar.progress = current;
                cell.progressLable.text = [NSString stringWithFormat:@"%d of %d kb",current, maximum];
            };
            
            [mcop start:^(NSError *error, NSData *data)
            {
                if (error != nil) {
                    NSLog(@"error:%@", error);
                    return;
                }
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *saveDirectory = [paths objectAtIndex:0];
                attachmentPath = [saveDirectory stringByAppendingPathComponent:part.filename];
                BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:attachmentPath];
                if (fileExists) {
                    NSLog(@"File already exists!");
                }
                else{
                    [data writeToFile:attachmentPath atomically:YES];
                }
                
                [self btnPressed:nil];
                
                btnAttachment.enabled = TRUE;
                
            }];
        }
    }
}


-(IBAction)btnPressed:(id)sender
{
    UIDocumentInteractionController *dc = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:attachmentPath]];
    dc.delegate = (id)self;
    [dc presentPreviewAnimated:YES];

}


- (void)documentInteractionControllerDidDismissOptionsMenu:(UIDocumentInteractionController *)controller {
    [UINavigationBar appearance].tintColor = [UIColor whiteColor];
}

/*
 dlegeate to ocument show controller : docment controller used to show image and pdf from the chat cell did select
 */
- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller;
{
    return self;
}




#pragma mark : UITableView DataSource

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.arrayOfMessages count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section ==  selectecSection)
        return 1;
    else
        return 0;
    
}

/**
 
 @brief set height of section header
 
 
 */
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 100;
}

/**
 
 @brief set height for cell in table view
 
 */
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 300;
    
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    
    mailHeaderTableViewCell *headerView;
    headerView= (mailHeaderTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"mailHeader"];
    if (headerView == nil)
        headerView = [[mailHeaderTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"mailHeader"];
    
    MCOIMAPMessage *message = [self.arrayOfMessages objectAtIndex:section];
    headerView.lblTo.text = [self getStringForArray:message.header.to];
    headerView.lblCC.text = [self getStringForArray:message.header.cc];
    headerView.lblFrom.text = [NSString stringWithFormat:@"%@ %@", message.header.from.displayName, message.header.from.mailbox];
    headerView.lblSubject.text = message.header.subject;
    
    
    
    [headerView.btnAction addTarget:self action:@selector(headerPressed:) forControlEvents:UIControlEventTouchUpInside];
    headerView.btnAction.tag = section;
    return headerView.contentView;
    
}




-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    maiFooterTableViewCell  *cell;
    cell= (maiFooterTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"mailFooter"];
    if (cell == nil)
        cell = [[maiFooterTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"mailFooter"];
    
    
    MCOIMAPMessage *message = [self.arrayOfMessages objectAtIndex:indexPath.section];

    NSString *cachedPreview = self.messagePreviews[[NSString stringWithFormat:@"%d", message.uid]];
    
    if (cachedPreview)
    {
        cell.txtViewMailBody.text = cachedPreview;
    }
    else
    {
        MCOIMAPMessageRenderingOperation * messageRenderingOperation;
        messageRenderingOperation = [self.imapSession plainTextBodyRenderingOperationWithMessage:message
                                                                                          folder:@"INBOX"];
        
        [messageRenderingOperation start:^(NSString * plainTextBodyString, NSError * error) {
            cell.txtViewMailBody.text = plainTextBodyString;
        }];
    }
    
    cell.btnAttachment.hidden = true;
    cell.progressLable.hidden = true;
    cell.progressBar  .hidden = true;
    cell.btnAttachment.enabled = true;
    
    if ([message.attachments count] > 0)
    {
        
        cell.btnAttachment.hidden = false;
        cell.progressLable.hidden = FALSE;
        cell.progressBar  .hidden = false;
        cell.btnAttachment.enabled = FALSE;
    }
    [self downlaodattachmentFormMessage:message andForCell:cell];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MCOIMAPMessage *message = [self.arrayOfMessages objectAtIndex:indexPath.section];
    [self downlaodattachmentFormMessage:message andForCell:(maiFooterTableViewCell*)[tableView cellForRowAtIndexPath:indexPath]];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
