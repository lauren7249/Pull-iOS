//
//  SharedConvoViewController.h
//  Pull
//
//  Created by Adam Horowitz on 9/17/14.
//
//

#import <UIKit/UIKit.h>
#import "SharedConvoTemplateViewController.h"

@interface SharedConvoViewController4S : SharedConvoTemplateViewController{
    IBOutlet UITableView *tableView;
    IBOutlet UIScrollView *scrollView;
    IBOutlet UITextField *commentTextField;
    IBOutlet UIView *commentView;
    
}
@end
