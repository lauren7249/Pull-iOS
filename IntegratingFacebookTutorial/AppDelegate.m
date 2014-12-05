//
//  Copyright (c) 2013 Parse. All rights reserved.

#import "AppDelegate.h"

#import <Parse/Parse.h>
#import "LoginViewController.h"
#import "HomePageViewController.h"
#import "SMSMessage.h"
#import <sqlite3.h>
#import "DatabaseHandler.h"
#import <AddressBook/AddressBook.h>
#import <FacebookSDK/FacebookSDK.h>
#import "MyTabBar.h"


@implementation AppDelegate


#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // ****************************************************************************
    // Fill in with your Parse credentials:
    // ****************************************************************************
     [Parse setApplicationId:@"V78CyTgjJqFRP1nOiUclf9siu8Bcja3D65i1UG34" clientKey:@"ccQmmMwIY3wTRaBayFecdfZc4N0EIpYR30R5KdeH"];
    
    // Register for push notifications
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else
    {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
    }
    
    //--- your custom code
    // Whenever a person opens the app, check for a cached session
  /*  if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
        
        // If there's one, just open the session silently, without showing the user the login UI
        [FBSession openActiveSessionWithReadPermissions:@[@"public_profile"]
                                           allowLoginUI:NO
                                      completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                          // Handler for session state changes
                                          // This method will be called EACH time the session state changes,
                                          // also for intermediate states and NOT just when the session open
                                          [self sessionStateChanged:session state:state error:error];
                                      }];
    } */
    
    //get Pushes
    NSDictionary *notificationPayload = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];

    
    // Override point for customization after application launch.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *phoneNumber = [defaults objectForKey:@"pullPhone"];
    NSString *password = [defaults objectForKey:@"pullPassword"];
    
    if(phoneNumber != nil){
        [PFUser logInWithUsername:phoneNumber password:password];
         
            if ([PFUser currentUser]) {
                NSLog(@"Success");
                
                if([[defaults objectForKey:@"pullIsFacebook"] isEqual:@"Yes"]){
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

                }
                
                
                MyTabBar *mtb = [[MyTabBar alloc] init];
                self.window.rootViewController = mtb;
                self.window.backgroundColor = [UIColor whiteColor];
                [self.window makeKeyAndVisible];
               
            } else {
                NSLog(@"Fail");
                LoginViewController *viewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
                self.rootController = [[UINavigationController alloc] initWithRootViewController:viewController];
                self.window.rootViewController = self.rootController;
                self.window.backgroundColor = [UIColor whiteColor];
                [self.window makeKeyAndVisible];
            }
    }
    else{
       LoginViewController *viewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        self.rootController = [[UINavigationController alloc] initWithRootViewController:viewController];
        self.window.rootViewController = self.rootController;
        self.window.backgroundColor = [UIColor whiteColor];
        [self.window makeKeyAndVisible];    
    }
    return YES;
}

// This method will handle ALL the session state changes in the app
- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error
{
    // If the session was opened successfully
    if (!error && state == FBSessionStateOpen){
        NSLog(@"Session opened");
        // Show the user the logged-in UI
        
        return;
    }
    if (state == FBSessionStateClosed || state == FBSessionStateClosedLoginFailed){
        // If the session is closed
        NSLog(@"Session closed");
        // Show the user the logged-out UI
        
    }
    
    // Handle errors
    if (error){
        NSLog(@"Error");
        NSString *alertText;
        NSString *alertTitle;
        // If the error requires people using an app to make an action outside of the app in order to recover
        if ([FBErrorUtility shouldNotifyUserForError:error] == YES){
            alertTitle = @"Something went wrong";
            alertText = [FBErrorUtility userMessageForError:error];
            ;
        } else {
            
            // If the user cancelled login, do nothing
            if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
                NSLog(@"User cancelled login");
                
                // Handle session closures that happen outside of the app
            } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession){
                alertTitle = @"Session Error";
                alertText = @"Your current session is no longer valid. Please log in again.";
                
                
                // Here we will handle all other errors with a generic error message.
                // We recommend you check our Handling Errors guide for more information
                // https://developers.facebook.com/docs/ios/errors/
            } else {
                //Get more error information from the error
                NSDictionary *errorInformation = [[[error.userInfo objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"] objectForKey:@"body"] objectForKey:@"error"];
                
                // Show the user an error message
                alertTitle = @"Something went wrong";
                alertText = [NSString stringWithFormat:@"Please retry. \n\n If the problem persists contact us and mention this error code: %@", [errorInformation objectForKey:@"message"]];
                
            }
        }
        // Clear this token
        [FBSession.activeSession closeAndClearTokenInformation];
        // Show the user the logged-out UI
        
    }
}

// ****************************************************************************
// App switching methods to support Facebook Single Sign-On.
// ****************************************************************************
// During the Facebook login flow, your app passes control to the Facebook iOS app or Facebook in a mobile browser.
// After authentication, your app will be called back with the session information.
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
}
- (void)applicationDidBecomeActive:(UIApplication *)application
{
    
    // Handle the user leaving the app while the Facebook login dialog is being shown
    // For example: when the user presses the iOS "home" button while the login dialog is active
    [FBAppCall handleDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
    [[PFFacebookUtils session] close];
}

- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
 {
    [PFPush handlePush:userInfo];
    // Parse JSON data and query
     if([[userInfo objectForKey:@"action"] isEqualToString:@"com.Pull.pullapp.util.ACTION_RECEIVE_SHARED_MESSAGES"]){
         NSString *sender = [self fixPhoneNumber:[userInfo objectForKey:@"from"]];
         NSString *owner = [self fixPhoneNumber:[userInfo objectForKey:@"owner"]];
         NSString *person_shared = [userInfo objectForKey:@"person_shared"];
         NSString *to = [userInfo objectForKey:@"to"];
         NSString *address = [self fixPhoneNumber:[userInfo objectForKey:@"address"]];
         NSString *messageType = [userInfo objectForKey:@"messageType"];
         
         int convoType;
         NSString *confidante;
         if([owner isEqualToString:[[PFUser currentUser] username]]){
             convoType = 2;
             confidante = sender;
         }
         else{
             convoType = 1;
             confidante = to;
         }
         PFQuery *query = [PFQuery queryWithClassName:@"SMSMessage"];
         [query whereKey:@"owner" equalTo:owner];
         [query whereKey:@"address" equalTo:address];
         [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
             if(!error){
                 NSLog(@"Successfully retrieved %lu messages.", (unsigned long)objects.count);
                 // Do something with the found objects
                 if(objects.count > 0){
                     [self notifySharedMessages:sender anOwner:owner aTo:to aConfidante:confidante aPerson_Shared:person_shared anAddress:address theObjects:objects aConvoType:convoType aMessageType:messageType];
                     ;
                     [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadSharedConversations" object:nil];
                 }
             }
             else{
                 NSLog(@"Error: %@ %@", error, [error userInfo]);
             }
         }];
     }
    
    
}

- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [PFPush handlePush:userInfo];
    // Parse JSON data and query
    if([[userInfo objectForKey:@"action"] isEqualToString:@"com.Pull.pullapp.util.ACTION_RECEIVE_SHARED_MESSAGES"]){
        NSString *sender = [self fixPhoneNumber:[userInfo objectForKey:@"from"]];
        NSString *owner = [self fixPhoneNumber:[userInfo objectForKey:@"owner"]];
        NSString *person_shared = [userInfo objectForKey:@"person_shared"];
        NSString *to = [userInfo objectForKey:@"to"];
        NSString *address = [self fixPhoneNumber:[userInfo objectForKey:@"address"]];
        NSString *messageType = [userInfo objectForKey:@"messageType"];
        
        int convoType;
        NSString *confidante;
        if([owner isEqualToString:[[PFUser currentUser] username]]){
            convoType = 2;
            confidante = sender;
        }
        else{
            convoType = 1;
            confidante = to;
        }
        PFQuery *query = [PFQuery queryWithClassName:@"SMSMessage"];
        [query whereKey:@"owner" equalTo:owner];
        [query whereKey:@"address" equalTo:address];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if(!error){
                NSLog(@"Successfully retrieved %lu messages.", (unsigned long)objects.count);
                // Do something with the found objects
                if(objects.count > 0){
                    [self notifySharedMessages:sender anOwner:owner aTo:to aConfidante:confidante aPerson_Shared:person_shared anAddress:address theObjects:objects aConvoType:convoType aMessageType:messageType];
                    ;
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadSharedConversations" object:nil];
                }
            }
            else{
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];
    }
    
    
}


-(void)notifySharedMessages:(NSString *)sender anOwner:(NSString *)owner aTo:(NSString *)to aConfidante:(NSString * )confidante aPerson_Shared:(NSString *)person_shared anAddress:(NSString *)address theObjects:(NSArray *)objects aConvoType:(int)convoType aMessageType:(NSString *)messageType{
    NSString* conversant;
    if(convoType == 1)
        conversant = owner;
    else
        conversant = confidante;
    NSString* convoID = [[owner stringByAppendingString:address] stringByAppendingString:conversant];
    NSLog(@"convoid from broadcastreceiver: %@", convoID);
    DatabaseHandler *db = [[DatabaseHandler alloc] initWithDBInfo];
    
    for(PFObject *object in objects){
        [db addSharedMessage:convoID aMsg:object aConvoType:convoType];
    }
    
    NSString *from = [self getNameFromContacts:sender];
    NSLog(@"%@", from);
    [db addSharedConversation:convoID aConfidante:confidante anOriginalRecipientName:person_shared anOriginalRecipient:address anOwner:owner aType:convoType];
    NSLog(@"%@", [[PFUser currentUser] username]);
    if(![to isEqualToString:[[PFUser currentUser] username]]) return;
    NSArray *subscribedChannels = [PFInstallation currentInstallation].channels;
    PFPush *push = [[PFPush alloc] init];
    [push setChannel:subscribedChannels[0]];
    [push setMessage:[NSString stringWithFormat:@"%@'s messages with %@", from, person_shared]];
    [push sendPushInBackground];
    [db close];
}

- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    // check if you are in video page --> return landscape
    return UIInterfaceOrientationMaskPortrait;
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

-(NSString *)getNameFromContacts:(NSString *)sender
{
    CFErrorRef *error = nil;
    
    
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
    
    __block BOOL accessGranted = NO;
    if (ABAddressBookRequestAccessWithCompletion != NULL) { // we're on iOS 6
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            accessGranted = granted;
            dispatch_semaphore_signal(sema);
        });
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        
    }
    else { // we're on iOS 5 or older
        accessGranted = YES;
    }
    
    if (accessGranted) {
        
#ifdef DEBUG
        NSLog(@"Fetching contact info ----> ");
#endif
        
        
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
        ABRecordRef source = ABAddressBookCopyDefaultSource(addressBook);
        CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeopleInSourceWithSortOrdering(addressBook, source, kABPersonSortByFirstName);
        CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);
        
        
        for (int i = 0; i < nPeople; i++)
        {
            
            ABRecordRef person = CFArrayGetValueAtIndex(allPeople, i);
            
            //get First Name and Last Name
            
            NSString *firstNames = (__bridge NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty);
            
            NSString *lastNames =  (__bridge NSString*)ABRecordCopyValue(person, kABPersonLastNameProperty);
            
            if (!firstNames) {
                firstNames = @"";
            }
            if (!lastNames) {
                lastNames = @"";
            }
            else{
                lastNames = [@" " stringByAppendingString:lastNames];
            }
            //get Phone Numbers
            
            ABMultiValueRef multiPhones = ABRecordCopyValue(person, kABPersonPhoneProperty);
            for(CFIndex i=0;i<ABMultiValueGetCount(multiPhones);i++) {
                
                CFStringRef phoneNumberRef = ABMultiValueCopyValueAtIndex(multiPhones, i);
                NSString *phoneNumber = (__bridge NSString *) phoneNumberRef;
                NSString *newPhoneNumber = [[phoneNumber componentsSeparatedByCharactersInSet:
                                        [[NSCharacterSet decimalDigitCharacterSet] invertedSet]]
                                       componentsJoinedByString:@""];
                if(newPhoneNumber.length == 10)
                    newPhoneNumber = [@"1" stringByAppendingString:newPhoneNumber];
                if([sender isEqualToString:(newPhoneNumber)]){
                    return [firstNames stringByAppendingString:lastNames];
                }
                
                
                //NSLog(@"All numbers %@", phoneNumbers);
                
            }
            
#ifdef DEBUG
            //NSLog(@"Person is: %@", contacts.firstNames);
            //NSLog(@"Phones are: %@", contacts.numbers);
            //NSLog(@"Email is:%@", contacts.emails);
#endif
            
            
            
            
        }
        return nil;
        
        
        
    } else {
#ifdef DEBUG
        NSLog(@"Cannot fetch Contacts :( ");
#endif
        return NO;
        
        
    }
    
}


@end
