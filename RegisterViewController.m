//
//  RegisterViewController.m
//  Pull
//
//  Created by Adam Horowitz on 8/12/14.
//
//

#import "RegisterViewController.h"
#import <Parse/Parse.h>
#import "VerificationViewController.h"
#import "VerificationNoFacebookViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "AppDelegate.h"

@interface RegisterViewController ()

@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;


@end

@implementation RegisterViewController

@synthesize verifyNum;
@synthesize verifyNumOnly;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (IBAction)registerWithoutButtonTouchHandler:(id)sender{
    if(![self.phoneTextField.text isEqualToString:@""]){
        self.verifyNum = [NSMutableString string];
        self.verifyNumOnly = [NSMutableString string];
        [self.verifyNum appendString:@"Your Pull Verification Number is: "];
        for(int i = 0; i < 4; i++){
            int num = arc4random() % 10;
            [self.verifyNum appendString: [NSString stringWithFormat:@"%d",num]];
            [self.verifyNumOnly appendString: [NSString stringWithFormat:@"%d",num]];
        }
        
        NSString *phoneNumber = self.phoneTextField.text;
        
        
        phoneNumber = [self fixPhoneNumber:phoneNumber];
        
        [PFCloud callFunctionInBackground:@"messageWithTwilio"
                           withParameters:@{@"number_from": @"16506662062",
                                            @"number_to": phoneNumber,
                                            @"message": self.verifyNum}
                                    block:^(NSString *response, NSError *error){
                                        
                                    }];
        
        VerificationNoFacebookViewController *nextView = [[VerificationNoFacebookViewController alloc] initWithNibName:@"VerificationNoFacebookViewController" bundle:nil];
        nextView.verifyNum = self.verifyNumOnly;
        nextView.phoneNumber = phoneNumber;
        [self presentViewController:nextView animated:YES completion:nil];
    }
    else
        NSLog(@"%@", @"failure");
}

- (IBAction)registerWithButtonTouchHandler:(id)sender{
    
    
    
    if(![self.phoneTextField.text isEqualToString:@""]){
        // If the session state is any of the two "open" states when the button is clicked
        if (FBSession.activeSession.state == FBSessionStateOpen
            || FBSession.activeSession.state == FBSessionStateOpenTokenExtended) {
            
            // Close the session and remove the access token from the cache
            // The session state handler (in the app delegate) will be called automatically
            [FBSession.activeSession closeAndClearTokenInformation];
            
            // If the session state is not any of the two "open" states when the button is clicked
        } else {
            // Open a session showing the user the login UI
            // You must ALWAYS ask for public_profile permissions when opening a session
            [FBSession openActiveSessionWithReadPermissions:@[@"public_profile"]
                                               allowLoginUI:YES
                                          completionHandler:
             ^(FBSession *session, FBSessionState state, NSError *error) {
                 
                 // Retrieve the app delegate
                 AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
                 // Call the app delegate's sessionStateChanged:state:error method to handle session state changes
                 [appDelegate sessionStateChanged:session state:state error:error];
             }];
        }
        
            NSString *phoneNumber = self.phoneTextField.text;
        
        
            phoneNumber = [self fixPhoneNumber:phoneNumber];
        
        self.verifyNum = [NSMutableString string];
        self.verifyNumOnly = [NSMutableString string];
        [self.verifyNum appendString:@"Your Pull Verification Number is: "];
        for(int i = 0; i < 4; i++){
            int num = arc4random() % 10;
            [self.verifyNum appendString: [NSString stringWithFormat:@"%d",num]];
            [self.verifyNumOnly appendString: [NSString stringWithFormat:@"%d",num]];
        }
        
        [PFCloud callFunctionInBackground:@"messageWithTwilio"
                           withParameters:@{@"number_from": @"16506662062",
                                            @"number_to": phoneNumber,
                                            @"message": self.verifyNum}
                                    block:^(NSString *response, NSError *error){
                                        
                                    }];

        
            VerificationViewController *nextView = [[VerificationViewController alloc] initWithNibName:@"VerificationViewController" bundle:nil];
            nextView.verifyNum = self.verifyNumOnly;
            nextView.phoneNumber = phoneNumber;
            [self presentViewController:nextView animated:YES completion:nil];
    }
    
}

- (void)viewDidLoad
{
    self.title = @"Registration";
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
