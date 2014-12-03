//
//  VerificationViewController.m
//  Pull
//
//  Created by Adam Horowitz on 8/12/14.
//
//

#import "VerificationViewController.h"
#import "LoginViewController.h"
#import <Parse/Parse.h>

@interface VerificationViewController ()

@property (weak, nonatomic) IBOutlet UITextField *verifyNumberField;

@end

@implementation VerificationViewController

@synthesize verifyNum;
@synthesize phoneNumber;

- (IBAction)verifyButtonTouchHandler:(id)sender{
    if([self.verifyNumberField.text isEqualToString:self.verifyNum]){
        
        
        
        
        if (FBSession.activeSession.isOpen) {
            
            [FBSettings setLoggingBehavior:[NSSet setWithObjects:
                                            FBLoggingBehaviorFBRequests,
                                            nil]];
            
            [[FBRequest requestForMe] startWithCompletionHandler:
             ^(FBRequestConnection *connection,
               NSDictionary<FBGraphUser> *user,
               NSError *error) {
                 if (!error) {
                     NSLog(@"Success");
                     PFUser *pfuser = [PFUser user];
                     pfuser.username = self.phoneNumber;
                     pfuser.password = [user objectForKey:@"id"];
                     [pfuser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                         if(!error){
                             PFInstallation *currentInstallation = [PFInstallation currentInstallation];
                             [currentInstallation addUniqueObject:[@"phoneNumber" stringByAppendingString:self.phoneNumber] forKey:@"channels"];
                             [currentInstallation setObject:pfuser forKey:@"user"];
                             [currentInstallation saveInBackground];
                             
                             PFPush *push = [[PFPush alloc] init];
                             [push setChannel:[@"phoneNumber" stringByAppendingString:self.phoneNumber]];
                             [push setMessage:@"You have successfully registered"];
                             [push sendPushInBackground];
                             
                             LoginViewController *nextView = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
                             [self presentViewController:nextView animated:YES completion:nil];
                             
                             
                             
                         } else{
                             NSString *errorString = [error userInfo][@"error"];
                             NSLog(errorString);
                         }
                     }];

                 }
             }];
        }
    }
    else{
        NSLog(@"Failure");
    }
    
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
