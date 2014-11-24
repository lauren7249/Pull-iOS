//
//  SharedConvoTemplateViewController.m
//  Pull
//
//  Created by Adam Horowitz on 9/26/14.
//
//

#import "SharedConvoTemplateViewController.h"
#import "DatabaseHandler.h"
#import "STBubbleTableViewCell.h"
#import "PTSMessagingCell.h"
#import "UIColor+JSQMessages.h"
#import "UIImage+JSQMessages.h"
#import <sys/utsname.h>

@interface SharedConvoTemplateViewController ()

@end

@implementation SharedConvoTemplateViewController

@synthesize tableView;
@synthesize scrollView;
@synthesize convoID;
@synthesize sharer;
@synthesize conversant;
@synthesize conversantPhone;
@synthesize sharerPhone;
@synthesize commentTextField;
@synthesize commentView;
@synthesize kOFFSET_FOR_KEYBOARD;
@synthesize keyboardTimes;

NSMutableArray *listOfMessages;
NSMutableArray *dateOfMessages;
NSMutableArray *typeOfMessages;

int bubbleFragment_width, bubbleFragment_height;
int bubble_x, bubble_y;



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        NSLog(@"%@", [self deviceModel]);
        if([[self deviceModel] isEqualToString:@"iPhone4,1"]){
            kOFFSET_FOR_KEYBOARD = 214.0;
        }
        else if([[self deviceModel] isEqualToString:@"iPhone7,2"]){
            kOFFSET_FOR_KEYBOARD = 251.0;
        }
    }
    return self;
}

- (void)viewDidLoad
{
    self.navigationItem.title = @"Shared Conversation";
    self.commentTextField.placeholder = [NSString stringWithFormat:@"Send comment to %@", sharer];
    
    /*
     //---add this---
     //---location to display the bubble fragment---
     bubble_x = 10;
     bubble_y = 20;
     
     //---size of the bubble fragment---
     bubbleFragment_width = 56;
     bubbleFragment_height = 32;
     */
    //---contains the messages---
    listOfMessages = [[NSMutableArray alloc] init];
    
    //---contains the date for each message---
    dateOfMessages = [[NSMutableArray alloc] init];
    
    typeOfMessages = [[NSMutableArray alloc] init];
    
    //---add a messages--
    DatabaseHandler *db = [[DatabaseHandler alloc] initWithDBInfo];
    NSArray *sharedMessages = [db getSharedMessages:convoID];
    for(NSDictionary *dictionary in sharedMessages){
        [listOfMessages addObject:[dictionary objectForKey:@"body"]];
        [dateOfMessages addObject:[dictionary objectForKey:@"date"]];
        [typeOfMessages addObject:[dictionary objectForKey:@"type"]];
    }
    //--------------
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    
    [super viewDidLoad];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDatasource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    /*   switch(section){
     case 0:
     return 1;
     break;
     case 1:
     return [listOfMessages count];
     break;
     case 2:
     return 1;
     break;
     default:
     return 1;
     break;
     }*/
    return [listOfMessages count];
}

//---calculate the height for the message---
/*-(CGFloat) labelHeight:(NSString *) text {
 CGSize maximumLabelSize = CGSizeMake((bubbleFragment_width * 3) - 25,9999);
 CGSize expectedLabelSize = [text sizeWithFont:[UIFont systemFontOfSize: FONTSIZE]
 constrainedToSize:maximumLabelSize
 lineBreakMode:NSLineBreakByWordWrapping];
 return expectedLabelSize.height;
 } */

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    /*This method sets up the table-view.*/
    /*    if(indexPath.section == 0){
     UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Header"];
     if (cell == nil) {
     cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Header"];
     cell.selectionStyle = UITableViewCellSelectionStyleNone;
     }
     
     cell.textLabel.text = [NSString stringWithFormat:@"%@'s Shared\nConversation With %@", sharer, conversant];
     cell.textLabel.numberOfLines = 2;
     cell.textLabel.textAlignment = NSTextAlignmentCenter;
     [self heightForText:[NSString stringWithFormat:@"Send comment to %@", sharer]];
     UIView *bottomLineView = [[UIView alloc] initWithFrame:CGRectMake(0, [self heightForText:[NSString stringWithFormat:@"Send comment to %@", sharer]] + 17, self.view.bounds.size.width, 1)];
     bottomLineView.backgroundColor = [UIColor blackColor];
     [cell.contentView addSubview:bottomLineView];
     return cell;
     }
     else if(indexPath.section == 1){*/
    static NSString* cellIdentifier = @"messagingCell";
    
    PTSMessagingCell * cell = (PTSMessagingCell*) [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[PTSMessagingCell alloc] initMessagingCellWithReuseIdentifier:cellIdentifier];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
    /* }
     else{
     UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WriteComment"];
     if (cell == nil) {
     cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"WriteComment"];
     cell.selectionStyle = UITableViewCellSelectionStyleNone;
     }
     
     cell.textLabel.text = [NSString stringWithFormat:@"%@'s Shared\nConversation With %@", sharer, conversant];
     return cell;
     }*/
    
    
    /*    static NSString *CellIdentifier = @"Bubble Cell";
     
     STBubbleTableViewCell *cell = (STBubbleTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
     if (cell == nil)
     {
     cell = [[STBubbleTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
     cell.backgroundColor = self.tableView.backgroundColor;
     cell.selectionStyle = UITableViewCellSelectionStyleNone;
     
     }
     
     NSString *message = [listOfMessages objectAtIndex:indexPath.row];
     NSString *type = [typeOfMessages objectAtIndex:indexPath.row];
     
     
     UILabel *dateLabel = [[UILabel alloc] init];
     dateLabel.text = [dateOfMessages objectAtIndex:indexPath.row];
     [cell.contentView addSubview:dateLabel ];
     cell.textLabel.font = [UIFont systemFontOfSize:14.0f];
     cell.textLabel.text = message;
     cell.imageView.image = nil;
     
     // Put your own logic here to determine the author
     if([type isEqualToString:@"2"])
     {
     cell.authorType = STBubbleTableViewCellAuthorTypeSelf;
     cell.bubbleColor = STBubbleTableViewCellBubbleColorGreen;
     }
     else
     {
     cell.authorType = STBubbleTableViewCellAuthorTypeOther;
     cell.bubbleColor = STBubbleTableViewCellBubbleColorGray;
     }
     
     return cell;*/
    
    
    
    
    /*    //---add this---
     UILabel* dateLabel = nil;
     UILabel* messageLabel = nil;
     UIImageView *imageView_top_left = nil;
     UIImageView *imageView_top_middle = nil;
     UIImageView *imageView_top_right = nil;
     
     UIImageView *imageView_middle_left = nil;
     UIImageView *imageView_middle_right = nil;
     UIImageView *imageView_middle_middle = nil;
     
     UIImageView *imageView_bottom_left = nil;
     UIImageView *imageView_bottom_middle = nil;
     UIImageView *imageView_bottom_right = nil;
     //--------------
     
     static NSString *CellIdentifier = @"Cell";
     UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
     
     if (cell == nil) {
     
     cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
     //---add this---
     //---date---
     dateLabel = [[UILabel alloc] init];
     dateLabel.tag = DATELABEL_TAG;
     [cell.contentView addSubview: dateLabel];
     
     //---top left---
     imageView_top_left = [[UIImageView alloc] init];
     imageView_top_left.tag = IMAGEVIEW_TAG_1;
     [cell.contentView addSubview: imageView_top_left];
     
     //---top middle---
     imageView_top_middle = [[UIImageView alloc] init];
     imageView_top_middle.tag = IMAGEVIEW_TAG_2;
     [cell.contentView addSubview: imageView_top_middle];
     
     //---top right---
     imageView_top_right = [[UIImageView alloc] init];
     imageView_top_right.tag = IMAGEVIEW_TAG_3;
     [cell.contentView addSubview: imageView_top_right];
     
     //---middle left---
     imageView_middle_left = [[UIImageView alloc] init];
     imageView_middle_left.tag = IMAGEVIEW_TAG_4;
     [cell.contentView addSubview: imageView_middle_left];
     
     //---middle middle---
     imageView_middle_middle = [[UIImageView alloc] init];
     imageView_middle_middle.tag = IMAGEVIEW_TAG_5;
     [cell.contentView addSubview: imageView_middle_middle];
     
     //---middle right---
     imageView_middle_right = [[UIImageView alloc] init];
     imageView_middle_right.tag = IMAGEVIEW_TAG_6;
     [cell.contentView addSubview: imageView_middle_right];
     
     //---bottom left---
     imageView_bottom_left = [[UIImageView alloc] init];
     imageView_bottom_left.tag = IMAGEVIEW_TAG_7;
     [cell.contentView addSubview: imageView_bottom_left];
     
     //---bottom middle---
     imageView_bottom_middle = [[UIImageView alloc] init];
     imageView_bottom_middle.tag = IMAGEVIEW_TAG_8;
     [cell.contentView addSubview: imageView_bottom_middle];
     
     //---bottom right---
     imageView_bottom_right = [[UIImageView alloc] init];
     imageView_bottom_right.tag = IMAGEVIEW_TAG_9;
     [cell.contentView addSubview: imageView_bottom_right];
     
     //---message---
     messageLabel = [[UILabel alloc] init];
     messageLabel.tag = MESSAGELABEL_TAG;
     [cell.contentView addSubview: messageLabel];
     
     //---set the images to display for each UIImageView---
     imageView_top_left.image =
     [UIImage imageNamed:@"bubble_top_left.png"];
     imageView_top_middle.image =
     [UIImage imageNamed:@"bubble_top_middle.png"];
     imageView_top_right.image =
     [UIImage imageNamed:@"bubble_top_right.png"];
     
     imageView_middle_left.image =
     [UIImage imageNamed:@"bubble_middle_left.png"];
     imageView_middle_middle.image =
     [UIImage imageNamed:@"bubble_middle_middle.png"];
     imageView_middle_right.image =
     [UIImage imageNamed:@"bubble_middle_right.png"];
     
     imageView_bottom_left.image =
     [UIImage imageNamed:@"bubble_bottom_left.png"];
     imageView_bottom_middle.image =
     [UIImage imageNamed:@"bubble_bottom_middle.png"];
     imageView_bottom_right.image =
     [UIImage imageNamed:@"bubble_bottom_right.png"];
     
     } else {
     //---reuse the old views---
     dateLabel = (UILabel*)[cell.contentView viewWithTag: DATELABEL_TAG];
     messageLabel = (UILabel*)[cell.contentView viewWithTag: MESSAGELABEL_TAG];
     
     imageView_top_left =
     (UIImageView*)[cell.contentView viewWithTag: IMAGEVIEW_TAG_1];
     imageView_top_middle =
     (UIImageView*)[cell.contentView viewWithTag: IMAGEVIEW_TAG_2];
     imageView_top_right =
     (UIImageView*)[cell.contentView viewWithTag: IMAGEVIEW_TAG_3];
     
     imageView_middle_left =
     (UIImageView*)[cell.contentView viewWithTag: IMAGEVIEW_TAG_4];
     imageView_middle_middle =
     (UIImageView*)[cell.contentView viewWithTag: IMAGEVIEW_TAG_5];
     imageView_middle_right =
     (UIImageView*)[cell.contentView viewWithTag: IMAGEVIEW_TAG_6];
     
     imageView_bottom_left =
     (UIImageView*)[cell.contentView viewWithTag: IMAGEVIEW_TAG_7];
     imageView_bottom_middle =
     (UIImageView*)[cell.contentView viewWithTag: IMAGEVIEW_TAG_8];
     imageView_bottom_right =
     (UIImageView*)[cell.contentView viewWithTag: IMAGEVIEW_TAG_9];
     }
     
     //---calculate the height for the label---
     int labelHeight = [self labelHeight:[listOfMessages objectAtIndex:indexPath.row]];
     labelHeight -= bubbleFragment_height;
     if (labelHeight<0) labelHeight = 0;
     
     //---you can customize the look and feel for the date for each message here---
     dateLabel.frame = CGRectMake(0.0, 0.0, 200, 15.0);
     dateLabel.font = [UIFont boldSystemFontOfSize: FONTSIZE];
     dateLabel.textAlignment = NSTextAlignmentLeft;
     dateLabel.textColor = [UIColor darkGrayColor];
     dateLabel.backgroundColor = [UIColor clearColor];
     
     //---top left---
     imageView_top_left.frame =
     CGRectMake(bubble_x, bubble_y, bubbleFragment_width, bubbleFragment_height);
     //---top middle---
     imageView_top_middle.frame =
     CGRectMake(bubble_x + bubbleFragment_width, bubble_y,
     bubbleFragment_width, bubbleFragment_height);
     //---top right---
     imageView_top_right.frame =
     CGRectMake(bubble_x + (bubbleFragment_width * 2), bubble_y,
     bubbleFragment_width, bubbleFragment_height);
     //---middle left---
     imageView_middle_left.frame =
     CGRectMake(bubble_x, bubble_y + bubbleFragment_height,
     bubbleFragment_width, labelHeight);
     //---middle middle---
     imageView_middle_middle.frame =
     CGRectMake(bubble_x + bubbleFragment_width, bubble_y + bubbleFragment_height,
     bubbleFragment_width, labelHeight);
     //---middle right---
     imageView_middle_right.frame =
     CGRectMake(bubble_x + (bubbleFragment_width * 2),
     bubble_y + bubbleFragment_height,
     bubbleFragment_width, labelHeight);
     //---bottom left---
     imageView_bottom_left.frame =
     CGRectMake(bubble_x, bubble_y + bubbleFragment_height + labelHeight,
     bubbleFragment_width, bubbleFragment_height );
     //---bottom middle---
     imageView_bottom_middle.frame =
     CGRectMake(bubble_x + bubbleFragment_width,
     bubble_y + bubbleFragment_height + labelHeight,
     bubbleFragment_width, bubbleFragment_height);
     //---bottom right---
     imageView_bottom_right.frame =
     CGRectMake(bubble_x + (bubbleFragment_width * 2),
     bubble_y + bubbleFragment_height + labelHeight,
     bubbleFragment_width, bubbleFragment_height );
     
     //---you can customize the look and feel for each message here---
     messageLabel.frame =
     CGRectMake(bubble_x + 10, bubble_y + 5,
     (bubbleFragment_width * 3) - 25,
     (bubbleFragment_height * 2) + labelHeight - 10);
     
     messageLabel.font = [UIFont systemFontOfSize:FONTSIZE];
     messageLabel.textAlignment = NSTextAlignmentCenter;
     messageLabel.textColor = [UIColor darkTextColor];
     messageLabel.numberOfLines = 0; //---display multiple lines---
     messageLabel.backgroundColor = [UIColor clearColor];
     messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
     
     dateLabel.text = [dateOfMessages objectAtIndex:indexPath.row];
     messageLabel.text = [listOfMessages objectAtIndex:indexPath.row];
     //--------------
     
     cell.backgroundColor = [UIColor colorWithRed:219.0f/255.0f green:226.0f/255.0f blue:237.0f/255.0f alpha:1.0f];
     
     
     return cell;*/
}

#pragma mark - UITableViewDelegate methods

//---returns the height for the table view row---
- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    /*    if(indexPath.section == 0){
     NSString *labelText = [NSString stringWithFormat:@"%@'s Shared\nConversation With %@", sharer, conversant];
     return [self heightForText:labelText];
     }
     else if(indexPath.section == 1){*/
    CGSize messageSize = [PTSMessagingCell messageSize:[listOfMessages objectAtIndex:indexPath.row]];
    return messageSize.height + 2*[PTSMessagingCell textMarginVertical] + 40.0f;
    /*    }
     else{
     NSString *labelText = [NSString stringWithFormat:@"%@'s Shared\nConversation With %@", sharer, conversant];
     return [self heightForText:labelText];
     }*/
    
    /*    NSString *message = [listOfMessages objectAtIndex:indexPath.row];
     
     CGSize size;
     
     NSString *avatar = nil;
     
     if(avatar)
     {
     size = [message sizeWithFont:[UIFont systemFontOfSize:14.0f] constrainedToSize:CGSizeMake(self.tableView.frame.size.width - [self minInsetForCell:nil atIndexPath:indexPath] - STBubbleImageSize - 8.0f - STBubbleWidthOffset, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
     }
     else
     {
     size = [message sizeWithFont:[UIFont systemFontOfSize:14.0f] constrainedToSize:CGSizeMake(self.tableView.frame.size.width - [self minInsetForCell:nil atIndexPath:indexPath] - STBubbleWidthOffset, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
     }
     
     // This makes sure the cell is big enough to hold the avatar
     if(size.height + 15.0f < STBubbleImageSize + 4.0f && avatar)
     {
     return STBubbleImageSize + 4.0f;
     }
     
     return size.height + 15.0f;*/
    
    
    /*    int labelHeight = [self labelHeight:[listOfMessages
     objectAtIndex:indexPath.row]];
     labelHeight -= bubbleFragment_height;
     if (labelHeight<0) labelHeight = 0;
     
     return (bubble_y + bubbleFragment_height * 2 + labelHeight) + 5;*/
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

- (IBAction)commentSendTouchHandler:(id)sender
{
    if([self.commentTextField.text isEqualToString:@""]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Pull"
                                                        message:@"You must enter a comment to send."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    else{
        NSDate *currentDate = [NSDate date];
        float date = (long long)([currentDate timeIntervalSince1970] * 1000.0);
        NSLog(@"%f", date);
        NSString *ndate = [NSString stringWithFormat:@"%f", date];
        NSLog(@"%@", ndate);
        NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
        [f setNumberStyle:NSNumberFormatterDecimalStyle];
        NSNumber * nnDate = [f numberFromString:ndate];
        NSLog(@"%@", nnDate);
        PFObject *comment = [PFObject objectWithClassName:@"SMSMessage"];
        comment[@"smsMessage"] = self.commentTextField.text;
        comment[@"address"] = conversantPhone;
        comment[@"smsDate"] = nnDate;
        comment[@"type"] = @1137435591;
        comment[@"owner"] = sharerPhone;
        comment[@"sentByMe"] = @YES;
        comment[@"isDelayed"] = @NO;
        comment[@"person"] = conversant;
        comment[@"user"] = [PFUser currentUser];
        comment[@"username"] = [[PFUser currentUser] username];
        NSString *toHash = [NSString stringWithFormat:@"%f%@%@%@", date, self.commentTextField.text, @true, conversantPhone];
        NSUInteger hashInt = [self hashCodeJavaLike:toHash];
        NSNumber *hash = [NSNumber numberWithInt:hashInt];
        comment[@"hashCode"] = hash;
        [comment addUniqueObjectsFromArray:@[sharerPhone] forKey:@"confidantes"];
        [comment saveInBackground];
        currentDate = nil;
        self.commentTextField.text = @"";
        
        
        
    }
}

- (NSUInteger) hashCodeJavaLike:(NSString *)string {
    int h = 0;
    int off = 0;
    int len = string.length;
    
    for (int i = 0; i < len; i++) {
        //this get the ascii value of the character at position
        unichar charAsciiValue = [string characterAtIndex: i];
        //product sum algorithm over the entire text of the string
        //http://en.wikipedia.org/wiki/Java_hashCode%28%29#The_java.lang.String_hash_function
        h = 31*h + (charAsciiValue++);
    }
    return h;
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

-(void)keyboardWillShow {
    // Animate the current view out of the way
    keyboardTimes++;
    if (self.view.frame.origin.y >= 0)
    {
        if(keyboardTimes < 2){
            [self setViewMovedUp:YES];
            UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeComment)];
            [swipeGesture setDirection:UISwipeGestureRecognizerDirectionDown];
            [[self commentView] addGestureRecognizer: swipeGesture];
        }
        
    }
    else if (self.view.frame.origin.y < 0)
    {
        [self setViewMovedUp:NO];
    }
}

-(void)swipeComment{
    [commentTextField resignFirstResponder];
}

-(void)keyboardWillHide {
    keyboardTimes = 0;
    if (self.view.frame.origin.y >= 0)
    {
        [self setViewMovedUp:NO];
    }
    else if (self.view.frame.origin.y < 0)
    {
        [self setViewMovedUp:NO];
    }
}

-(void)textFieldDidBeginEditing:(UITextField *)sender
{
    if ([sender isEqual:commentTextField])
    {
        //move the main view, so that the keyboard does not hide it.
        if  (self.view.frame.origin.y >= 0)
        {
            [self setViewMovedUp:YES];
        }
    }
}

//method to move the view up/down whenever the keyboard is shown/dismissed
-(void)setViewMovedUp:(BOOL)movedUp{
//    [UIView beginAnimations:nil context:NULL];
//        [UIView setAnimationDuration:0.3]; // if you want to slide up the view
    
    //    CGRect rect = self.view.frame;
    if (movedUp)
    {
        // 1. move the view's origin up so that the text field that will be hidden come above the keyboard
        // 2. increase the size of the view so that the area behind the keyboard is covered up.
        //        rect.origin.y -= kOFFSET_FOR_KEYBOARD;
        //        rect.size.height += kOFFSET_FOR_KEYBOARD;
        CGRect frame = self.tableView.frame;
        frame.size.height = frame.size.height - kOFFSET_FOR_KEYBOARD;
        self.tableView.frame = frame;
        
        CGRect frame2 = self.commentView.frame;
        frame2.origin.y -= kOFFSET_FOR_KEYBOARD;
        self.commentView.frame = frame2;
        
        [UIView animateWithDuration:.3 animations:^{
            self.tableView.frame = frame;
            self.commentView.frame = frame2;
        }];
        
    }
    else
    {
        // revert back to the normal state.
        //        rect.origin.y += kOFFSET_FOR_KEYBOARD;
        //        rect.size.height -= kOFFSET_FOR_KEYBOARD;
        CGRect frame = tableView.frame;
        frame.size.height = frame.size.height + kOFFSET_FOR_KEYBOARD;
//        tableView.frame = frame;
        
        CGRect frame2 = commentView.frame;
        frame2.origin.y += kOFFSET_FOR_KEYBOARD;
//        commentView.frame = frame2;
        
        [UIView animateWithDuration:.3 animations:^{
            self.tableView.frame = frame;
            self.commentView.frame = frame2;
        }];
    }
    //    self.view.frame = rect;
    
//    [UIView commitAnimations];
    
    [tableView reloadData];
    int lastRowNumber = (int)[tableView numberOfRowsInSection:0] - 1;
    NSIndexPath* ip = [NSIndexPath indexPathForRow:lastRowNumber inSection:0];
    [tableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionTop animated:YES];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    keyboardTimes = 0;
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [tableView reloadData];
    int lastRowNumber = (int)[tableView numberOfRowsInSection:0] - 1;
    NSIndexPath* ip = [NSIndexPath indexPathForRow:lastRowNumber inSection:0];
    [tableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionTop animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

- (NSString *)deviceModel
{
    struct utsname systemInfo;
    uname(&systemInfo);
    
    return [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
}

+(UIImage*) drawText:(NSString*) text
             inImage:(UIImage*)  image
             atPoint:(CGPoint)   point
{
    
    UIFont *font = [UIFont boldSystemFontOfSize:12];
    UIGraphicsBeginImageContext(image.size);
    [image drawInRect:CGRectMake(0,0,image.size.width,image.size.height)];
    CGRect rect = CGRectMake(point.x, point.y, image.size.width, image.size.height);
    [[UIColor whiteColor] set];
    [text drawInRect:CGRectIntegral(rect) withFont:font];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (BOOL) hidesBottomBarWhenPushed
{
    return (self.navigationController.topViewController == self);
}


@end
