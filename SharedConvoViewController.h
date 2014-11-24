//
//  SharedConvoViewController.h
//  Pull
//
//  Created by Adam Horowitz on 9/17/14.
//
//

#import <UIKit/UIKit.h>

@interface SharedConvoViewController : UIViewController{
    IBOutlet UITableView *tableView;
    IBOutlet UILabel *label;
}

@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) UILabel *label;
@property (readwrite) NSString *convoID;
@property (readwrite) NSString *sharer;
@property (readwrite) NSString *conversant;

@end
