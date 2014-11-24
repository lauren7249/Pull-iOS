//
//  HomePageViewController.h
//  Pull
//
//  Created by Adam Horowitz on 9/16/14.
//
//

#import <UIKit/UIKit.h>
#import "SharedConvoTemplateViewController.h"

@interface HomePageViewController : UITableViewController

@property(strong, nonatomic) NSArray *sharedConversations;

@property (nonatomic, strong) SharedConvoTemplateViewController *sharedConvoViewController;




@end
