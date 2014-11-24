//
//  PhoneNumberViewController.m
//  Pull
//
//  Created by Adam Horowitz on 6/23/14.
//
//

#import "PhoneNumberViewController.h"
#import <CommonCrypto/CommonHMAC.h>
#import <Parse/Parse.h>

@interface PhoneNumberViewController ()

@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;

@end

@implementation PhoneNumberViewController

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

- (IBAction)validateButtonTouchHandler:(id)sender{
    if([self isPhoneNumber:self.phoneTextField.text]){
        PFUser *user = [PFUser user];
        user.username = self.phoneTextField.text;
        
        UIDevice *thisDevice = [UIDevice currentDevice];
        NSUUID *uniqueIdentifier = [thisDevice identifierForVendor];
        NSString *uI = [uniqueIdentifier UUIDString];
        
        NSString *pass = [self hashString:self.phoneTextField.text withSalt:uI];
        NSLog(pass);
        
        user.password = pass;
        
        [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
            if(!error){
                NSLog(@"Success!");
                PFObject *channel = [PFObject objectWithClassName:@"Channels"];
                channel[@"channel"] = [[NSArray arrayWithObjects:@"phoneNumber", self.phoneTextField.text, nil]componentsJoinedByString:@""];
                channel[@"user"] = user;
                [channel saveInBackground];
            }
            else{
                NSLog([error userInfo][@"error"]);
            }
            
        }];
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Phone Number" message:@"You must enter a valid 10 digit phone number." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
}

-(NSString *) hashString :(NSString *) data withSalt: (NSString *) salt {
    
    
    const char *cKey  = [salt cStringUsingEncoding:NSUTF8StringEncoding];
    const char *cData = [data cStringUsingEncoding:NSUTF8StringEncoding];
    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    
    NSString *hash;
    
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", cHMAC[i]];
    hash = output;
    return hash;
    
}

- (BOOL)isPhoneNumber:(NSString*)number
{
    NSString *numberRegEx = @"[0-9]{10}";
    NSPredicate *numberTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", numberRegEx];
    if ([numberTest evaluateWithObject:number] == YES)
        return TRUE;
    else
        return FALSE;
}

@end
