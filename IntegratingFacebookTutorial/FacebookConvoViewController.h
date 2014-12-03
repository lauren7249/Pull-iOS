//
//  FacebookConvoViewController.h
//  Pull
//
//  Created by Adam Horowitz on 12/3/14.
//
//

#import <UIKit/UIKit.h>

@interface FacebookConvoViewController : UIViewController{

    IBOutlet UITableView *tableView;
}

@property(readwrite) NSDictionary *messageInfo;
@property(readwrite) NSArray *comments;


@end
