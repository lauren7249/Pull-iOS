//
//  MyTabBar.m
//  Pull
//
//  Created by Adam Horowitz on 11/17/14.
//
//

#import "MyTabBar.h"
#import "HomePageViewController.h"
#import "YourMessagesViewController.h"
#import <FacebookSDK/FacebookSDK.h>

@interface MyTabBar ()

@end

@implementation MyTabBar

- (void)viewDidLoad {
    [super viewDidLoad];
    
    HomePageViewController *view1 = [[HomePageViewController alloc] init];
    
    UINavigationController*  theNavController = [[UINavigationController alloc]
                                                 initWithRootViewController:view1];
    
    YourMessagesViewController *ym = [[YourMessagesViewController alloc] init];
    
    if(FBSession.activeSession.isOpen){
        [FBRequestConnection startWithGraphPath:@"/me/inbox"
                                     parameters:nil
                                     HTTPMethod:@"GET"
                              completionHandler:^(
                                                  FBRequestConnection *connection,
                                                  id result,
                                                  NSError *error
                                                  ) {
                                  if (error) {
//                                      [self handleAPICallError:error];
                                  }
                                  else{
                                      NSDictionary *resultDict = (NSDictionary *)result;
                                      NSArray *facebookConversations = [resultDict objectForKey:@"data"];
                                      ym.facebookConversations = facebookConversations;
                                      
                                      UINavigationController*  theNavController2 = [[UINavigationController alloc]
                                                                                    initWithRootViewController:ym];
                                      
                                      
                                      NSMutableArray *tabViewControllers = [[NSMutableArray alloc] init];
                                      [tabViewControllers addObject:theNavController];
                                      [tabViewControllers addObject:theNavController2];
                                      
                                      [self setViewControllers:tabViewControllers];
                                      //can't set this until after its added to the tab bar
                                      theNavController.tabBarItem =
                                      [[UITabBarItem alloc] initWithTitle:@"Shared" image:nil tag:1];
                                      theNavController2.tabBarItem =
                                      [[UITabBarItem alloc] initWithTitle:@"Your Messages" image:nil tag:2];

                                      
                                  }
                              }];
    }
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

@end
