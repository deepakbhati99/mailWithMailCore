//
//  ViewController.m
//  IMPATest29
//
//  Created by Deepak Bhati on 7/29/17.
//  Copyright © 2017 bdAppManiac. All rights reserved.
//

//For IMAP
#define kHostName @"imap.gmail.com"
#define kPortName 993


//For SMTP
#define kHostNameSMTP @"smtp.gmail.com"
#define kPortNameSMTP 465



#define kFromMail @"abc@abc.com"
#define kToMail   @"abc@abc.com"

#define NUMBER_OF_MESSAGES_TO_LOAD		20


#import "InboxViewController.h"
#import "AppDelegate.h"
#import <MailCore/MailCore.h>
#import "MCTMsgViewController.h"
#import "messageViewController.h"
#import "MCTTableViewCell.h"

@interface InboxViewController ()
{
    NSArray *messageArray;
    NSMutableDictionary *filterDict;
    IBOutlet UITableView *messageTableView;
    NSMutableDictionary *messagePreviews;
    AppDelegate *appdelegate;
    int messageCount;
    
    
    
    
    UICollectionView *cool;

}
@property (nonatomic, strong) UIActivityIndicatorView *loadMoreActivityView;
@property (nonatomic) BOOL isLoading;
@property (nonatomic) MCOIMAPSession *imapSession;
@property (nonatomic, strong) MCOIMAPFetchMessagesOperation *imapMessagesFetchOp;
@property (nonatomic, strong) MCOIMAPMessageRenderingOperation * messageRenderingOperation;

@property (nonatomic) NSInteger totalNumberOfInboxMessages;
@end

@implementation InboxViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    appdelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    self.isLoading = NO;

    
    self.loadMoreActivityView =
    [[UIActivityIndicatorView alloc]
     initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];

    
    [self initIMAPSession];
    [self fetchEmail:NUMBER_OF_MESSAGES_TO_LOAD];
    messageArray = nil;
    messagePreviews = [NSMutableDictionary new];
    messageCount = 0;
    
    self.totalNumberOfInboxMessages = -1;
    [messageTableView reloadData];


    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)initIMAPSession{
    _imapSession = [[MCOIMAPSession alloc] init];
    _imapSession.hostname = kHostName;
    [_imapSession setConnectionType:MCOConnectionTypeTLS];
    
    
    
    NSLog(@"email %@",[[NSUserDefaults standardUserDefaults]objectForKey:@"email"]);
    NSLog(@"password %@",[[NSUserDefaults standardUserDefaults]objectForKey:@"password"]);
    
    [_imapSession setPort: kPortName];
    [_imapSession setUsername:[[NSUserDefaults standardUserDefaults]objectForKey:@"email"]];
    [_imapSession setPassword:[[NSUserDefaults standardUserDefaults]objectForKey:@"password"]];
    [_imapSession setConnectionType:MCOConnectionTypeTLS];
    
}


-(void)fetchEmail:(NSUInteger)nMessages{
    
    [appdelegate showLoading];
    self.isLoading = YES;
    
    
    MCOIMAPMessagesRequestKind requestKind = (MCOIMAPMessagesRequestKind)
    (MCOIMAPMessagesRequestKindHeaders | MCOIMAPMessagesRequestKindStructure |
     MCOIMAPMessagesRequestKindInternalDate | MCOIMAPMessagesRequestKindHeaderSubject |
     MCOIMAPMessagesRequestKindFlags | MCOIMAPMessagesRequestKindGmailThreadID);
    
    NSString *inboxFolder = @"INBOX";
    MCOIMAPFolderInfoOperation *inboxFolderInfo = [self.imapSession folderInfoOperation:inboxFolder];
    
    [inboxFolderInfo start:^(NSError *error, MCOIMAPFolderInfo *info)
     {
         BOOL totalNumberOfMessagesDidChange =
         self.totalNumberOfInboxMessages != [info messageCount];
         
         self.totalNumberOfInboxMessages = [info messageCount];
         
         NSUInteger numberOfMessagesToLoad =
         MIN(self.totalNumberOfInboxMessages, nMessages);
         
         MCORange fetchRange;
         
         // If total number of messages did not change since last fetch,
         // assume nothing was deleted since our last fetch and just
         // fetch what we don't have
         if (!totalNumberOfMessagesDidChange && messageArray.count)
         {
             numberOfMessagesToLoad -= messageArray.count;
             
             fetchRange =
             MCORangeMake(self.totalNumberOfInboxMessages -
                          messageArray.count -
                          (numberOfMessagesToLoad - 1),
                          (numberOfMessagesToLoad - 1));
         }
         
         // Else just fetch the last N messages
         else
         {
             fetchRange =
             MCORangeMake(self.totalNumberOfInboxMessages -
                          (numberOfMessagesToLoad - 1),
                          (numberOfMessagesToLoad - 1));
         }
         
         self.imapMessagesFetchOp =
         [self.imapSession fetchMessagesByNumberOperationWithFolder:inboxFolder
                                                        requestKind:requestKind
                                                            numbers:
          [MCOIndexSet indexSetWithRange:fetchRange]];
         
         [self.imapMessagesFetchOp setProgress:^(unsigned int progress) {
             NSLog(@"Progress: %u of %lu", progress, (unsigned long)numberOfMessagesToLoad);
         }];
         
         [self.imapMessagesFetchOp start:
          ^(NSError *error, NSArray *messages, MCOIndexSet *vanishedMessages)
          {
              [appdelegate hideLoading];
              self.isLoading = NO;
              

              if (messages.count > 0)
              {
                  NSLog(@"fetched all messages.");
                  
                  
                  NSSortDescriptor *sort =
                  [NSSortDescriptor sortDescriptorWithKey:@"header.date" ascending:NO];
                  
                  NSMutableArray *combinedMessages =
                  [NSMutableArray arrayWithArray:messages];
                  [combinedMessages addObjectsFromArray:messageArray];
                  
                  messageArray =
                  [combinedMessages sortedArrayUsingDescriptors:@[sort]];
                  [self filterMailAccordingToThreadID];

              }
              else
              {
                   [self showAlertView:[error localizedDescription]];

              }
              
             
              
          }];
     }];
}


-(void)filterMailAccordingToThreadID
{
    filterDict = [[NSMutableDictionary alloc]init];
    
    NSMutableArray *temp = [[NSMutableArray alloc]initWithArray:messageArray];
    
    for (int i = 0; i < temp.count; i++)
    {
        MCOIMAPMessage *messageI = temp[i];
        [filterDict setObject:[[NSMutableArray alloc]init] forKey:[NSString stringWithFormat:@"%d",i]];
        [[filterDict objectForKey:[NSString stringWithFormat:@"%d",i]] addObject:messageI];
        for (int j = i; j < temp.count; j++)
        {
            MCOIMAPMessage *messageJ = temp[j];
            if ((messageI.gmailThreadID == messageJ.gmailThreadID) &&(i != j)) {
                [[filterDict objectForKey:[NSString stringWithFormat:@"%d",i]] addObject:messageJ];
                [temp removeObjectAtIndex:j];
            }
        }
    }
    
    NSLog(@"done");
    [messageTableView reloadData];

    
    
}

-(void)newMail{
    [appdelegate showLoading];
    MCOSMTPSession *smtpSession = [[MCOSMTPSession alloc] init];
    smtpSession.hostname = kHostNameSMTP;
    smtpSession.port = kPortNameSMTP;
    smtpSession.username = [[NSUserDefaults standardUserDefaults]objectForKey:@"email"];
    smtpSession.password = [[NSUserDefaults standardUserDefaults]objectForKey:@"password"];
    smtpSession.authType = MCOAuthTypeSASLPlain;
    smtpSession.connectionType = MCOConnectionTypeTLS;
    
    MCOMessageBuilder *builder = [[MCOMessageBuilder alloc] init];
    MCOAddress *from = [MCOAddress addressWithDisplayName:@"Deepak"
                                                  mailbox:kFromMail];
    MCOAddress *to = [MCOAddress addressWithDisplayName:nil
                                                mailbox:kToMail];
    [[builder header] setFrom:from];
    [[builder header] setTo:@[to]];
    [[builder header] setSubject:@"Test Mail"];
    [builder setHTMLBody:@"This is a test message!"];
    NSData * rfc822Data = [builder data];
    
    MCOSMTPSendOperation *sendOperation =
    [smtpSession sendOperationWithData:rfc822Data];
    [sendOperation start:^(NSError *error) {
        [appdelegate hideLoading];
        if(error) {
            [self showAlertView:error.localizedDescription];
            NSLog(@"Error sending email: %@", error);
        } else {
            NSLog(@"Successfully sent email!");
            [self showAlertView:@"Successfully sent email!"];
        }
    }];
}


-(IBAction)sendNewMailAction:(id)sender{
    [self newMail];
}



-(void)downlaodattachmentFormMessage:(MCOIMAPMessage *)message
{
    
    if ([message.attachments count] > 0) {
        
        for (int k = 0; k < [message.attachments count]; k++) {
            MCOIMAPPart *part = [message.attachments objectAtIndex:k];
           // MCOIMAPFetchContentOperation *mcop = [self.imapSession fetchMessageAttachmentByUIDOperationWithFolder:@"INBOX" uid:message.uid partID:part.partID encoding:part.encoding];
            
            
            MCOIMAPFetchContentOperation *mcop = [self.imapSession fetchMessageAttachmentOperationWithFolder:@"INBOX" uid:message.uid partID:part.partID encoding:part.encoding];
            [mcop start:^(NSError *error, NSData *data) {
                if (error != nil) {
                    NSLog(@"error:%@", error);
                    return;
                }
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *saveDirectory = [paths objectAtIndex:0];
                NSString *attachmentPath = [saveDirectory stringByAppendingPathComponent:part.filename];
                BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:attachmentPath];
                if (fileExists) {
                    NSLog(@"File already exists!");
                }
                else{
                    [data writeToFile:attachmentPath atomically:YES];
                }
            }];
        }
    }
}


#pragma mark : UITableView DataSource

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 1)
    {
        if (self.totalNumberOfInboxMessages >= 0)
            return 1;
        
        return 0;
    }
    
    return [filterDict allKeys].count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    switch (indexPath.section)
    {
        case 0:
        {
            MCTTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MailCell" forIndexPath:indexPath];
            //MCOIMAPMessage *message = messageArray[indexPath.row];
            MCOIMAPMessage *message = [[filterDict objectForKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]] objectAtIndex:0];
            
            UILabel *titleLabel = [cell viewWithTag:1];
            UILabel *subtitleLabel = [cell viewWithTag:2];

            titleLabel.text = message.header.subject;
            
            NSLog(@"thread ID %llu",message.gmailThreadID);
            NSLog(@"message  ID %llu",message.gmailMessageID);
            
            NSString *uidKey = [NSString stringWithFormat:@"%d", message.uid];
            NSString *cachedPreview = messagePreviews[uidKey];
            
            if (cachedPreview)
            {
                
                subtitleLabel.text = cachedPreview;
            }
            else
            {
                cell.messageRenderingOperation = [self.imapSession plainTextBodyRenderingOperationWithMessage:message
                                                                                                       folder:@"INBOX"];
                
                [cell.messageRenderingOperation start:^(NSString * plainTextBodyString, NSError * error) {
                    subtitleLabel.text = plainTextBodyString;
                    cell.messageRenderingOperation = nil;
                    messagePreviews[uidKey] = plainTextBodyString;
                }];
            }
            
            return cell;
            break;
        }
            
        case 1:
        {
            UITableViewCell *cell =
            [tableView dequeueReusableCellWithIdentifier:@"InboxStatusCell"];
            
            if (!cell)
            {
                cell =
                [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                       reuseIdentifier:@"InboxStatusCell"];
                
                cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
                cell.textLabel.textAlignment = NSTextAlignmentCenter;
                cell.detailTextLabel.textAlignment = NSTextAlignmentCenter;
            }
            
            if (messageArray.count < self.totalNumberOfInboxMessages)
            {
                cell.textLabel.text =
                [NSString stringWithFormat:@"Load %lu more",
                 MIN(self.totalNumberOfInboxMessages - messageArray.count,
                     NUMBER_OF_MESSAGES_TO_LOAD)];
            }
            else
            {
                cell.textLabel.text = nil;
            }
            
            cell.detailTextLabel.text =
            [NSString stringWithFormat:@"%ld message(s)",
             (long)self.totalNumberOfInboxMessages];
            
            cell.accessoryView = self.loadMoreActivityView;
            
            if (self.isLoading)
                [self.loadMoreActivityView startAnimating];
            else
                [self.loadMoreActivityView stopAnimating];
            
            return cell;
            break;
        }
            
        default:
            return nil;
            break;
    }
    
}

    
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MessageCell" forIndexPath:indexPath];
//    MCOIMAPMessage *message = messageArray[indexPath.row];
//    
//    NSLog(@"thread ID %llu",message.gmailThreadID);
//    NSLog(@"message  ID %llu",message.gmailMessageID);
//    
//    if (indexPath.row == 0) {
//        [self downlaodattachmentFormMessage:message];
//    }
//   // MCOIMAPMessagesRequestKindGmailThreadID
//    
//
//    NSLog(@"Attachemnt %@",[message.attachments description]);
//    
//    
//    UILabel *titleLabel = [cell viewWithTag:1];
//    titleLabel.text = message.header.subject;
//    UILabel *subtitleLabel = [cell viewWithTag:2];
//    NSString *uidKey = [NSString stringWithFormat:@"%d", message.uid];
//    NSString *cachedPreview = messagePreviews[uidKey];
//    
//    //    if (cachedPreview)
//    //    {
//    subtitleLabel.text = cachedPreview;
//    //    }
//    //    else
//    //    {
//    //        cell.messageRenderingOperation = [self.imapSession plainTextBodyRenderingOperationWithMessage:message
//    //                                                                                               folder:@"INBOX"];
//    //
//    //        [cell.messageRenderingOperation start:^(NSString * plainTextBodyString, NSError * error) {
//    //            subtitleLabel.text = plainTextBodyString;
//    //            cell.messageRenderingOperation = nil;
//    //            messagePreviews[uidKey] = plainTextBodyString;
//    //        }];
//    //    }
//    return cell;
//}




-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //MCOIMAPMessage *message = messageArray[indexPath.row];

    
    switch (indexPath.section)
    {
        case 0:
        {
//            MCOIMAPMessage *msg = messageArray[indexPath.row];
//            MCTMsgViewController *vc = [[MCTMsgViewController alloc] init];
//            vc.folder = @"INBOX";
//            vc.message = msg;
//            vc.session = self.imapSession;
//            [self.navigationController pushViewController:vc animated:YES];
            
            [self performSegueWithIdentifier:@"showMessageFullView" sender:[filterDict objectForKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]]];

            
            break;
        }
            
        case 1:
        {
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            
            if (!self.isLoading &&
                messageArray.count < self.totalNumberOfInboxMessages)
            {
                [self fetchEmail:messageArray.count + NUMBER_OF_MESSAGES_TO_LOAD];
                cell.accessoryView = self.loadMoreActivityView;
                [self.loadMoreActivityView startAnimating];
            }
            
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            break;
        }
            
        default:
            break;
    }
    

    
    
//    MCOIMAPMessage *msg = messageArray[indexPath.row];
//    MCTMsgViewController *vc = [[MCTMsgViewController alloc] init];
//    vc.folder = @"INBOX";
//    vc.message = msg;
//    vc.session = self.imapSession;
//    [self.navigationController pushViewController:vc animated:YES];

//    [self performSegueWithIdentifier:@"showMessageFullView" sender:msg];

 

    //        MCOIMAPMessage *msg = messageArray[indexPath.row];
    //        MCTMsgViewController *vc = [[MCTMsgViewController alloc] init];
    //        vc.folder = @"INBOX";
    //        vc.message = msg;
    //        vc.session = self.imapSession;
    //        [self.navigationController pushViewController:vc animated:YES];
}

-(void)showAlertView:(NSString *)msg{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:msg delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alert show];
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    messageViewController *vc = [segue destinationViewController];
    vc.folder = @"INBOX";
    vc.arrayOfMessages = [[NSMutableArray alloc]initWithArray: (NSMutableArray*)sender];
    vc.imapSession = self.imapSession;
    vc.messagePreviews = [[NSMutableDictionary alloc]initWithDictionary:messagePreviews];

    
    
}


@end
