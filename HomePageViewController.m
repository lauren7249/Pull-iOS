//
//  HomePageViewController.m
//  Pull
//
//  Created by Adam Horowitz on 9/16/14.
//
//

#import "HomePageViewController.h"
#import "DatabaseHandler.h"
#import "SharedConvoViewController4S.h"
#import "SharedConvoViewController6.h"
#import "LoginViewController.h"
#import "AppDelegate.h"
#import <sys/utsname.h>


@interface HomePageViewController ()

@end

@implementation HomePageViewController

@synthesize sharedConversations;
@synthesize sharedConvoViewController;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Display the nav controller modally.
    
    self.navigationItem.title = @"Shared Conversations";
    
    UIBarButtonItem *logOutButton = [[UIBarButtonItem alloc] initWithTitle:@"Log Out" style:UIBarButtonItemStyleDone target:self action:@selector(logOut)];
    self.navigationItem.rightBarButtonItem = logOutButton;
    [self.navigationItem setHidesBackButton:YES animated:YES];
    
    UIEdgeInsets inset = UIEdgeInsetsMake(5, 0, 0, 0);
    self.tableView.contentInset = inset;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    DatabaseHandler *db = [[DatabaseHandler alloc] initWithDBInfo];
    [db updateSharedMessages];
    sharedConversations = [db getSharedConversations];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTable:) name:@"reloadSharedConversations" object:nil];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return sharedConversations.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary *currentConvo = [sharedConversations objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [currentConvo objectForKey:@"sharer"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ doesn't know you've shared", [currentConvo objectForKey:@"conversant"]];
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here, for example:
    // Create the next view controller.
    NSString *phoneType = [self deviceModel];
    if([phoneType isEqualToString:@"iPhone4,1"])
        sharedConvoViewController = [[SharedConvoViewController4S alloc] initWithNibName:@"SharedConvoViewController4S" bundle:nil];
    else if([phoneType isEqualToString:@"iPhone7,2"])
        sharedConvoViewController = [[SharedConvoViewController6 alloc] initWithNibName:@"SharedConvoViewController6" bundle:nil];
    
    // Pass the selected object to the new view controller.
    NSDictionary *currentConvo = [sharedConversations objectAtIndex:indexPath.row];
    
    sharedConvoViewController.convoID = [currentConvo objectForKey:@"convoID"];
    sharedConvoViewController.sharer = [currentConvo objectForKey:@"sharer"];
    sharedConvoViewController.conversant = [currentConvo objectForKey:@"conversant"];
    sharedConvoViewController.sharerPhone = [currentConvo objectForKey:@"sharerPhone"];
    sharedConvoViewController.conversantPhone = [currentConvo objectForKey:@"conversantPhone"];
    
    // Push the view controller.
    [self.navigationController pushViewController:sharedConvoViewController animated:NO];
}

- (void)reloadTable:(NSNotification *)notification{
    DatabaseHandler *db = [[DatabaseHandler alloc] initWithDBInfo];
    sharedConversations = [db getSharedConversations];
    [self.tableView reloadData];
}

-(void)logOut{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"pullPhone"];
    [defaults removeObjectForKey:@"pullPassword"];
    [PFUser logOut];
    self.hidesBottomBarWhenPushed = YES;
    LoginViewController *loginView = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    [self.navigationController pushViewController:loginView animated:YES];
    
    
    
}

- (NSString *)deviceModel
{
    struct utsname systemInfo;
    uname(&systemInfo);
    
    return [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
}




@end
