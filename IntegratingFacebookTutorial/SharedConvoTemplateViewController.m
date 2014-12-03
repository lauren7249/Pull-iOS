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

@implementation SharedConvoTemplateViewController {
    BOOL keyboardHidden;
    int keyboardTimes;
    CGFloat kOFFSET_FOR_KEYBOARD;
}

@synthesize tableView;
@synthesize scrollView;
@synthesize convoID;
@synthesize sharer;
@synthesize conversant;
@synthesize conversantPhone;
@synthesize sharerPhone;
@synthesize commentTextField;
@synthesize commentView;

NSMutableArray *listOfMessages;
NSMutableArray *dateOfMessages;
NSMutableArray *typeOfMessages;

int bubbleFragment_width, bubbleFragment_height;
int bubble_x, bubble_y;



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    keyboardHidden = YES;
    
    self.navigationItem.title = @"Shared Conversation";
    self.commentTextField.placeholder = [NSString stringWithFormat:@"Send comment to %@", sharer];
    
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
    return [listOfMessages count];
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

-(void)updateSwipeGesture {
    UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeComment)];
    [swipeGesture setDirection:UISwipeGestureRecognizerDirectionDown];
    [[self commentView] addGestureRecognizer: swipeGesture];
}

-(void)keyboardWillShow:(NSNotification *)notification {
    // Animate the current view out of the way
    NSLog(@"keyboardWillShow");
    [self saveKeyboardHeight:notification];
    
    keyboardTimes++;
    if (self.view.frame.origin.y >= 0)
    {
        if(keyboardTimes < 2){
            [self setViewMovedUp:YES];
            [self updateSwipeGesture];
        }
        
    }
    else if (self.view.frame.origin.y < 0)
    {
        [self setViewMovedUp:NO];
    }
}

-(void)swipeComment{
    NSLog(@"resigning textfield");
    [commentTextField resignFirstResponder];
}

-(void)keyboardWillHide {
    NSLog(@"keyboardWillHide");
    keyboardHidden = YES;
    
    keyboardTimes = 0;
    [self setViewMovedUp:NO];
}

-(void)saveKeyboardHeight:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    
    CGRect keyboardEndFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    if (CGRectIsNull(keyboardEndFrame)) {
        return;
    }
    
    NSLog(@"Saving Rect Height: %f", keyboardEndFrame.size.height);
    
    kOFFSET_FOR_KEYBOARD = keyboardEndFrame.size.height;
}

-(void)keyboardDidChange:(NSNotification *)notification {
    NSLog(@"keyboardDidChange");
}

-(void)keyboardDidShow:(NSNotification *)notification {
    NSLog(@"keyboardDidShow");
    keyboardHidden = NO;
}

-(void)keyboardWillChange:(NSNotification *)notification {
    NSLog(@"keyboardWillChange");
    if (keyboardHidden) {
        return;
    }

    NSDictionary *userInfo = [notification userInfo];
    
    CGRect keyboardEndFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    if (CGRectIsNull(keyboardEndFrame)) {
        return;
    }
    
    if (keyboardEndFrame.size.height > kOFFSET_FOR_KEYBOARD) {
        NSLog(@"Growing Keyboard View");
        [self saveKeyboardHeight:notification];
        [self updateView];
        [self updateSwipeGesture];
    } else if (keyboardEndFrame.size.height < kOFFSET_FOR_KEYBOARD) {
        NSLog(@"Shrinking Keyboard View");
        [self saveKeyboardHeight:notification];
        [self updateView];
        [self updateSwipeGesture];
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

-(void)updateView {
    CGRect frame = self.view.frame;
    
    CGRect commentViewFrame = self.commentView.frame;
    commentViewFrame.origin.y = frame.size.height - commentViewFrame.size.height - kOFFSET_FOR_KEYBOARD;
    
    CGRect tableViewFrame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
    tableViewFrame.size.height = frame.size.height - commentViewFrame.size.height - kOFFSET_FOR_KEYBOARD;
    
    [UIView animateWithDuration:.3 animations:^{
        self.tableView.frame = tableViewFrame;
        self.commentView.frame = commentViewFrame;
    }];
    
    int lastRowNumber = (int)[tableView numberOfRowsInSection:0] - 1;
    NSIndexPath* ip = [NSIndexPath indexPathForRow:lastRowNumber inSection:0];
    [tableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

//method to move the view up/down whenever the keyboard is shown/dismissed
-(void)setViewMovedUp:(BOOL)movedUp{
    
    CGRect commentViewFrame = commentView.frame;
    CGRect tableViewFrame = tableView.frame;
    
    if (movedUp)
    {
        
        NSLog(@"Moving View Up");
        commentViewFrame.origin.y = self.view.frame.size.height - commentViewFrame.size.height - kOFFSET_FOR_KEYBOARD;
        tableViewFrame.size.height = self.view.frame.size.height - commentViewFrame.size.height - kOFFSET_FOR_KEYBOARD;
        
    }
    else
    {
        NSLog(@"Moving View Down");
        
        commentViewFrame.origin.y = self.view.frame.size.height - commentViewFrame.size.height;
        tableViewFrame.size.height = self.view.frame.size.height - commentViewFrame.size.height;
        
    }
    
    [UIView animateWithDuration:.3 animations:^{
        self.tableView.frame = tableViewFrame;
        self.commentView.frame = commentViewFrame;
    }];
    
    [tableView reloadData]; // Removing this seems to cause a bug where the keyboard autohides
    
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
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillChange:)
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidChange:)
                                                 name:UIKeyboardDidChangeFrameNotification
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
                                                    name:UIKeyboardDidShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillChangeFrameNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidChangeFrameNotification
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
