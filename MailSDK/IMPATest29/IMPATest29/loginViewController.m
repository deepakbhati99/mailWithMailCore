//
//  loginViewController.m
//  IMPATest29
//
//  Created by Deepak on 31/07/17.
//  Copyright © 2017 bdAppManiac. All rights reserved.
//

#import "loginViewController.h"

@interface loginViewController ()
{
    IBOutlet UITextField *txEmail, *txPassword;
}
@end

@implementation loginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(IBAction)loginPressed:(id)sender
{
    if ((txEmail.text.length > 0) && ([self IsValidEmail:txEmail.text]) && (txPassword.text.length > 0))
    {
        [[NSUserDefaults standardUserDefaults] setObject:txEmail.text forKey:@"email"];
        [[NSUserDefaults standardUserDefaults] setObject:txPassword.text forKey:@"password"];
        
        [[NSUserDefaults standardUserDefaults]synchronize];
        
        [self performSegueWithIdentifier:@"loginToInbox" sender:nil];
    }
}


-(BOOL)IsValidEmail:(NSString *)checkString
{
    if (checkString.length > 0) {
     
        //http://stackoverflow.com/questions/3139619/check-that-an-email-address-is-valid-on-ios
        
        BOOL stricterFilter = NO; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
        NSString *stricterFilterString = @"^[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}$";
        NSString *laxString = @"^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$";
        NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
        NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
        return [emailTest evaluateWithObject:checkString];

    }
    else
        return false;
    
    
    // USES - if([@"Email String" isValidEmail]) { /* True OR False*/ }
}


#pragma mark - TextField Delegates
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    return YES;
}

- (void) textFieldDidBeginEditing:(UITextField *)textField {
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
