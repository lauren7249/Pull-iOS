//
//  VerificationNoFacebookViewController.m
//  Pull
//
//  Created by Adam Horowitz on 10/9/14.
//
//

#import "VerificationNoFacebookViewController.h"
#import "LoginViewController.h"
#import <Parse/Parse.h>

@interface VerificationNoFacebookViewController ()

@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *verifyNumberField;

@end

@implementation VerificationNoFacebookViewController

@synthesize verifyNum;
@synthesize phoneNumber;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)verifyButtonTouchHandler:(id)sender{
    if([self.verifyNumberField.text isEqualToString:self.verifyNum] && ![self.passwordTextField.text isEqualToString:@""]){
        NSLog(@"Success");
        PFUser *user = [PFUser user];
        user.username = self.phoneNumber;
        user.password = self.passwordTextField.text;
        [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if(!error){
                PFInstallation *currentInstallation = [PFInstallation currentInstallation];
                [currentInstallation addUniqueObject:[@"phoneNumber" stringByAppendingString:self.phoneNumber] forKey:@"channels"];
                [currentInstallation setObject:user forKey:@"user"];
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
    else{
        NSLog(@"Failure");
    }
    
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
