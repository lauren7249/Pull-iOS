//
//  SharedConvoTemplateViewController.h
//  Pull
//
//  Created by Adam Horowitz on 9/26/14.
//
//

#import <UIKit/UIKit.h>

@interface SharedConvoTemplateViewController : UIViewController

@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, retain) UITextField *commentTextField;
@property (nonatomic, retain) UIView *commentView;
@property (readwrite) NSString *convoID;
@property (readwrite) NSString *sharer;
@property (readwrite) NSString *conversant;
@property (readwrite) NSString *conversantPhone;
@property (readwrite) NSString *sharerPhone;
@property (readwrite) float kOFFSET_FOR_KEYBOARD;
@property (readwrite) int keyboardTimes;


@end
