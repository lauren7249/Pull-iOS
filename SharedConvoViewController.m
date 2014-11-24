//
//  SharedConvoViewController.m
//  Pull
//
//  Created by Adam Horowitz on 9/17/14.
//
//

#import "SharedConvoViewController.h"
#import "DatabaseHandler.h"
#import "STBubbleTableViewCell.h"

@interface SharedConvoViewController () <STBubbleTableViewCellDataSource, STBubbleTableViewCellDelegate>

@property (weak, nonatomic) IBOutlet UITextField *commentTextField;

@end

@implementation SharedConvoViewController

@synthesize tableView;
@synthesize label;
@synthesize convoID;
@synthesize sharer;
@synthesize conversant;

NSMutableArray *listOfMessages;
NSMutableArray *dateOfMessages;
NSMutableArray *typeOfMessages;

static CGFloat const FONTSIZE = 14.0;
static int const DATELABEL_TAG = 1;
static int const MESSAGELABEL_TAG = 2;
static int const IMAGEVIEW_TAG_1 = 3;
static int const IMAGEVIEW_TAG_2 = 4;
static int const IMAGEVIEW_TAG_3 = 5;
static int const IMAGEVIEW_TAG_4 = 6;
static int const IMAGEVIEW_TAG_5 = 7;
static int const IMAGEVIEW_TAG_6 = 8;
static int const IMAGEVIEW_TAG_7 = 9;
static int const IMAGEVIEW_TAG_8 = 10;
static int const IMAGEVIEW_TAG_9 = 11;

int bubbleFragment_width, bubbleFragment_height;
int bubble_x, bubble_y;



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
    self.title = @"Shared Messages";
    label.text = [NSString stringWithFormat:@"%@'s Shared\nConversation With %@", sharer, conversant];
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
   
    self.tableView.backgroundColor = [UIColor colorWithRed:219.0f/255.0f green:226.0f/255.0f blue:237.0f/255.0f alpha:1.0f];
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
    static NSString *CellIdentifier = @"Bubble Cell";
    
    STBubbleTableViewCell *cell = (STBubbleTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[STBubbleTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.backgroundColor = self.tableView.backgroundColor;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
	}
	
	NSString *message = [listOfMessages objectAtIndex:indexPath.row];
    NSString *type = [typeOfMessages objectAtIndex:indexPath.row];
	
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
    
    return cell;
    
    
    
    
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
    
    NSString *message = [listOfMessages objectAtIndex:indexPath.row];
	
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
	
	return size.height + 15.0f;

    
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
        
    }
}


@end
