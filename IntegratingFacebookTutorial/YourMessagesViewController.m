//
//  YourMessagesViewController.m
//  Pull
//
//  Created by Adam Horowitz on 11/19/14.
//
//

#import "YourMessagesViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "FacebookTableViewCell.h"
#import "FacebookConvoViewController.h"

@interface YourMessagesViewController ()

@property (weak, nonatomic) IBOutlet UITableView *messagesView;

@end

@implementation YourMessagesViewController

@synthesize facebookConversations;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Facebook Conversations";
    facebookConversations = [self getOneOnOneConvos:facebookConversations];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [facebookConversations count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"FacebookCell";
    FacebookTableViewCell *cell = [_messagesView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[FacebookTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        // More initializations if needed.
    }
    
    NSDictionary *currentConvo = [facebookConversations objectAtIndex:indexPath.row];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *userID = [defaults objectForKey:@"pullPassword"];
    
    NSArray *people = [[currentConvo objectForKey:@"to"] objectForKey:@"data"];
    NSDictionary *peopleDictionary = [people objectAtIndex:0];
    
    NSDictionary *messageInfo = [currentConvo objectForKey:@"comments"];
    cell.messageInfo = messageInfo;
    
    
    if([userID isEqualToString:[peopleDictionary objectForKey:@"id"]]){
        peopleDictionary = [people objectAtIndex:1];
    }
    
    cell.textLabel.text = [peopleDictionary objectForKey:@"name"];
    
    return cell;
}

#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FacebookTableViewCell *cell = (FacebookTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    
    FacebookConvoViewController *fvc = [[FacebookConvoViewController alloc] initWithNibName:@"FacebookConvoViewController" bundle:nil];
    fvc.messageInfo = cell.messageInfo;
    [self.navigationController pushViewController:fvc animated:NO];
}

// Helper method to handle errors during API calls
- (void)handleAPICallError:(NSError *)error
{
    // If the user has removed a permission that was previously granted
    if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryPermissions) {
        NSLog(@"Re-requesting permissions");
        // Ask for required permissions.
        return;
    }
    
    // Some Graph API errors need retries, we will have a simple retry policy of one additional attempt
    // We also retry on a throttling error message, a more sophisticated app should consider a back-off period
    if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryRetry ||
        [FBErrorUtility errorCategoryForError:error] == FBErrorCategoryThrottling) {
            NSLog(@"Retrying open graph post");
            // Recovery tactic: Call API again.
            return;
    }
    
    // For all other errors...
    NSString *alertText;
    NSString *alertTitle;
    
    // Get more error information from the error
    int errorCode = error.code;
    NSDictionary *errorInformation = [[[[error userInfo] objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"]
                                       objectForKey:@"body"]
                                      objectForKey:@"error"];
    int errorSubcode = 0;
    if ([errorInformation objectForKey:@"code"]){
        errorSubcode = [[errorInformation objectForKey:@"code"] integerValue];
    }
    
    // Check if it's a "duplicate action" error
    if (errorCode == 5 && errorSubcode == 3501) {
        // Tell the user the action failed because duplicate action-object  are not allowed
        alertTitle = @"Duplicate action";
        alertText = @"You already did this, you can perform this action only once on each item.";
        
        // If the user should be notified, we show them the corresponding message
    } else if ([FBErrorUtility shouldNotifyUserForError:error]) {
        alertTitle = @"Something Went Wrong";
        
    } else {
        // show a generic error message
        NSLog(@"Unexpected error posting to open graph: %@", error);
        alertTitle = @"Something went wrong";
    }
}

-(NSArray *)getOneOnOneConvos:(NSArray *)fc{
    NSMutableArray *rma = [[NSMutableArray alloc] init];
    for(int i = 0; i < [fc count]; i++){
        NSDictionary *currentConvo = [fc objectAtIndex:i];
        NSDictionary *people = [[currentConvo objectForKey:@"to"] objectForKey:@"data"];
        if([people count] == 2)
            [rma addObject:currentConvo];
    }
    
    NSArray *ra = [rma copy];
    return ra;
}



@end
