//
//  LoginViewController.m
//  Pull
//
//  Created by Adam Horowitz on 8/25/14.
//
//

#import "LoginViewController.h"
#import "RegisterViewController.h"
#import "HomePageViewController.h"
#import <Parse/Parse.h>
#import "AppDelegate.h"
#import "MyTabBar.h"

@interface LoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    self.title = @"Welcome To Pull!";
    [self.navigationItem setHidesBackButton:YES animated:YES];
    
    [super viewDidAppear:YES];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)registerTouchHandler:(id)sender
{
    RegisterViewController *nextView = [[RegisterViewController alloc] initWithNibName:@"RegisterViewController" bundle:nil];
    [self.navigationController pushViewController:nextView animated:YES];
}

- (IBAction)loginTouchHandler:(id)sender
{
    NSString *phoneNumber = self.phoneTextField.text;
    phoneNumber = [self fixPhoneNumber:phoneNumber];
    
    
    [PFUser logInWithUsernameInBackground:phoneNumber password:self.passwordTextField.text
        block:^(PFUser *user, NSError *error) {
            if (user) {
                NSLog(@"Success");
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setObject:phoneNumber forKey:@"pullPhone"];
                [defaults setObject:self.passwordTextField.text forKey:@"pullPassword"];
                [defaults synchronize];
                
                
                HomePageViewController *nextView = [[HomePageViewController alloc] initWithNibName:@"HomePageViewController" bundle:nil];
                [self.navigationController pushViewController:nextView animated:YES];
            } else {
                NSLog(@"Fail");
            }
        }];
}

- (IBAction)loginFacebookTouchHandler:(id)sender
{
    NSString *phoneNumber = self.phoneTextField.text;
    phoneNumber = [self fixPhoneNumber:phoneNumber];
    
    if (!FBSession.activeSession.isOpen) {
        [FBSession openActiveSessionWithReadPermissions:@[@"public_profile", @"read_mailbox"]
                                           allowLoginUI:YES
                                      completionHandler:
         ^(FBSession *session, FBSessionState state, NSError *error) {
             
             // Retrieve the app delegate
             AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
             // Call the app delegate's sessionStateChanged:state:error method to handle session state changes
             [appDelegate sessionStateChanged:session state:state error:error];
         }];
    }
    
    if(FBSession.activeSession.isOpen){
    
        [FBSettings setLoggingBehavior:[NSSet setWithObjects:
                                        FBLoggingBehaviorFBRequests,
                                        nil]];
        
        [[FBRequest requestForMe] startWithCompletionHandler:
         ^(FBRequestConnection *connection,
           NSDictionary<FBGraphUser> *user,
           NSError *error) {
             if (!error) {
                 [PFUser logInWithUsernameInBackground:phoneNumber password:[user objectForKey:@"id"]
                     block:^(PFUser *user2, NSError *error) {
                         if (user2) {
                             NSLog(@"Success");
                             NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                             [defaults setObject:phoneNumber forKey:@"pullPhone"];
                             [defaults setObject:[user objectForKey:@"id"] forKey:@"pullPassword"];
                             [defaults setObject:@"Yes" forKey:@"pullIsFacebook"];
                             [defaults synchronize];
                             
                             MyTabBar *mtb = [[MyTabBar alloc] init];
                             [self.navigationController pushViewController:mtb animated:YES];
                         } else {
                             NSLog(@"Fail");
                         }
                }];
                 
             }
         }];
    }
}

- (NSString*)fixPhoneNumber:(NSString*)phoneNumber
{
    if(phoneNumber == nil)
        return phoneNumber;
    
    if(phoneNumber.length == 0)
        return phoneNumber;
    
    NSString *newPhoneNumber = phoneNumber;
    
    if([[newPhoneNumber substringWithRange:NSMakeRange(0,1)] isEqualToString:@"+"]){
        newPhoneNumber = [newPhoneNumber substringFromIndex:1];
    }
    
    if(newPhoneNumber.length == 10){
        newPhoneNumber = [@"1" stringByAppendingString:newPhoneNumber];
    }
    
    return newPhoneNumber;
}



@end
