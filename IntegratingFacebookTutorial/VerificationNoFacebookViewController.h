//
//  VerificationNoFacebookViewController.h
//  Pull
//
//  Created by Adam Horowitz on 10/9/14.
//
//

#import <UIKit/UIKit.h>

@interface VerificationNoFacebookViewController : UIViewController

@property (readwrite) NSMutableString *verifyNum;
@property (readwrite) NSString *phoneNumber;

- (IBAction)verifyButtonTouchHandler:(id)sender;

@end
