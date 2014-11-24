//
//  Copyright (c) 2013 Parse. All rights reserved.
#import <FacebookSDK/FacebookSDK.h>

@class HomePageViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UINavigationController *rootController;
@property (strong, nonatomic) HomePageViewController *viewController;

- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error;

@end
