//
//  FacebookConvoViewController.m
//  Pull
//
//  Created by Adam Horowitz on 12/3/14.
//
//

#import "FacebookConvoViewController.h"
#import "PTSMessagingCell.h"
#import "STBubbleTableViewCell.h"

@interface FacebookConvoViewController ()


@end


@implementation FacebookConvoViewController

@synthesize messageInfo;
@synthesize comments;

- (void)viewDidLoad {
    [super viewDidLoad];
    comments = [messageInfo ]
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

#pragma mark - UITableViewDatasource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString* cellIdentifier = @"messagingCell";
    
    PTSMessagingCell * cell = (PTSMessagingCell*) [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[PTSMessagingCell alloc] initMessagingCellWithReuseIdentifier:cellIdentifier];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

#pragma mark - UITableViewDelegate methods

//---returns the height for the table view row---
- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGSize messageSize = [PTSMessagingCell messageSize:[listOfMessages objectAtIndex:indexPath.row]];
    return messageSize.height + 2*[PTSMessagingCell textMarginVertical] + 40.0f;
}

#pragma mark - STBubbleTableViewCellDataSource methods

- (CGFloat)minInsetForCell:(STBubbleTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    if(UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
    {
        return 100.0f;
    }
    
    return 50.0f;
}

#pragma mark - STBubbleTableViewCellDelegate methods

- (void)tappedImageOfCell:(STBubbleTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSString *message = [listOfMessages objectAtIndex:indexPath.row];
    NSLog(@"%@", message);
}

#pragma mark -

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

-(void)configureCell:(id)cell atIndexPath:(NSIndexPath *)indexPath {
    PTSMessagingCell* ccell = (PTSMessagingCell*)cell;
    
    if ([[typeOfMessages objectAtIndex:indexPath.row] isEqualToString:@"2"]) {
        NSArray *senderInitials = [sharer componentsSeparatedByString:@" "];
        
        ccell.sent = YES;
        UIImage *withInitials = [[UIImage imageNamed:@"Green_Circle"] jsq_imageMaskedWithColor:[UIColor jsq_messageBubbleGreenColor]];
        ccell.avatarImageView.image = withInitials;
        ccell.avatarImageView.contentMode = UIViewContentModeCenter;
        ccell.avatarImageView.contentMode = UIViewContentModeScaleAspectFit;
        if(senderInitials.count == 1)
            ccell.initialsLabel.text = [NSString stringWithFormat:@"%@", [senderInitials[0] substringWithRange:NSMakeRange(0, 1)]];
        else
            ccell.initialsLabel.text = [NSString stringWithFormat:@"%@%@", [senderInitials[0] substringWithRange:NSMakeRange(0, 1)], [senderInitials[1] substringWithRange:NSMakeRange(0, 1)]];
        ccell.initialsLabel.textColor = [UIColor jsq_messageBubbleGreenColor];
        ccell.initialsLabel.textAlignment = NSTextAlignmentCenter;
        ccell.messageLabel.textColor = [UIColor whiteColor];
    } else {
        NSArray *conversantInitials = [conversant componentsSeparatedByString:@" "];
        ccell.sent = NO;
        ccell.avatarImageView.image = [[UIImage imageNamed:@"Green_Circle"] jsq_imageMaskedWithColor:[UIColor grayColor]];
        ccell.avatarImageView.contentMode = UIViewContentModeCenter;
        ccell.avatarImageView.contentMode = UIViewContentModeScaleAspectFit;
        if(conversantInitials.count == 1)
            ccell.initialsLabel.text = [NSString stringWithFormat:@"%@", [conversantInitials[0] substringWithRange:NSMakeRange(0, 1)]];
        else
            ccell.initialsLabel.text = [NSString stringWithFormat:@"%@%@", [conversantInitials[0] substringWithRange:NSMakeRange(0, 1)], [conversantInitials[1] substringWithRange:NSMakeRange(0, 1)]];
        ccell.initialsLabel.textColor = [UIColor grayColor];
        ccell.initialsLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    ccell.messageLabel.text = [listOfMessages objectAtIndex:indexPath.row];
    ccell.timeLabel.text = [dateOfMessages objectAtIndex:indexPath.row];
}

- (CGFloat)heightForText:(NSString *)bodyText
{
    UIFont *cellFont = [UIFont systemFontOfSize:17];
    CGSize constraintSize = CGSizeMake(300, MAXFLOAT);
    CGSize labelSize = [bodyText sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
    CGFloat height = labelSize.height + 10;
    NSLog(@"height=%f", height);
    return height;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CGFloat width=tableView.bounds.size.width;
    CGFloat height=25;
    UILabel * headerLbl=[[UILabel alloc] init];
    headerLbl.frame=CGRectMake(0, 0, width, height);
    headerLbl.text=[NSString stringWithFormat:@"%@'s Shared\nConversation With %@", sharer, conversant];
    headerLbl.textAlignment=NSTextAlignmentCenter;
    headerLbl.backgroundColor = [UIColor whiteColor];
    headerLbl.lineBreakMode = NSLineBreakByWordWrapping;
    headerLbl.numberOfLines = 0;
    return headerLbl;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    // calculate height of UILabel
    UILabel *lblSectionName = [[UILabel alloc] init];
    lblSectionName.text = [NSString stringWithFormat:@"%@'s Shared\nConversation With %@", sharer, conversant];
    lblSectionName.numberOfLines = 0;
    lblSectionName.lineBreakMode = NSLineBreakByWordWrapping;
    
    [lblSectionName sizeToFit];
    
    return lblSectionName.frame.size.height;
}

- (BOOL) hidesBottomBarWhenPushed
{
    return (self.navigationController.topViewController == self);
}


@end
