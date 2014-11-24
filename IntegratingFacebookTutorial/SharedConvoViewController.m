//
//  SharedConvoViewController.m
//  Pull
//
//  Created by Adam Horowitz on 9/17/14.
//
//

#import "SharedConvoViewController.h"

@interface SharedConvoViewController ()

@end

@implementation SharedConvoViewController

NSMutableArray *listOfMessages;
NSMutableArray *dateOfMessages;

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //---add this---
    //---location to display the bubble fragment---
    bubble_x = 10;
    bubble_y = 20;
    
    //---size of the bubble fragment---
    bubbleFragment_width = 56;
    bubbleFragment_height = 32;
    
    //---contains the messages---
    listOfMessages = [[NSMutableArray alloc] init];
    
    //---contains the date for each message---
    dateOfMessages = [[NSMutableArray alloc] init];
    
    //---add a message---
    [listOfMessages addObject:@"Hello there!"];
    [dateOfMessages addObject:[NSString stringWithFormat:@"%@",[NSDate date]]];
    //--------------
    
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    return [listOfMessages count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //---add this---
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

/*
#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here, for example:
    // Create the next view controller.
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:<#@"Nib name"#> bundle:nil];
    
    // Pass the selected object to the new view controller.
    
    // Push the view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
}
*/

-(CGFloat) labelHeight:(NSString *) text {
    CGSize maximumLabelSize = CGSizeMake((bubbleFragment_width * 3) - 25,9999);
    CGSize expectedLabelSize = [text sizeWithFont:[UIFont systemFontOfSize: FONTSIZE]
                                constrainedToSize:maximumLabelSize
                                    lineBreakMode:UILineBreakModeWordWrap];
    return expectedLabelSize.height;
}

//---returns the height for the table view row---
- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    int labelHeight = [self labelHeight:[listOfMessages
                                         objectAtIndex:indexPath.row]];
    labelHeight -= bubbleFragment_height;
    if (labelHeight<0) labelHeight = 0;
    
    return (bubble_y + bubbleFragment_height * 2 + labelHeight) + 5;
}


@end
